{{ config(materialized="ephemeral") }}

-- Raw diagnosis data from seed file
select
    diagnosis_id,
    encounter_id,
    icd10_code,
    diagnosis_description,
    diagnosis_date,
    is_primary
from {{ ref("diagnoses") }}
