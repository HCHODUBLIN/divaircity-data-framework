-- stg_admin_div_2.sql
-- Borough-level geographic boundary
-- Normalised dimension in the snowflake schema

SELECT
    CAST(borough_id AS INT)             AS admin_div_2_id,
    TRIM(borough_name)                  AS borough_name,
    CAST(city_id AS INT)                AS admin_div_1_id,
    CAST(area AS FLOAT)                 AS area_km2,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_boroughs') }}
WHERE borough_id IS NOT NULL
