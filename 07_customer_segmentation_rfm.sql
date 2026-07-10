-- 07_customer_segmentation_rfm.sql
--
-- NEW addition on top of the base pipeline: RFM (Recency, Frequency,
-- Monetary) customer segmentation, computed from the curated fact/dim
-- tables. This turns the raw pipeline into something with an actual
-- business use case -- identifying loyal, at-risk, and lapsed customers.
--
-- Rebuilt as a scheduled task so it always reflects the latest merged
-- order data, no manual re-run required.

USE DATABASE ecommerce_db;
USE SCHEMA analytics;

CREATE OR REPLACE TABLE analytics.customer_rfm AS
WITH order_stats AS (
  SELECT
    customer_id,
    MAX(order_date)                       AS last_order_date,
    COUNT(DISTINCT order_id)              AS order_count,
    SUM(order_total)                      AS total_spent
  FROM analytics.fact_orders
  WHERE status = 'completed'
  GROUP BY customer_id
),
scored AS (
  SELECT
    customer_id,
    last_order_date,
    order_count,
    total_spent,
    DATEDIFF('day', last_order_date, CURRENT_DATE()) AS recency_days,
    NTILE(4) OVER (ORDER BY DATEDIFF('day', last_order_date, CURRENT_DATE()) DESC) AS recency_score,
    NTILE(4) OVER (ORDER BY order_count ASC)  AS frequency_score,
    NTILE(4) OVER (ORDER BY total_spent ASC)  AS monetary_score
  FROM order_stats
)
SELECT
  s.customer_id,
  c.full_name,
  c.city,
  c.state,
  s.last_order_date,
  s.recency_days,
  s.order_count,
  s.total_spent,
  s.recency_score,
  s.frequency_score,
  s.monetary_score,
  (s.recency_score + s.frequency_score + s.monetary_score) AS rfm_total,
  CASE
    WHEN s.recency_score >= 3 AND s.frequency_score >= 3 AND s.monetary_score >= 3 THEN 'Champion'
    WHEN s.recency_score >= 3 AND s.frequency_score >= 2                          THEN 'Loyal'
    WHEN s.recency_score <= 2 AND s.frequency_score >= 3                          THEN 'At risk'
    WHEN s.recency_score <= 1 AND s.frequency_score <= 1                          THEN 'Lapsed'
    ELSE 'Regular'
  END AS segment
FROM scored s
JOIN analytics.dim_customers c ON c.customer_id = s.customer_id;

-- Quick check: segment distribution
-- SELECT segment, COUNT(*) AS customers, ROUND(AVG(total_spent),2) AS avg_spend
-- FROM analytics.customer_rfm GROUP BY segment ORDER BY avg_spend DESC;

-- Keep this table current as new orders flow in. Since this is a full
-- rebuild (not an incremental merge), a simple scheduled task is enough
-- at this data volume.
CREATE OR REPLACE TASK analytics.rebuild_customer_rfm_task
  WAREHOUSE = ecommerce_wh
  SCHEDULE = '30 MINUTE'
AS
  CREATE OR REPLACE TABLE analytics.customer_rfm AS
  WITH order_stats AS (
    SELECT customer_id, MAX(order_date) AS last_order_date,
           COUNT(DISTINCT order_id) AS order_count, SUM(order_total) AS total_spent
    FROM analytics.fact_orders WHERE status = 'completed' GROUP BY customer_id
  ),
  scored AS (
    SELECT customer_id, last_order_date, order_count, total_spent,
           DATEDIFF('day', last_order_date, CURRENT_DATE()) AS recency_days,
           NTILE(4) OVER (ORDER BY DATEDIFF('day', last_order_date, CURRENT_DATE()) DESC) AS recency_score,
           NTILE(4) OVER (ORDER BY order_count ASC)  AS frequency_score,
           NTILE(4) OVER (ORDER BY total_spent ASC)  AS monetary_score
    FROM order_stats
  )
  SELECT s.*, c.full_name, c.city, c.state,
    (s.recency_score + s.frequency_score + s.monetary_score) AS rfm_total,
    CASE
      WHEN s.recency_score >= 3 AND s.frequency_score >= 3 AND s.monetary_score >= 3 THEN 'Champion'
      WHEN s.recency_score >= 3 AND s.frequency_score >= 2                          THEN 'Loyal'
      WHEN s.recency_score <= 2 AND s.frequency_score >= 3                          THEN 'At risk'
      WHEN s.recency_score <= 1 AND s.frequency_score <= 1                          THEN 'Lapsed'
      ELSE 'Regular'
    END AS segment
  FROM scored s
  JOIN analytics.dim_customers c ON c.customer_id = s.customer_id;

ALTER TASK analytics.rebuild_customer_rfm_task RESUME;
