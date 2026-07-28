with base_data as (
    select * from {{ ref('stg_loans') }}
)

select
    *,
    case 
        when credit_score >= 750 then 'Excellent'
        when credit_score >= 650 then 'Good'
        when credit_score >= 550 then 'Fair'
        else 'Poor'
    end as credit_tier,
    case
        when credit_score < 550 and is_approved = 1 then 'High-Risk Unexpected Approval'
        when credit_score >= 750 and is_approved = 0 then 'Low-Risk Unexpected Rejection'
        else 'Standard Processing'
    end as process_anomaly_flag
from base_data