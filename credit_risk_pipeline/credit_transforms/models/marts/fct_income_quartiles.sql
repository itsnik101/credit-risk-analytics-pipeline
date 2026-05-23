{{ config(materialized='table') }}

WITH clean_loans AS (
    SELECT * FROM {{ ref('stg_loans') }}
),

quartile_assignments AS (
    SELECT
        income,
        loan_to_income,
        loan_approved_flag,
        credit_category,
        -- Your exact NTILE logic to split applicants into 4 even income tiers
        NTILE(4) OVER (ORDER BY income) AS income_quartile
    FROM clean_loans
)

SELECT
    income_quartile,
    COUNT(*) AS total_applicants,
    CAST(AVG(income) AS DECIMAL(10,2)) AS avg_income,
    CAST(AVG(loan_to_income) AS DECIMAL(10,2)) AS avg_loan_to_income,
    -- Your exact percentage calculation logic from your sheets
    CAST(ROUND(100.00 * SUM(CASE WHEN loan_approved_flag = '1' THEN 1 ELSE 0 END) / COUNT(*), 2) AS DECIMAL(10,2)) AS approval_rate
FROM quartile_assignments
GROUP BY income_quartile