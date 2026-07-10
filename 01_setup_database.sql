-- 01_setup_database.sql
-- Run as ACCOUNTADMIN or a role with CREATE DATABASE / WAREHOUSE privileges.

CREATE WAREHOUSE IF NOT EXISTS ecommerce_wh
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

CREATE DATABASE IF NOT EXISTS ecommerce_db;

CREATE SCHEMA IF NOT EXISTS ecommerce_db.raw;        -- staging / landing tables
CREATE SCHEMA IF NOT EXISTS ecommerce_db.analytics;  -- curated, query-ready tables

USE WAREHOUSE ecommerce_wh;
USE DATABASE ecommerce_db;
