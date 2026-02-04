-- stg_plan.sql
-- Urban action plans from city partners

SELECT
    CAST(plan_id AS INT)                AS plan_id,
    TRIM(plan_name)                     AS plan_name,
    TRIM(plan_type)                     AS plan_type,
    CAST(organisation_id AS INT)        AS organisation_id,
    TRIM(scope)                         AS scope,
    CAST(admin_div_id AS INT)           AS admin_div_id,
    TRIM(focus)                         AS focus,
    CAST(timescale_years AS INT)        AS timescale_years,
    CAST(start_date AS DATE)            AS start_date,
    CAST(end_date AS DATE)              AS end_date,
    TRIM(status)                        AS status,
    COALESCE(CAST(is_divaircity_plan AS BOOLEAN), FALSE) AS is_divaircity_plan,
    CAST(target_area_ha AS FLOAT)       AS target_area_ha,
    COALESCE(CAST(has_citizen_science AS BOOLEAN), FALSE) AS has_citizen_science,
    TRIM(outcomes)                      AS outcomes,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_plans') }}
WHERE plan_id IS NOT NULL
