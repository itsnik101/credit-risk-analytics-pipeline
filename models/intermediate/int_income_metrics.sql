with base_data as (
    select * from {{ ref('stg_loans') }}
),

ranked_income as (
    select
        *,
        ntile(4) over (order by annual_income) as income_quartile
    from base_data
)

select
    *,
    case 
        when income_quartile = 1 then 'Low Income'
        when income_quartile = 2 then 'Lower-Middle Income'
        when income_quartile = 3 then 'Upper-Middle Income'
        when income_quartile = 4 then 'High Income'
    end as income_tier
from ranked_income