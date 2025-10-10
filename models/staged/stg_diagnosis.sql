{{ config(materialized="table") }}

{#
    INSTRUCTIONS FOR CANDIDATE:

    This model should clean and standardize diagnosis data from the raw layer.

    TODO:
    1. Use CTEs to structure your query
    2. Keep dates as text (SQLite limitation)
    3. Standardize ICD-10 codes to uppercase and trim whitespace
    4. Cast is_primary to integer (SQLite uses 0/1 for booleans)
    5. Add created_at timestamp column with current_timestamp

    Expected output columns:
    - diagnosis_id
    - encounter_id
    - icd10_code (uppercase, trimmed)
    - diagnosis_description
    - diagnosis_date (keep as text)
    - is_primary (as integer: 0 or 1)
    - created_at
#}

with
    source as (
        select * from {{ ref("raw_diagnosis") }}
    ),

    cleaned as (
        -- TODO: Implement data cleaning logic here
        select
            diagnosis_id,
            encounter_id,
            -- TODO: Uppercase and trim ICD-10 code
            icd10_code,
            diagnosis_description,
            -- TODO: Keep as text (no casting needed)
            diagnosis_date,
            -- TODO: Ensure is_primary is integer type (handle 'true'/'false' strings)
            is_primary,
            -- TODO: Add created_at timestamp
            null as created_at
        from source
    )

select * from cleaned
