# Runbook: running this pipeline end to end

This walks through actually standing the pipeline up, start to finish, using
the synthetic e-commerce dataset in `data/`.

## 0. What you'll need

- A Snowflake account ([free trial](https://signup.snowflake.com/), no card required)
- An AWS account with permission to create an S3 bucket and an IAM role
- Docker, to run NiFi locally (or a local NiFi install)
- Python 3.9+ (for the data generator; already run once, see `data/output/`)

## 1. Generate the sample data

Already done if you're reading this after cloning — CSVs are in `data/output/`.
To regenerate (e.g. with more rows), edit the constants at the top of
`data/generate_data.py` and re-run:

```bash
cd data
python generate_data.py
```

## 2. Create the S3 bucket

1. In the AWS console, create a bucket, e.g. `your-name-ecommerce-pipeline`.
2. Inside it, create four prefixes (folders): `customers/`, `products/`,
   `orders/`, `order_items/`.
3. Block public access (default) — Snowflake will access it via IAM role, not
   public URLs.

## 3. Set up Snowflake

Run the scripts in `sql/` **in order**, in a Snowflake worksheet:

1. `01_setup_database.sql`
2. `02_staging_tables.sql`
3. `03_file_format_stage.sql` — **edit the placeholders first**:
   `<BUCKET_NAME>`, `<AWS_ACCOUNT_ID>`, `<IAM_ROLE_NAME>`
4. Run `DESC INTEGRATION ecommerce_s3_int;` and copy the
   `STORAGE_AWS_IAM_USER_ARN` and `STORAGE_AWS_EXTERNAL_ID` values.
5. In AWS IAM, create a role (or edit an existing one) with an S3 read/list
   policy on your bucket, and a trust policy that trusts the ARN/external ID
   from step 4. [Snowflake's guide](https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration)
   has the exact trust policy JSON.
6. `04_snowpipe.sql`
7. `05_streams_tasks.sql`
8. `06_analytics_tables.sql`
9. `07_customer_segmentation_rfm.sql`

## 4. Wire up S3 event notifications (for Snowpipe auto-ingest)

1. Run `SHOW PIPES;` in Snowflake and copy the `notification_channel` (an SQS
   ARN) for each pipe.
2. In the S3 console, go to your bucket → **Properties** → **Event
   notifications** → **Create event notification**.
3. For each prefix (`customers/`, `products/`, `orders/`, `order_items/`):
   event type = `PUT`, prefix = that folder, destination = SQS queue = the
   matching pipe's notification ARN.

## 5. Run NiFi locally

Quickest path is Docker:

```bash
docker run --name nifi \
  -p 8443:8443 \
  -e SINGLE_USER_CREDENTIALS_USERNAME=admin \
  -e SINGLE_USER_CREDENTIALS_PASSWORD=YourPassword123! \
  apache/nifi:latest
```

Open `https://localhost:8443/nifi` and log in.

Build a simple flow per file (or one flow with four branches):

1. **GetFile** — `Input Directory` = the path to `data/output/` (mount it
   into the container if using Docker), `Keep Source File` = true (so you can
   re-run), filter on the relevant CSV name.
2. **PutS3Object** — set `Bucket` to your bucket, `Object Key` to
   `customers/${filename}` (adjust per branch), and configure AWS credentials
   (Access Key/Secret, or an instance role if running in AWS).
3. Connect GetFile → PutS3Object, start both processors.

Watch the bucket — files should appear within seconds of starting the flow.

## 6. Verify data is flowing

Back in Snowflake:

```sql
-- Did Snowpipe pick up the files?
SELECT SYSTEM$PIPE_STATUS('raw.orders_pipe');

-- Are rows landing in staging?
SELECT COUNT(*) FROM raw.orders;

-- Did the stream capture changes and the task merge them?
SHOW TASKS;
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
ORDER BY scheduled_time DESC LIMIT 10;

SELECT COUNT(*) FROM analytics.fact_orders;

-- The new addition — customer segments
SELECT segment, COUNT(*) AS customers, ROUND(AVG(total_spent), 2) AS avg_spend
FROM analytics.customer_rfm
GROUP BY segment
ORDER BY avg_spend DESC;
```

If `analytics.fact_orders` has rows and `customer_rfm` shows a segment
breakdown, the full pipeline is working.

## 7. Take your screenshots

Now that it's running, capture:
- The NiFi canvas with the flow connected and running
- A Snowflake worksheet showing the `customer_rfm` query and its output
- The S3 bucket showing the loaded files

Drop them in `images/` and reference them from the main `README.md`.

## Troubleshooting

- **Pipe shows `PENDING_FILE_COUNT: 0` forever** — check the S3 event
  notification is pointed at the right SQS ARN and prefix.
- **`COPY INTO` errors on load** — check `SELECT * FROM TABLE(VALIDATE(raw.orders, JOB_ID => '_last'));`
  for row-level error detail.
- **Task not running** — tasks are created suspended; confirm you ran the
  `ALTER TASK ... RESUME;` lines at the bottom of `05_streams_tasks.sql` and
  `07_customer_segmentation_rfm.sql`.
