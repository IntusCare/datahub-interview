{{ config(materialized="table") }}

{#
    INSTRUCTIONS FOR CANDIDATE:

    This model should clean and standardize encounter data from the raw layer.

    TODO:
    1. Use CTEs to structure your query
    2. Keep dates as text (SQLite limitation)
    3. Standardize encounter_type values (trim whitespace, title case)
    4. Filter out any encounters with status != 'completed'
    5. Add created_at timestamp column with current_timestamp

    Expected output columns:
    - encounter_id
    - patient_id
    - provider_id
    - encounter_date (keep as text)
    - encounter_type (standardized)
    - status
    - chief_complaint
    - created_at
#}

with
    source as (
        select * from {{ ref("raw_encounter") }}
    ),

    cleaned as (
        -- TODO: Implement data cleaning and filtering logic here
        select
            encounter_id,
            patient_id,
            provider_id,
            -- TODO: Keep as text (no casting needed)
            encounter_date,
            -- TODO: Standardize encounter_type (trim whitespace)
            encounter_type,
            status,
            chief_complaint,
            -- TODO: Add created_at timestamp
            null as created_at
        from source
        -- TODO: Add WHERE clause to filter for completed encounters only
    )

select * from cleaned
