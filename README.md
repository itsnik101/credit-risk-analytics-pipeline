# 💳 Enterprise Credit Risk Analytics & Transformation Pipeline

[![dbt](https://img.shields.io/badge/dbt-Core%20v1.8+-FF694B?style=for-the-badge&logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![SQL Server](https://img.shields.io/badge/MS%20SQL%20Server-2022-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/en-us/sql-server/)
[![Tableau](https://img.shields.io/badge/Tableau-Public-E97627?style=for-the-badge&logo=tableau&logoColor=white)](https://public.tableau.com/)
[![Git](https://img.shields.io/badge/Git-Version%20Control-F05032?style=for-the-badge&logo=git&logoColor=white)](https://git-scm.com/)

An end-to-end data engineering and analytics intelligence platform designed to ingest raw transactional credit applications, sanitize and feature-engineer underwriting metrics through a 3-tier **dbt** architecture, and expose actionable risk profiles via **Tableau Public**.

---

## 📌 Executive Summary

Modern credit underwriting requires reliable, deterministic data transformations to identify high-risk loan approvals and audit lending biases. This project establishes a production-grade data modeling pipeline that transforms raw unstructured credit records into materialized, audit-ready data marts.

### Key Highlights
* **3-Tier dbt Architecture:** Structured transformation flow (**Staging $\rightarrow$ Intermediate $\rightarrow$ Marts**) enforcing separation of concerns.
* **Deterministic Entity Resolution:** Generated unique surrogate keys using `ROW_NUMBER() OVER()` to resolve primary key deficiencies in raw source data.
* **Underwriting Anomaly Detection:** Automated flag logic to isolate policy edge cases (e.g., unexpected approvals for applicants with credit scores `< 550`).
* **Interactive Intelligence Platform:** Cross-filtered Tableau dashboards evaluating credit score distributions, leverage ceilings, and demographic approval fairness.

---

## 🏗️ System Architecture & Pipeline Design


```

┌────────────────┐       ┌────────────────┐       ┌────────────────┐       ┌────────────────┐
│   Raw Ingestion│  ───► │  Staging Layer │  ───► │  Intermediate  │  ───► │   Data Marts   │
│ (MS SQL Server)│       │  (stg_loans)   │       │ (Feature Eng.) │       │  (Materialized)│
└────────────────┘       └────────────────┘       └────────────────┘       └────────────────┘
│
▼
┌────────────────┐
│ Tableau Public │
│   Dashboards   │
└────────────────┘

```

---

## 📁 Repository Structure

```directory
credit-risk-analytics-pipeline/
├── models/
│   ├── staging/
│   │   ├── staging.yml           # Source definitions and column documentation
│   │   └── stg_loans.sql         # Data type casting and field renaming
│   ├── intermediate/
│   │   ├── intermediate.yml      # Model metadata
│   │   ├── int_risk_base.sql     # Credit tier assignments & anomaly detection
│   │   └── int_income_metrics.sql# Income quartile distributions (NTILE)
│   └── marts/
│       ├── marts.yml             # Data quality tests (unique, not_null)
│       ├── fct_risk_analytics.sql# Primary fact mart for downstream BI
│       ├── fct_income_quartiles.sql
│       ├── fct_risk_anomalies.sql
│       └── fct_demographic_fairness.sql
├── dbt_project.yml               # Global dbt configuration
├── profiles.yml.example          # Sample connection setup (credentials hidden)
├── .gitignore                    # Credential and artifact isolation rules
└── README.md                     # Project documentation

```

---

## 📐 Data Modeling & dbt Layers

* **Objective:** Ingest raw `dbo.loans` data, apply uniform naming conventions (snake_case), and explicitly cast columns into standard data types (`INT`, `NUMERIC`, `BIT`, `VARCHAR`).
* **Primary Key Workaround:** Engineered a deterministic surrogate primary key (`applicant_id`) using window functions to ensure schema integrity across upstream models.

```sql
SELECT
    ROW_NUMBER() OVER (
        ORDER BY Age, Income, CreditScore, LoanAmount
    ) AS applicant_id,
    CAST(Age AS INT) AS age,
    CAST(Gender AS VARCHAR(20)) AS gender,
    CAST(Income AS NUMERIC(18,2)) AS annual_income,
    CAST(CreditScore AS INT) AS credit_score,
    CAST(LoanAmount AS NUMERIC(18,2)) AS loan_amount,
    CAST(LoanApproved AS BIT) AS is_approved,
    CAST(LoantoIncome AS NUMERIC(10,4)) AS loan_to_income_ratio,
    CAST(YearsExperience AS INT) AS years_experience,
    CAST(EmploymentType AS VARCHAR(50)) AS employment_type,
    CAST(Education AS VARCHAR(50)) AS education_level,
    CAST(City AS VARCHAR(50)) AS city
FROM {{ source('credit_risk', 'loans') }}

```

* **Risk Categorization:** Maps credit scores to industry-standard risk tiers (`Excellent`, `Good`, `Fair`, `Poor`).
* **Anomaly Flagging:** Highlights underwriting policy violations:
* *High-Risk Unexpected Approval:* Credit Score `< 550` and `is_approved = 1`.
* *Low-Risk Unexpected Rejection:* Credit Score `≥ 750` and `is_approved = 0`.


* **Income Quartiles:** Utilizes `NTILE(4) OVER (ORDER BY annual_income)` to segment borrowers into economic cohorts (`Low`, `Lower-Middle`, `Upper-Middle`, `High`).

* Materializes final fact tables into SQL Server to drive BI performance and eliminate run-time analytical lag.
* Includes specialized tables: `fct_risk_analytics`, `fct_risk_anomalies`, and `fct_demographic_fairness`.

---

## 🧪 Data Quality & Testing Framework

Data quality constraints are enforced using dbt's automated testing suite inside YAML configuration blocks:

```yaml
version: 2

models:
  - name: stg_loans
    columns:
      - name: applicant_id
        data_tests:
          - unique
          - not_null
      - name: credit_score
        data_tests:
          - not_null

```

To run data quality checks locally:

```bash
dbt test

```

---

## 📊 Tableau BI Presentation Layer

The materialized marts power an executive decision intelligence platform in Tableau, structured across three key analytical views:

1. **Executive Portfolio Overview:** Global KPI cards (**Total Applications**, **Approval Rate**, **Avg Credit Score**, **Avg Loan Amount**, **Avg LTI Ratio**) combined with stacked approval bar charts across credit tiers.
2. **Underwriting Risk Scatter Analysis:** A 2D quadrant scatter plot mapping **Credit Score vs. Loan-to-Income Ratio** against regulatory benchmarks (**600 Subprime Floor**, **4.5 Max LTI Ceiling**).
3. **Risk Matrix Heatmap:** Cross-tabulation matrices analyzing approval velocity across employment types and risk profiles.

<img width="2879" height="1740" alt="Screenshot 2026-08-15 151929" src="https://github.com/user-attachments/assets/807e4c7c-7704-4997-88fe-0057b228e854" />
<img width="2879" height="1732" alt="Screenshot 2026-08-15 151941" src="https://github.com/user-attachments/assets/9ecbace4-cf26-42c2-a674-f7b6995356e1" />
<img width="2847" height="1690" alt="image" src="https://github.com/user-attachments/assets/7276b076-8d15-4ee8-96c3-9e50400c66b6" />




> 🔗 **[View Live Interactive Dashboard on Tableau Public](https://www.google.com/search?q=%23)**

---

## ⚙️ How to Run This Project Locally

### Prerequisites

* Python 3.10+
* MS SQL Server 2022+ & SSMS
* `dbt-sqlserver` adapter

### 1. Clone the Repository

```bash
git clone [https://github.com/YOUR_USERNAME/credit-risk-analytics-pipeline.git](https://github.com/YOUR_USERNAME/credit-risk-analytics-pipeline.git)
cd credit-risk-analytics-pipeline

```

### 2. Set Up Virtual Environment & Dependencies

```bash
python -m venv venv
venv\Scripts\activate
pip install dbt-sqlserver

```

### 3. Configure `profiles.yml`

Create a `profiles.yml` file in your `~/.dbt/` directory (or project root):

```yaml
credit_risk:
  outputs:
    dev:
      type: sqlserver
      driver: 'ODBC Driver 17 for SQL Server'
      server: localhost
      port: 1433
      database: creditrisk_db
      schema: dbo
      user: your_username
      password: your_password
  target: dev

```

### 4. Execute Pipeline & Run Tests

```bash
dbt debug    # Verify database connection
dbt run      # Build all models
dbt test     # Execute data quality suite

```

---

## 🛡️ Data Governance & Security

This repository strictly adheres to credential isolation best practices:

* Sensitive database connection strings and passwords are managed via `profiles.yml` and excluded from version control via `.gitignore`.
* Raw `.csv` data exports and compiled build logs (`target/`, `logs/`) are ignored to maintain a clean codebase.

---

## 👤 Author & Acknowledgments

* **Developer:** Nikhil Singh Rawat
* **Role Focus:** Analytics Engineering / Data Engineering



1. Replace `YOUR_USERNAME`, `your_username`, `Your Name`, and URLs with your actual information.
2. If you upload a screenshot of your Tableau dashboard or KPI cards to GitHub, you can add an image tag directly inside the Tableau section:
   ```markdown
   ![Dashboard Screenshot](./path/to/screenshot.png)

```
