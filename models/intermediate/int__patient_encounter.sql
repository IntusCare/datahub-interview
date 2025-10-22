{{ config(materialized="table") }}

{#
    INSTRUCTIONS FOR CANDIDATE:

    This model joins patient, encounter, and diagnosis data to create a comprehensive
    patient encounter view with associated diagnoses.

    TODO:
    1. Use multiple CTEs to structure your query logically
    2. Join staged patient, encounter, and diagnosis tables
    3. Calculate patient age at time of encounter using dob and encounter_date
    4. Create a flag for whether the encounter has a chronic condition diagnosis
       Chronic conditions (for this exercise): I10, E11.9, E11.65, J44.9, J44.1, I50.9
    5. Aggregate diagnosis information per encounter (count of diagnoses, primary diagnosis)
    6. Include patient demographics and encounter details

    Expected output columns:
    - encounter_id
    - patient_id
    - patient_first_name
    - patient_last_name
    - patient_age_at_encounter (calculated)
    - patient_sex
    - patient_phone_formatted
    - encounter_date
    - encounter_type
    - chief_complaint
    - primary_diagnosis_code (the ICD-10 code where is_primary = 1)
    - primary_diagnosis_description
    - total_diagnoses_count
    - has_chronic_condition (0 or 1)
    - created_at
#}

with
    patients as (
        select * from {{ ref("stg_patient") }}
    ),

    encounters as (
        select * from {{ ref("stg_encounter") }}
    ),

    diagnoses as (
        select * from {{ ref("stg_diagnosis") }}
    ),

    -- TODO: Modify this CTE to identify primary diagnoses
    primary_diagnoses as (
        select
            encounter_id,
            icd10_code as primary_diagnosis_code,
            diagnosis_description as primary_diagnosis_description
        from diagnoses
        -- TODO: Filter for primary diagnoses only
    ),

    -- TODO: Create a CTE to aggregate diagnosis counts per encounter
    -- diagnosis_counts as (

    -- ),

    -- TODO: Create a CTE to flag chronic conditions
    -- Output should include has_chronic_condition - 0 or 1
    -- chronic_conditions as (
    --     select distinct
    --         encounter_id,
    --         ...
    -- ),

    joined as (
        select
            e.encounter_id,
            p.patient_id,
            p.first_name as patient_first_name,
            p.last_name as patient_last_name,
            -- TODO: Calculate age at encounter (use julianday for SQLite)
            -- HINT: this is valid syntax: cast((julianday('now') - julianday(date2)) / 1.5 as integer)
            null as patient_age_at_encounter,
            p.sex as patient_sex,
            p.phone_formatted as patient_phone_formatted,
            e.encounter_date,
            e.encounter_type,
            e.chief_complaint,
            -- TODO: Include primary diagnosis information
            null as primary_diagnosis_code,
            null as primary_diagnosis_description,
            -- TODO: Include diagnosis count
            null as total_diagnoses_count,
            -- TODO: Include chronic condition flag (use COALESCE to handle NULLs as 0)
            -- HINT: this is valid syntax: 'coalesce(expression, default_value) as has_chronic_condition'
            0 as has_chronic_condition,
            current_timestamp as created_at
        from encounters e
        inner join patients p on e.patient_id = p.patient_id
        -- TODO: Add LEFT JOINs for primary_diagnoses, diagnosis_counts, and chronic_conditions
    )

select * from joined
