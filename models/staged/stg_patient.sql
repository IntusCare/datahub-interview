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
            -- TODO: Keep dob as text (no casting needed for SQLite)
            dob,
            sex,
            -- TODO: Clean phone number (remove all non-numeric characters)
            phone as phone_cleaned,
            -- TODO: Format phone using the format_phone_number macro
            phone as phone_formatted,
            -- TODO: Handle NULL emails
            email,
            address_line_1,
            city,
            -- TODO: Uppercase state
            state,
            zip_code,
            -- TODO: Add created_at timestamp
            null as created_at
        from source
    )

select * from cleaned
