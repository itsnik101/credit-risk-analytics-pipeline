USE creditrisk_db;
GO

-- 1. Clean up any older reporting tables so we start fresh
IF OBJECT_ID('dbo.fct_risk_analytics', 'U') IS NOT NULL 
    DROP TABLE dbo.fct_risk_analytics;
GO

-- 2. Drop the temporary session table if it exists from a previous try
IF OBJECT_ID('tempdb..#temp_loans') IS NOT NULL
    DROP TABLE #temp_loans;
GO

-- 3. PHASE 1: Run your exact cleaning room logic using your real table name ('loans')
SELECT
    CAST(Income AS DECIMAL(10,2)) AS income,
    CAST(LoantoIncome AS DECIMAL(10,2)) AS loan_to_income,
    CAST(LoanApproved AS VARCHAR(5)) AS loan_approved_flag,
    COALESCE(EmploymentType, 'Unknown') AS employment_type,
    COALESCE(City, 'Unknown') AS city,
    COALESCE(Gender, 'Unknown') AS gender,
    CASE 
        WHEN CreditScore IS NULL THEN 'Data Missing'
        WHEN CreditScore < 550 THEN 'Poor'
        WHEN CreditScore < 650 THEN 'Fair'
        WHEN CreditScore < 750 THEN 'Average'
        WHEN CreditScore < 850 THEN 'Good'
        ELSE 'Exceptional'
    END AS credit_category
INTO #temp_loans
FROM dbo.loans; -- <--- Target your real table name here!
GO

-- 4. PHASE 2: Aggregate the final metrics seamlessly
SELECT 
    credit_category,
    employment_type,
    city,
    gender,
    COUNT(*) AS total_applicants,
    AVG(income) AS avg_income,
    AVG(loan_to_income) AS avg_loan_to_income,
    CAST(ROUND(100.00 * SUM(CASE WHEN loan_approved_flag = '1' THEN 1 ELSE 0 END) / COUNT(*), 2) AS DECIMAL(10,2)) AS approval_rate
INTO dbo.fct_risk_analytics
FROM #temp_loans
GROUP BY credit_category, employment_type, city, gender;
GO

-- 5. Clean up the temporary session table from memory
DROP TABLE #temp_loans;
GO

-- 6. Print the pristine final results table!
SELECT TOP 10 * FROM dbo.fct_risk_analytics;
GO