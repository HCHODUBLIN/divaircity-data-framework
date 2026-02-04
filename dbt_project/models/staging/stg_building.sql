-- stg_building.sql
-- Buildings for NBS proximity analysis

SELECT
    CAST(building_id AS INT)            AS building_id,
    CAST(location_id AS INT)            AS location_id,
    TRIM(building_type)                 AS building_type,
    TRIM(building_use)                  AS building_use,
    CAST(year_built AS INT)             AS year_built,
    CAST(floor_area_m2 AS FLOAT)        AS floor_area_m2,
    CAST(nbs_proximity_pre AS FLOAT)    AS nbs_proximity_pre,
    CAST(nbs_proximity_post AS FLOAT)   AS nbs_proximity_post,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_buildings') }}
WHERE building_id IS NOT NULL
