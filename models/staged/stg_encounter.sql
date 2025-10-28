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
        select
            encounter_id,
            patient_id,
            provider_id,
            encounter_date,
            -- In PostgreSQL , we can use INITCAP() which would convert directly to title case 
            -- In Python, we can use title() as well
            upper(substr(trim(encounter_type),1,1)) || lower(substr(trim(encounter_type),2)) as encounter_type,
            status,
            chief_complaint,
            current_timestamp as created_at
        from source
             where lower(status) = 'completed'
    )

select * from cleaned
