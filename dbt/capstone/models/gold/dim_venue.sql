with venues as (
    select
        venue_id,
        venue_name,
        venue_city,
        venue_country
    from {{ ref('stg_cleaned') }}
    qualify row_number() over (
        partition by venue_id
        order by _loaded_at desc
    ) = 1

)
select * from venues