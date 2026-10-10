with batting_team as (
    select
        batting_team_id as team_id,
        batting_team_name as team_name
    from {{ref('stg_cleaned')}}
),
bowling_team as (
    select
        bowling_team_id as team_id,
        bowling_team_name as team_name
    from {{ref('stg_cleaned')}}
),
combined as (
    select * from batting_team
    union
    select * from bowling_team
),
de as (
    select
        team_id,
        team_name
    from combined
    qualify row_number() over (
        partition by team_id
        order by team_name
    ) = 1

)
select * from de where team_id is not null
