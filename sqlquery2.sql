USE creditrisk_db;
GO

-- =========================================================================
-- TABLE 1: INCOME QUANTILES ANALYSIS
-- =========================================================================

-- 1. Wipe out older iterations if they exist
IF OBJECT_ID('dbo.fct_income_quartiles', 'U') IS NOT NULL 
    DROP TABLE dbo.fct_income_quartiles;
GO

IF OBJECT_ID('tempdb..#temp_loans_q') IS NOT NULL
    DROP TABLE #temp_loans_q;
GO

-- 2. Pull clean metrics from your staging layer data
SELECT
    CAST(Income AS DECIMAL(10,2)) AS income,
    CAST(LoantoIncome AS DECIMAL(10,2)) AS loan_to_income,
    CAST(LoanApproved AS VARCHAR(5)) AS loan_approved_flag
INTO #temp_loans_q
FROM dbo.loans;
GO

-- 3. Run your exact NTILE window distribution logic
SELECT
    income_quartile,
    COUNT(*) AS total_applicants,
    CAST(AVG(income) AS DECIMAL(10,2)) AS avg_income,
    CAST(AVG(loan_to_income) AS DECIMAL(10,2)) AS avg_loan_to_income,
    CAST(ROUND(100.00 * SUM(CASE WHEN loan_approved_flag = '1' THEN 1 ELSE 0 END) / COUNT(*), 2) AS DECIMAL(10,2)) AS approval_rate
INTO dbo.fct_income_quartiles
FROM (
    SELECT *,
           NTILE(4) OVER (ORDER BY income) AS income_quartile -- Your exact distribution tool
    FROM #temp_loans_q
) AS t
GROUP BY income_quartile;
GO

DROP TABLE #temp_loans_q;
GO


-- =========================================================================
-- TABLE 2: RISK ANOMALIES AUDIT
-- =========================================================================

-- 1. Wipe out older iterations if they exist
IF OBJECT_ID('dbo.fct_risk_anomalies', 'U') IS NOT NULL 
    DROP TABLE dbo.fct_risk_anomalies;
GO

-- 2. Compile your advanced UNION audit logic[cite: 5]
SELECT 
    'High-Credit Rejection' AS anomaly_type,
    CreditScore AS raw_credit_score,
    CAST(Income AS DECIMAL(10,2)) AS income,
    CAST(LoantoIncome AS DECIMAL(10,2)) AS loan_to_income,
    COALESCE(EmploymentType, 'Unknown') AS employment_type,
    COALESCE(City, 'Unknown') AS city,
    COALESCE(Gender, 'Unknown') AS gender
INTO dbo.fct_risk_anomalies
FROM dbo.loans
WHERE CreditScore > 700
  AND Income > 59447
  AND LoanApproved = '0' -- High quality rejections[cite: 5]

UNION ALL

SELECT 
    'Low-Credit Approval' AS anomaly_type,
    CreditScore AS raw_credit_score,
    CAST(Income AS DECIMAL(10,2)) AS income,
    CAST(LoantoIncome AS DECIMAL(10,2)) AS loan_to_income,
    COALESCE(EmploymentType, 'Unknown') AS employment_type,
    COALESCE(City, 'Unknown') AS city,
    COALESCE(Gender, 'Unknown') AS gender
FROM dbo.loans
WHERE CreditScore < 600
  AND LoantoIncome > 0.5
  AND LoanApproved = '1'; -- Low quality approvals[cite: 5]
GO

-- =========================================================================
-- VERIFICATION VERDICTS
-- =========================================================================
SELECT 'Income Quartiles Data Sample:' AS [Table Title];
SELECT TOP 4 * FROM dbo.fct_income_quartiles ORDER BY income_quartile;

SELECT 'Risk Anomalies Data Sample:' AS [Table Title];
SELECT TOP 5 * FROM dbo.fct_risk_anomalies ORDER BY anomaly_type, raw_credit_score DESC;
GO