with contracts as (
    select
        contract_id,
        contract_grade,
        annual_retainer_usd,
        contract_status,
        case when row_number() over (
        partition by contract_id
        order by _loaded_at desc)=1 then 1 else 0  end as is_active
    from {{ref('stg_cleaned')}}
)
select * from contracts