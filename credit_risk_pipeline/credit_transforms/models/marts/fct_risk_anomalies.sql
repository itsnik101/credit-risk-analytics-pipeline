{{ config(materialized='table') }}

WITH clean_loans AS (
    SELECT * FROM {{ ref('stg_loans') }}
)

-- Anomaly Type 1: High quality applicants who got unexpectedly rejected
SELECT 
    'High-Credit Rejection' AS anomaly_type,
    credit_category,
    raw_credit_score,
    income,
    loan_to_income,
    employment_type,
    city,
    gender
FROM clean_loans
WHERE raw_credit_score > 700
  AND income > 59447
  AND loan_approved_flag = '0'

UNION ALL

-- Anomaly Type 2: Low quality applicants who got suspiciously approved
SELECT 
    'Low-Credit Approval' AS anomaly_type,
    credit_category,
    raw_credit_score,
    income,
    loan_to_income,
    employment_type,
    city,
    gender
FROM clean_loans
WHERE raw_credit_score < 600
  AND loan_to_income > 0.5
  AND loan_approved_flag = '1'