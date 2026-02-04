-- stg_decision.sql
-- Decisions made at events

SELECT
    CAST(decision_id AS INT)            AS decision_id,
    CAST(plan_id AS INT)                AS plan_id,
    CAST(person_id AS INT)              AS person_id,
    CAST(organisation_id AS INT)        AS organisation_id,
    CAST(event_id AS INT)               AS event_id,
    TRIM(description)                   AS description,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_decisions') }}
WHERE decision_id IS NOT NULL
