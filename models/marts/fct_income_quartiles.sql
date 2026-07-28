select
    applicant_id,
    annual_income,
    income_quartile,
    income_tier,
    city
from {{ ref('int_income_metrics') }}