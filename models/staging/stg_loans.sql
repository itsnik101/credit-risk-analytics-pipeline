WITH source AS (

    SELECT *
    FROM {{ source('credit_risk','loans') }}

),

renamed AS (

    SELECT

        ROW_NUMBER() OVER (
            ORDER BY
                Age,
                Income,
                CreditScore,
                LoanAmount
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

    FROM source

)

SELECT *
FROM renamed;