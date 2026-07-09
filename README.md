# ❄️ Data Warehouse with Snowflake for Data Engineering

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Apache NiFi](https://img.shields.io/badge/Apache%20NiFi-728E9B?style=for-the-badge&logo=apache&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=postgresql&logoColor=white)

An end-to-end real-time data engineering pipeline using *Apache NiFi, **AWS S3, **Snowflake, **Snowpipe, **Streams, and **Tasks*.

---

## 📌 Overview

This project demonstrates a modern cloud data warehouse pipeline that ingests, stores, processes, and transforms data for analytics.

Apache NiFi is used for data ingestion, AWS S3 works as the cloud landing zone, and Snowflake handles automated loading, change data capture, and SQL-based transformation.

---

## 🏗️ Architecture

![Pipeline Architecture](images/architecture.png)

### Pipeline Flow

1.⁠ ⁠Source data is ingested using Apache NiFi.
2.⁠ ⁠Apache NiFi sends the data to AWS S3.
3.⁠ ⁠Snowpipe continuously loads new files from S3 into Snowflake staging tables.
4.⁠ ⁠Snowflake Streams track new and changed data.
5.⁠ ⁠Snowflake Tasks run automated SQL transformations.
6.⁠ ⁠Final analytics tables are created for reporting and analysis.

---

## 🛠️ Tools and Technologies

•⁠  ⁠Snowflake
•⁠  ⁠AWS S3
•⁠  ⁠Apache NiFi
•⁠  ⁠Snowpipe
•⁠  ⁠Snowflake Streams
•⁠  ⁠Snowflake Tasks
•⁠  ⁠SQL
•⁠  ⁠Data Warehousing
•⁠  ⁠ETL / ELT

---

## ✨ Key Features

•⁠  ⁠Real-time data ingestion
•⁠  ⁠Automated loading from AWS S3 to Snowflake
•⁠  ⁠Change Data Capture using Streams
•⁠  ⁠Scheduled SQL transformations using Tasks
•⁠  ⁠Cloud-based data warehouse architecture
•⁠  ⁠Analytics-ready final tables

---

## 📂 Repository Structure

⁠ text
data-warehouse-snowflake-for-data-engineering/
│
├── images/
│   └── architecture.png
│
├── SQL Code/
│   └── Snowflake SQL scripts
│
├── Real-Time Data Streaming using Apache Nifi, AWS, Snowpipe, Stream & Task/
│   └── Pipeline files and documentation
│
├── README.md
├── LICENSE
└── .gitignore
 ⁠

---

## 🚀 Getting Started

### Prerequisites

•⁠  ⁠Snowflake account
•⁠  ⁠AWS account with S3 bucket
•⁠  ⁠Apache NiFi installed
•⁠  ⁠Basic SQL knowledge

### Steps

1.⁠ ⁠Create an AWS S3 bucket for raw data storage.
2.⁠ ⁠Configure Apache NiFi to ingest source data and send it to S3.
3.⁠ ⁠Create Snowflake database, schema, file format, and external stage.
4.⁠ ⁠Configure Snowpipe for continuous data loading.
5.⁠ ⁠Create Streams to capture changes.
6.⁠ ⁠Create Tasks to automate transformations.
7.⁠ ⁠Query final analytics tables in Snowflake.

---

## 📊 Project Workflow

⁠ text
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
 ⁠

---

## 🧠 Skills Demonstrated

•⁠  ⁠Data Engineering
•⁠  ⁠ETL Pipeline Development
•⁠  ⁠Cloud Data Warehousing
•⁠  ⁠Snowflake SQL
•⁠  ⁠Real-Time Data Ingestion
•⁠  ⁠AWS S3 Integration
•⁠  ⁠Change Data Capture
•⁠  ⁠Pipeline Automation

---

## 🏗️ Architecture

![Pipeline Architecture](images/architecture.png)

---

## 📸 Project Screenshots

### Apache NiFi Flow
Coming Soon

### Snowflake Query Results
Coming Soon

### AWS S3 Bucket
Coming Soon

---

## 🔮 Future Improvements

•⁠  ⁠Add dbt for SQL transformation management
•⁠  ⁠Add Airflow for orchestration
•⁠  ⁠Add dashboard using Power BI or Streamlit
•⁠  ⁠Add data quality checks
•⁠  ⁠Add CI/CD pipeline for SQL deployment
•⁠  ⁠Add sample dataset so others can run the project

---

## 👨‍💻 Author

*Nehal Nadipalli*

GitHub: [NehalNadipalli](https://github.com/NehalNadipalli)
