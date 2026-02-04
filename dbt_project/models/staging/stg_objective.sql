-- stg_objective.sql
-- Plan objectives

SELECT
    CAST(objective_id AS INT)           AS objective_id,
    TRIM(objective_name)                AS objective_name,
    CAST(plan_id AS INT)                AS plan_id,
    TRIM(description)                   AS description,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_objectives') }}
WHERE objective_id IS NOT NULL
