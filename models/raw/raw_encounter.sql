{{ config(materialized="ephemeral") }}

-- Raw encounter data from seed file
select
    encounter_id,
    patient_id,
    provider_id,
    encounter_date,
    encounter_type,
    status,
    chief_complaint
from {{ ref("encounters") }}
