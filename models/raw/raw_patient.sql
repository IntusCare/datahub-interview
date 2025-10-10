{{ config(materialized="ephemeral") }}

-- Raw patient data from seed file
select
    patient_id,
    first_name,
    last_name,
    dob,
    sex,
    phone,
    email,
    address_line_1,
    city,
    state,
    zip_code
from {{ ref("patients") }}
