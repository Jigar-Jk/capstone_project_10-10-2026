with source as (

    select * from {{ source('raw', 'raw_cricket') }}

),
cleaned  as (
    select
        upper(trim(delivery_id)) as delivery_id,
        try_to_timestamp(delivery_timestamp) as delivery_timestamp,
        try_to_number(innings_no) as innings_no,
        try_to_number(over_no) as over_no,
        try_to_number(ball_in_over) as ball_in_over,
        try_to_number(runs_off_bat) as runs_off_bat,
        case when upper(trim(extra_type)) in ('NULL','') then null else trim(extra_type) end as extra_type,
        try_to_number(extra_runs) as extra_runs,
        try_to_number(total_runs) as total_runs,
        upper(trim(is_wicket)) as is_wicket,
        case when upper(trim(dismissal_type)) in ('NULL','') then null else trim(dismissal_type) end as dismissal_type,
        try_to_number(ball_speed_kmph) as ball_speed_kmph,
        upper(trim(non_striker_id)) as non_striker_id,
        upper(trim(shot_type)) as shot_type,
        upper(trim(shot_region)) as shot_region,
        upper(trim(match_id)) as match_id,
        coalesce(try_to_date(match_date,'YYYY-MM-DD'), try_to_date(match_date,'DD-MM-YYYY'), try_to_date(match_date,'DD/MM/YYYY')) as match_date,
        upper(trim(match_format)) as match_format,
        upper(trim(tournament_name))as tournament_name,
        try_to_number(season) as season,
        upper(trim(match_stage)) as match_stage,
        upper(trim(toss_decision)) as toss_decision,
        upper(trim(venue_id)) as venue_id,
        upper(trim(venue_name)) as venue_name,
        upper(trim(venue_city)) as venue_city,
        upper(trim(venue_country)) as venue_country,
        upper(trim(batting_team_id)) as batting_team_id,
        upper(trim(batting_team_name)) as batting_team_name,
        upper(trim(bowling_team_id)) as bowling_team_id,
        upper(trim(bowling_team_name)) as bowling_team_name,
        upper(trim(batsman_id)) as batsman_id,
        upper(trim(batsman_name)) as batsman_name,
        coalesce(try_to_date(batsman_dob,'YYYY-MM-DD'), try_to_date(batsman_dob,'DD-MM-YYYY'), try_to_date(batsman_dob,'DD/MM/YYYY')) as batsman_dob,
        upper(trim(batsman_nationality)) as batsman_nationality,
        upper(trim(batting_hand)) as batting_hand,
        upper(trim(batsman_role)) as batsman_role,
        upper(trim(batsman_email)) as batsman_email,
        upper(trim(batsman_phone)) as batsman_phone,
        try_to_number(batsman_icc_rating) as batsman_icc_rating,
        upper(trim(bowler_id)) as bowler_id,
        upper(trim(bowler_name)) as bowler_name,
        upper(trim(bowler_nationality)) as bowler_nationality,
        upper(trim(bowling_style)) as bowling_style,
        try_to_number(bowler_icc_rating) as bowler_icc_rating,
        upper(trim(contract_id)) as contract_id,
        upper(trim(contract_grade)) as contract_grade,
        try_to_number(annual_retainer_usd, 18, 2) as annual_retainer_usd,
        upper(trim(contract_status)) as contract_status,
        upper(trim(drs_review_id)) as drs_review_id,
        upper(trim(drs_reviewed_by)) as drs_reviewed_by,
        upper(trim(drs_original_decision)) as drs_original_decision,
        upper(trim(drs_outcome)) as drs_outcome,
        _source_file,
        _loaded_at

    from source

),

deduplicated as (

    select *
    from cleaned
    qualify row_number() over (
        partition by delivery_id
        order by _loaded_at desc
    ) = 1

)

select * from deduplicated