with source as (

    select * from {{ source('raw', 'raw_banking') }}

),

cleaned as (

    select
        -- transaction
        trim(transaction_id)                                   as transaction_id,
        coalesce(
            try_to_date(trim(transaction_date), 'YYYY-MM-DD'),
            try_to_date(trim(transaction_date), 'DD-MM-YYYY')
        )                                                      as transaction_date,
        upper(trim(transaction_type))                          as transaction_type,
        try_to_number(transaction_amount, 18, 2)               as transaction_amount,
        upper(trim(payment_method))                            as payment_method,
        upper(trim(payment_channel))                           as payment_channel,
        upper(trim(transaction_status))                        as transaction_status,
        coalesce(try_to_boolean(trim(is_fraud)), false)        as is_fraud,

        -- customer
        trim(customer_id)                                      as customer_id,
        trim(customer_name)                                    as customer_name,
        coalesce(upper(trim(customer_segment)), 'UNKNOWN')     as customer_segment,
        try_to_number(credit_score)                            as credit_score,

        -- branch
        trim(branch_id)                                        as branch_id,
        trim(branch_name)                                      as branch_name,

        -- loan
        nullif(trim(loan_id), '')                              as loan_id,
        upper(trim(loan_type))                                 as loan_type,
        try_to_number(loan_amount, 18, 2)                      as loan_amount,
        try_to_number(interest_rate, 5, 2)                     as interest_rate,
        try_to_number(tenure_months)                           as tenure_months,
        upper(trim(loan_status))                               as loan_status,
        try_to_date(trim(loan_issue_date), 'YYYY-MM-DD')       as loan_issue_date,

        -- complaint
        nullif(trim(complaint_id), '')                         as complaint_id,
        upper(trim(complaint_category))                        as complaint_category,
        upper(trim(complaint_priority))                        as complaint_priority,
        upper(trim(complaint_status))                          as complaint_status,
        try_to_date(trim(complaint_date), 'YYYY-MM-DD')        as complaint_date,

        -- audit
        _source_file,
        _loaded_at

    from source

),

deduplicated as (

    select *
    from cleaned
    qualify row_number() over (
        partition by transaction_id
        order by _loaded_at desc
    ) = 1

)

select * from deduplicated