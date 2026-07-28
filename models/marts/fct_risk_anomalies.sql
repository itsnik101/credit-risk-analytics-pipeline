select
    applicant_id,
    credit_score,
    loan_to_income_ratio,
    years_experience,
    is_approved,
    process_anomaly_flag as anomaly_flag
from {{ ref('int_risk_base') }}
where process_anomaly_flag != 'Standard Processing'