-- sql/05_streams_tasks.sql
-- Streams track new rows landing in raw.orders / raw.order_items.
-- A Task runs every 5 minutes, consumes the streams, and merges
-- clean, deduplicated rows into the analytics layer.

USE DATABASE ecommerce_db;

CREATE OR REPLACE STREAM raw.orders_stream ON TABLE raw.orders;
CREATE OR REPLACE STREAM raw.order_items_stream ON TABLE raw.order_items;

-- Analytics tables (created here so the task below can reference them;
-- see 06_analytics_tables.sql for the full definitions with comments)
CREATE TABLE IF NOT EXISTS analytics.fact_orders (
  order_id      NUMBER PRIMARY KEY,
  customer_id   NUMBER,
  order_date    TIMESTAMP_NTZ,
  status        VARCHAR,
  order_total   NUMBER(10,2),
  updated_at    TIMESTAMP_NTZ
);

CREATE TABLE IF NOT EXISTS analytics.fact_order_items (
  order_item_id NUMBER PRIMARY KEY,
  order_id      NUMBER,
  product_id    NUMBER,
  quantity      NUMBER,
  unit_price    NUMBER(10,2),
  line_total    NUMBER(10,2),
  updated_at    TIMESTAMP_NTZ
);

CREATE OR REPLACE TASK raw.merge_orders_task
  WAREHOUSE = ecommerce_wh
  SCHEDULE = '5 MINUTE'
WHEN
  SYSTEM$STREAM_HAS_DATA('raw.orders_stream')
AS
  MERGE INTO analytics.fact_orders AS tgt
  USING (
    SELECT order_id, customer_id, order_date, status, order_total
    FROM raw.orders_stream
    WHERE METADATA$ACTION = 'INSERT'
  ) AS src
  ON tgt.order_id = src.order_id
  WHEN MATCHED THEN UPDATE SET
    customer_id = src.customer_id,
    order_date  = src.order_date,
    status      = src.status,
    order_total = src.order_total,
    updated_at  = CURRENT_TIMESTAMP()
  WHEN NOT MATCHED THEN INSERT (order_id, customer_id, order_date, status, order_total, updated_at)
  VALUES (src.order_id, src.customer_id, src.order_date, src.status, src.order_total, CURRENT_TIMESTAMP());

CREATE OR REPLACE TASK raw.merge_order_items_task
  WAREHOUSE = ecommerce_wh
  SCHEDULE = '5 MINUTE'
WHEN
  SYSTEM$STREAM_HAS_DATA('raw.order_items_stream')
AS
  MERGE INTO analytics.fact_order_items AS tgt
  USING (
    SELECT order_item_id, order_id, product_id, quantity, unit_price, line_total
    FROM raw.order_items_stream
    WHERE METADATA$ACTION = 'INSERT'
  ) AS src
  ON tgt.order_item_id = src.order_item_id
  WHEN MATCHED THEN UPDATE SET
    order_id   = src.order_id,
    product_id = src.product_id,
    quantity   = src.quantity,
    unit_price = src.unit_price,
    line_total = src.line_total,
    updated_at = CURRENT_TIMESTAMP()
  WHEN NOT MATCHED THEN INSERT (order_item_id, order_id, product_id, quantity, unit_price, line_total, updated_at)
  VALUES (src.order_item_id, src.order_id, src.product_id, src.quantity, src.unit_price, src.line_total, CURRENT_TIMESTAMP());

-- Tasks are created SUSPENDED by default -- turn them on:
ALTER TASK raw.merge_orders_task RESUME;
ALTER TASK raw.merge_order_items_task RESUME;

-- Check status any time:
-- SHOW TASKS;
-- SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY()) ORDER BY scheduled_time DESC LIMIT 20;
