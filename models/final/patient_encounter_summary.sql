{{ config(materialized="table") }}

{#
    INSTRUCTIONS FOR CANDIDATE:

    This model creates an analytics-ready patient summary aggregating encounter
    and diagnosis information at the patient level.

    TODO:
    1. Use multiple CTEs for clear, logical query structure
    2. Aggregate encounter data per patient
    3. Calculate various metrics per patient
    4. Include patient demographics

    Expected output columns:
    - patient_id
    - patient_first_name
    - patient_last_name
    - patient_sex
    - patient_phone_formatted
    - current_age (calculated from dob to current date)
    - total_encounters
    - first_encounter_date
    - most_recent_encounter_date
    - total_diagnoses
    - unique_diagnosis_codes
    - has_chronic_condition (1 if any encounter has chronic condition, else 0)
    - most_common_encounter_type
    - emergency_visit_count (count of 'Emergency' encounter types)
    - created_at
#}

with
    source as (
        select * from {{ ref("int__patient_encounter") }}
    ),

    patients as (
        select * from {{ ref("stg_patient") }}
    ),

    -- TODO: Modify this aggregation CTE for patient-level encounter metrics
    patient_encounters as (
        select
            patient_id,
            count(*) as total_encounters,
            min(encounter_date) as first_encounter_date,
            max(encounter_date) as most_recent_encounter_date,
            sum(total_diagnoses_count) as total_diagnoses,
            count(distinct primary_diagnosis_code) as unique_diagnosis_codes,
            max(has_chronic_condition) as has_chronic_condition,
             sum(case 
                when lower(encounter_type) = 'emergency' then 1
                else 0
                end)
             as emergency_visit_count
        from source
        group by patient_id
    ),

    -- TODO: Create CTE to find most common encounter type per patient
    -- HINT: Use window functions or subquery with GROUP BY and ORDER BY
    encounter_type_ranking as (
        select
            patient_id,
            encounter_type,
            count(*) as encounter_type_count,
            row_number() over (partition by patient_id order by count(*) desc) as rn
        from source
        group by patient_id, encounter_type
    ),

    most_common_type as (
        select
            patient_id,
            encounter_type as most_common_encounter_type
        from encounter_type_ranking
        where rn = 1
    ),

    final as (
        select
            p.patient_id,
            p.first_name as patient_first_name,
            p.last_name as patient_last_name,
            p.sex as patient_sex,
            p.phone_formatted as patient_phone_formatted,
            -- TODO: Calculate current age from dob
            -- HINT: this is valid syntax: julianday(date1) - julianday(date2)
            cast((julianday('now') - julianday(p.dob)) / 365 as integer) as current_age,
            -- TODO: Include aggregated metrics from patient_encounters CTE
            pe.total_encounters as total_encounters,
            pe.first_encounter_date as first_encounter_date,
            pe.most_recent_encounter_date as most_recent_encounter_date,
            pe.total_diagnoses as total_diagnoses,
            pe.unique_diagnosis_codes as unique_diagnosis_codes,
            pe.has_chronic_condition as has_chronic_condition,
            -- TODO: Include most common encounter type
            mct.most_common_encounter_type as most_common_encounter_type,
            pe.emergency_visit_count as emergency_visit_count,
            current_timestamp as created_at
        from patients p
        left join patient_encounters pe on p.patient_id = pe.patient_id
        left join most_common_type mct on  p.patient_id = mct.patient_id
        
    )

select * from final
