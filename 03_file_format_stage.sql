-- sql/03_file_format_stage.sql
-- Points Snowflake at the S3 bucket that NiFi writes into.
-- Replace <BUCKET_NAME>, <AWS_ACCOUNT_ID>, and <IAM_ROLE_NAME> with your own.
-- Full storage-integration setup (trust policy, external ID) is documented at:
-- https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration

USE DATABASE ecommerce_db;
USE SCHEMA raw;

CREATE OR REPLACE FILE FORMAT raw.csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('', 'NULL')
  EMPTY_FIELD_AS_NULL = TRUE;

CREATE OR REPLACE STORAGE INTEGRATION ecommerce_s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<AWS_ACCOUNT_ID>:role/<IAM_ROLE_NAME>'
  STORAGE_ALLOWED_LOCATIONS = ('s3://<BUCKET_NAME>/customers/',
                                's3://<BUCKET_NAME>/products/',
                                's3://<BUCKET_NAME>/orders/',
                                's3://<BUCKET_NAME>/order_items/');

-- After creating the integration, run DESC INTEGRATION ecommerce_s3_int;
-- and use the returned STORAGE_AWS_IAM_USER_ARN / STORAGE_AWS_EXTERNAL_ID
-- to finish trusting Snowflake in your IAM role's trust policy.

CREATE OR REPLACE STAGE raw.customers_stage
  URL = 's3://<BUCKET_NAME>/customers/'
  STORAGE_INTEGRATION = ecommerce_s3_int
  FILE_FORMAT = raw.csv_format;

CREATE OR REPLACE STAGE raw.products_stage
  URL = 's3://<BUCKET_NAME>/products/'
  STORAGE_INTEGRATION = ecommerce_s3_int
  FILE_FORMAT = raw.csv_format;

CREATE OR REPLACE STAGE raw.orders_stage
  URL = 's3://<BUCKET_NAME>/orders/'
  STORAGE_INTEGRATION = ecommerce_s3_int
  FILE_FORMAT = raw.csv_format;

CREATE OR REPLACE STAGE raw.order_items_stage
  URL = 's3://<BUCKET_NAME>/order_items/'
  STORAGE_INTEGRATION = ecommerce_s3_int
  FILE_FORMAT = raw.csv_format;
