{{ config(materialized='table') }}

WITH clean_loans AS (
    -- Reads directly from the clean staging view we just built above
    SELECT * FROM {{ ref('stg_loans') }}
)

SELECT 
    credit_category,
    employment_type,
    city,
    gender,
    
    -- Compute final metrics summary metrics
    COUNT(*) AS total_applicants,
    AVG(income) AS avg_income,
    AVG(loan_amount) AS avg_loan_amount,
    AVG(loan_to_income) AS avg_loan_to_income,
    
    -- Calculate exact loan approval rates by demographic split
    CAST(ROUND(100.00 * SUM(CASE WHEN loan_approved_flag = '1' THEN 1 ELSE 0 END) / COUNT(*), 2) AS DECIMAL(10,2)) AS approval_rate
FROM clean_loans
GROUP BY credit_category, employment_type, city, gender