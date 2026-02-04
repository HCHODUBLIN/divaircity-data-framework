-- stg_nbs_project.sql
-- Nature-Based Solution implementations

SELECT
    CAST(nbs_id AS INT)                 AS nbs_id,
    TRIM(nbs_name)                      AS nbs_name,
    TRIM(nbs_type)                      AS nbs_type,
    CAST(plan_id AS INT)                AS plan_id,
    CAST(location_id AS INT)            AS location_id,
    TRIM(description)                   AS description,
    CAST(project_area_m2 AS FLOAT)      AS project_area_m2,
    CAST(project_area_ha AS FLOAT)      AS project_area_ha,
    CAST(year_built AS INT)             AS year_built,
    CAST(installation_cost AS FLOAT)    AS installation_cost,
    CAST(maintenance_cost_annual AS FLOAT) AS maintenance_cost_annual,
    CAST(co2_sequestration_potential_kg AS FLOAT) AS co2_sequestration_potential_kg,
    CAST(normalised_cost_per_m2_co2 AS FLOAT) AS normalised_cost_per_m2_co2,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_nbs_projects') }}
WHERE nbs_id IS NOT NULL
