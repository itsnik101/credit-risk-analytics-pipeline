select
    applicant_id,
    age,
    annual_income,
    credit_score,
    credit_tier,
    loan_amount,
    loan_to_income_ratio,
    years_experience,
    employment_type,
    is_approved
from {{ ref('int_risk_base') }}