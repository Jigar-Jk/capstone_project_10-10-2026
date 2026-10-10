with matches as (
    select
        match_id,
        match_date,
        match_format,
        tournament_name,
        season,
        match_stage,
        toss_decision
    from {{ref('stg_cleaned')}}
    qualify row_number() over (
        partition by match_id
        order by _loaded_at desc
    ) = 1
)
select * from matches
