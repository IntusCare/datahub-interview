{{ config(materialized="table") }}

{#
    INSTRUCTIONS FOR CANDIDATE:

    This model should clean and standardize patient data from the raw layer.

    TODO:
    1. Use CTEs to structure your query
    2. Clean phone numbers - remove formatting characters and standardize to 10 digits
    3. Use the format_phone_number() macro to format cleaned phone numbers as XXX-XXX-XXXX
    4. Handle NULL emails by replacing with 'unknown@example.com'
    5. Standardize state codes to uppercase
    6. Keep dates as text (SQLite limitation)
    7. Add a created_at timestamp column with current_timestamp
    8. Add a unique record identifier using patient_id

    Expected output columns:
    - patient_id (keep as-is)
    - first_name
    - last_name
    - dob (keep as text)
    - sex
    - phone_cleaned (10 digits only)
    - phone_formatted (using format_phone_number macro)
    - email (handle NULLs)
    - address_line_1
    - city
    - state (uppercase)
    - zip_code
    - created_at
#}

with
    source as (
        select * from {{ ref("raw_patient") }}
    ),

    cleaned as (
        -- TODO: Implement data cleaning logic here
        -- HINT: Use REPLACE() function to remove phone formatting characters
        -- HINT: Use COALESCE() for NULL handling
        select
            patient_id,
            first_name,
            last_name,
            dob,
            sex,
            replace(replace(replace(replace(phone, '(', ''), ')', ''), '-', ''), ' ', '') as phone_cleaned,
            coalesce(email, 'unknown@example.com') as email,
            address_line_1,
            city,
            upper(state) as state,
            zip_code,
            current_timestamp as created_at
        from source
    ),
    
    formatted as (
        select
            *,
            {{ format_phone_number('phone_cleaned') }} as phone_formatted
        from cleaned
    )

select * from formatted
