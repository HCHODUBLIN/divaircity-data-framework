-- stg_event.sql
-- Co-creation events (workshops, meetings, educational)

SELECT
    CAST(event_id AS INT)               AS event_id,
    TRIM(event_type)                    AS event_type,
    CAST(neighbourhood_id AS INT)       AS admin_div_3_id,
    CAST(plan_id AS INT)                AS plan_id,
    CAST(phase_id AS INT)               AS phase_id,
    CAST(tool_id AS INT)                AS tool_id,
    CAST(event_date AS DATE)            AS event_date,
    CAST(event_time AS TIME)            AS event_time,
    TRIM(event_location)                AS event_location,
    TRIM(description)                   AS description,
    CAST(total_participants AS INT)     AS total_participants,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_events') }}
WHERE event_id IS NOT NULL
