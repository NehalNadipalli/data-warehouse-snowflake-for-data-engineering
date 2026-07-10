-- sql/02_staging_tables.sql
-- Raw landing tables. Column types are intentionally loose (VARCHAR/NUMBER)
-- since this is the "as-loaded" layer -- cleanup happens downstream.

USE DATABASE ecommerce_db;
USE SCHEMA raw;

CREATE OR REPLACE TABLE raw.customers (
  customer_id   NUMBER,
  first_name    VARCHAR,
  last_name     VARCHAR,
  email         VARCHAR,
  city          VARCHAR,
  state         VARCHAR,
  signup_date   DATE,
  _loaded_at    TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE raw.products (
  product_id    NUMBER,
  product_name  VARCHAR,
  category      VARCHAR,
  unit_price    NUMBER(10,2),
  _loaded_at    TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE raw.orders (
  order_id      NUMBER,
  customer_id   NUMBER,
  order_date    TIMESTAMP_NTZ,
  status        VARCHAR,
  order_total   NUMBER(10,2),
  _loaded_at    TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE raw.order_items (
  order_item_id NUMBER,
  order_id      NUMBER,
  product_id    NUMBER,
  quantity      NUMBER,
  unit_price    NUMBER(10,2),
  line_total    NUMBER(10,2),
  _loaded_at    TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
