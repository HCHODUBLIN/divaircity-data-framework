-- stg_event_participation.sql
-- Event participation records
-- Grain: one row per person per event

SELECT
    CAST(participation_id AS INT)       AS participation_id,
    CAST(event_id AS INT)               AS event_id,
    CAST(person_id AS INT)              AS person_id,
    CAST(organisation_id AS INT)        AS organisation_id,
    TRIM(role)                          AS role,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_event_participations') }}
WHERE participation_id IS NOT NULL
