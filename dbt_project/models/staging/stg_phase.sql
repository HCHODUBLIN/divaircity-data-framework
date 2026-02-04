-- stg_phase.sql
-- Co-creation phases within plans

SELECT
    CAST(phase_id AS INT)               AS phase_id,
    CAST(plan_id AS INT)                AS plan_id,
    TRIM(phase_name)                    AS phase_name,
    CAST(phase_order AS INT)            AS phase_order,
    TRIM(building_type)                 AS building_type,
    CAST(total_households AS INT)       AS total_households,
    TRIM(description)                   AS description,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_phases') }}
WHERE phase_id IS NOT NULL
