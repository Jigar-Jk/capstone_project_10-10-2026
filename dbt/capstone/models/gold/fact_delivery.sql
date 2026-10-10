with deliveries as (

select
    delivery_id,
    match_id,
    venue_id,
    batting_team_id,
    bowling_team_id,
    batsman_id,
    non_striker_id,
    bowler_id,
    drs_review_id,
    delivery_timestamp,
    innings_no,
    over_no,
    ball_in_over,
    runs_off_bat,
    extra_runs,
    total_runs,
    ball_speed_kmph,
    is_wicket,
    extra_type,
    dismissal_type,
    shot_type,
    shot_region
from {{ ref('stg_cleaned') }}

)

select * from deliveries