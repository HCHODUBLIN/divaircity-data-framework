-- stg_person.sql
-- Anonymised participant records
-- GDPR Note: No PII stored - only surrogate key and community/org membership

SELECT
    CAST(person_id AS INT)              AS person_id,
    CAST(community_id AS INT)           AS community_id,
    CAST(organisation_id AS INT)        AS organisation_id,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_persons') }}
WHERE person_id IS NOT NULL
