-- sql/04_snowpipe.sql
-- One pipe per source table. AUTO_INGEST relies on S3 event notifications
-- (SQS) pointed at each pipe -- see docs/RUNBOOK.md for the console steps.

USE DATABASE ecommerce_db;
USE SCHEMA raw;

CREATE OR REPLACE PIPE raw.customers_pipe
  AUTO_INGEST = TRUE
AS
  COPY INTO raw.customers (customer_id, first_name, last_name, email, city, state, signup_date)
  FROM @raw.customers_stage
  FILE_FORMAT = raw.csv_format;

CREATE OR REPLACE PIPE raw.products_pipe
  AUTO_INGEST = TRUE
AS
  COPY INTO raw.products (product_id, product_name, category, unit_price)
  FROM @raw.products_stage
  FILE_FORMAT = raw.csv_format;

CREATE OR REPLACE PIPE raw.orders_pipe
  AUTO_INGEST = TRUE
AS
  COPY INTO raw.orders (order_id, customer_id, order_date, status, order_total)
  FROM @raw.orders_stage
  FILE_FORMAT = raw.csv_format;

CREATE OR REPLACE PIPE raw.order_items_pipe
  AUTO_INGEST = TRUE
AS
  COPY INTO raw.order_items (order_item_id, order_id, product_id, quantity, unit_price, line_total)
  FROM @raw.order_items_stage
  FILE_FORMAT = raw.csv_format;

-- After creation, grab the SQS ARN for each pipe:
--   SHOW PIPES;  (see "notification_channel" column)
-- and wire it into your S3 bucket's event notifications (see RUNBOOK.md).

-- Manual test load (skip auto-ingest, load whatever's in the stage right now):
-- COPY INTO raw.orders FROM @raw.orders_stage FILE_FORMAT = raw.csv_format;
