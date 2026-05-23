{{ config(materialized='ephemeral') }}  -- <--- CHANGE 'view' TO 'table' HERE!

WITH base_source AS (
    SELECT * FROM {{ source('dbo', 'loans') }}
)


SELECT
    -- 1. Explicitly fix column text data types into decimals for exact math
    CAST(Income AS DECIMAL(10,2)) AS income,
    CAST(LoanAmount AS DECIMAL(10,2)) AS loan_amount,
    CAST(LoantoIncome AS DECIMAL(10,2)) AS loan_to_income,
    
    -- 2. Standardize target flags as clear strings
    CAST(LoanApproved AS VARCHAR(5)) AS loan_approved_flag,
    
    -- 3. Safety Net: Replace blank or missing cells with 'Unknown'
    COALESCE(EmploymentType, 'Unknown') AS employment_type,
    COALESCE(City, 'Unknown') AS city,
    COALESCE(Gender, 'Unknown') AS gender,
    
    -- 4. Central Business Rule: Bucketing credit scores cleanly in one central place
    CASE 
        WHEN CreditScore IS NULL THEN 'Data Missing'
        WHEN CreditScore < 550 THEN 'Poor'
        WHEN CreditScore < 650 THEN 'Fair'
        WHEN CreditScore < 750 THEN 'Average'
        WHEN CreditScore < 850 THEN 'Good'
        ELSE 'Exceptional'
    END AS credit_category,
    
    CreditScore AS raw_credit_score
FROM base_source