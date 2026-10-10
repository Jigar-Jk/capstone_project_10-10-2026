with batsmen as (

select
    batsman_id,
    batsman_name,
    batsman_dob,
    batsman_nationality,
    batting_hand,
    batsman_role,
    batsman_email,
    batsman_phone,
    batsman_icc_rating,
    contract_id,
    _loaded_at
from {{ref('stg_cleaned')}}
qualify row_number() over (
    partition by batsman_id
    order by _loaded_at desc
) = 1

),

bowlers as (

select
    bowler_id ,
    bowler_name ,
    bowler_nationality,
    bowling_style,
    bowler_icc_rating,
    _loaded_at
from {{ref('stg_cleaned')}}
qualify row_number() over (
    partition by bowler_id
    order by _loaded_at desc
) = 1

),

combined as (

select
   distinct batsman_id as player_id,
    batsman_name as player_name,
    batsman_dob as player_dob,
    batsman_nationality as player_nationality,
    batting_hand,
    batsman_role,
    bowling_style,
    batsman_email as player_email,
    batsman_phone as player_phone,
    batsman_icc_rating,
    bowler_icc_rating,
    contract_id,
from batsmen bat
full outer join bowlers bow
on bat.batsman_id=bow.bowler_id
)
select * from combined
