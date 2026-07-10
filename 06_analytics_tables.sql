-- sql/06_analytics_tables.sql
-- dim_customers / dim_products are small reference tables -- simple full
-- refresh is fine at this scale, no stream/task needed.
-- (fact_orders / fact_order_items are created in 05_streams_tasks.sql,
-- since the merge task needs them to exist first.)

USE DATABASE ecommerce_db;
USE SCHEMA analytics;

CREATE OR REPLACE TABLE analytics.dim_customers AS
SELECT
  customer_id,
  first_name,
  last_name,
  first_name || ' ' || last_name AS full_name,
  email,
  city,
  state,
  signup_date
FROM raw.customers;

CREATE OR REPLACE TABLE analytics.dim_products AS
SELECT
  product_id,
  product_name,
  category,
  unit_price
FROM raw.products;

-- A convenience view joining everything for ad-hoc analysis / BI tools.
CREATE OR REPLACE VIEW analytics.vw_order_details AS
SELECT
  o.order_id,
  o.order_date,
  o.status,
  c.customer_id,
  c.full_name,
  c.city,
  c.state,
  oi.product_id,
  p.product_name,
  p.category,
  oi.quantity,
  oi.unit_price,
  oi.line_total
FROM analytics.fact_orders o
JOIN analytics.dim_customers c ON o.customer_id = c.customer_id
JOIN analytics.fact_order_items oi ON o.order_id = oi.order_id
JOIN analytics.dim_products p ON oi.product_id = p.product_id;
