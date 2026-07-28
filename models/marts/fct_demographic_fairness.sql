with base as (
    select * from {{ ref('stg_loans') }}
),

aggregated as (
    select
        gender,
        education_level,
        count(applicant_id) as total_applications,
        sum(case when is_approved = 1 then 1 else 0 end) as total_approvals
    from base
    group by gender, education_level
)

select
    gender,
    education_level,
    total_applications,
    total_approvals,
    cast(total_approvals as numeric(18,2)) / nullif(total_applications, 0) as approval_rate
from aggregated