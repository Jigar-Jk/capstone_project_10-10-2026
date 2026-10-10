with drs_reviews as (
    select
        drs_review_id,
        drs_reviewed_by,
        drs_original_decision,
        drs_outcome
    from {{ref('stg_cleaned')}}
    where drs_review_id is not null
    qualify row_number() over (
        partition by drs_review_id
        order by _loaded_at desc
    ) = 1
)
select * from drs_reviews