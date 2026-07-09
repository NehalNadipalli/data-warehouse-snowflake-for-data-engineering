# Data Warehouse with Snowflake for Data Engineering

This project demonstrates an end-to-end real-time data engineering pipeline using Snowflake, AWS, Apache NiFi, Snowpipe, Streams, and Tasks.

## Project Overview

The goal of this project is to build a modern cloud data warehouse pipeline that can ingest, process, and organize data for analytics.

The pipeline uses Apache NiFi for data movement, AWS for cloud storage, and Snowflake for data warehousing and transformation.

## Tools and Technologies

•⁠  ⁠Snowflake
•⁠  ⁠SQL
•⁠  ⁠AWS S3
•⁠  ⁠Apache NiFi
•⁠  ⁠Snowpipe
•⁠  ⁠Streams
•⁠  ⁠Tasks
•⁠  ⁠Data Warehousing
•⁠  ⁠ETL / ELT

## Key Features

•⁠  ⁠Real-time data ingestion
•⁠  ⁠Automated loading into Snowflake
•⁠  ⁠Cloud-based data storage using AWS S3
•⁠  ⁠Snowpipe-based continuous loading
•⁠  ⁠Change data capture using Snowflake Streams
•⁠  ⁠Automated transformations using Snowflake Tasks
•⁠  ⁠SQL-based data modeling

## Architecture

```text
Source Data
    ↓
Apache NiFi
    ↓
AWS S3
    ↓
Snowpipe
    ↓
Snowflake Staging Tables
    ↓
Streams and Tasks
    ↓
Final Analytics Tables
