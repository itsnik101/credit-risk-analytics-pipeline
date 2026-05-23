# End-to-End Credit Risk Architecture & Compliance Analytics

An enterprise-grade ELT data pipeline that ingests raw credit applicant data, executes dimensional modeling transformations via dbt, audits system data anomalies, and exposes interactive risk metrics through an executive Tableau dashboard.

##  Live Deliverables
* **Interactive BI Interface:** [Live Tableau Public Dashboard](PASTE_YOUR_TABLEAU_PUBLIC_URL_HERE)
* **Production Codebase:** [GitHub Repository](https://github.com/itsnik101/credit-risk-analytics-pipeline)

---

## System Architecture & Data Pipeline
1. **Extraction & Ingestion:** Raw demographic and credit tracking assets ingested via automated Python processing.
2. **Data Warehousing:** Transformed raw transactional schemas into operational staging environments within an enterprise SQL Server database instance.
3. **Data Build Tool (dbt) Transformation:** Built modular staging models and dimension/fact reporting layers (`marts`), implementing standardized configurations for testing and production deployment.
4. **Business Intelligence (BI) Layer:** Engineered a multi-layered interactive visualization system using parameters and conditional actions to track structural default exposure.

---

##  Relational Data Modeling & Marts Layer

The dbt architecture separates data transformation into clean, isolated analytical scopes:

### 1. `fct_risk_analytics`
Tracks baseline cross-demographic performance metrics segmented by market geographies and employment profiles.
* **Core Metrics:** `total_applicants`, `avg_income`, `avg_loan_to_income`, `approval_rate`
* **Analytical Dimensions:** `credit_category`, `employment_type`, `city`, `gender`

### 2. `fct_income_quartiles`
A macro economic leverage model categorizing the applicant pool into 4 distinct financial tiers via statistical bucket sizing.
* **Key Finding:** Successfully validated that macro debt burdens heavily scale inversely with consumer wealth, illustrating clear risk concentration in early-tier borrowing metrics.

### 3. `fct_risk_anomalies`
An operational system audit grid that isolates algorithmic engine exceptions for internal data compliance teams:
* **High-Credit Rejections:** Audits prime tier applicants (Credit Score > 700) flagged with automatic system rejections. 
* **Low-Credit Approvals:** Flags high-risk subprime applicants (Credit Score < 600) who bypassed core lending rules.

---

## Technical Skills Demonstrated
* **Data Transformation:** dbt (Data Build Tool), SQL Server Data Modeling, CTE Complex Expressions, Window Functions
* **Languages & Scripting:** Python (Pandas Ingestion), Advanced SQL T-SQL Dialect
* **Business Intelligence:** Tableau Dashboard Design, Dual-Axis Financial Mapping, Action Filters, Parameters
* **Version Control:** Git, Distributed Workspace Management Architecture