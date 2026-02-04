-- stg_admin_div_1.sql
-- City-level geographic boundary
-- Normalised dimension in the snowflake schema

SELECT
    CAST(city_id AS INT)                AS admin_div_1_id,
    TRIM(city_name)                     AS city_name,
    CAST(country_id AS INT)             AS country_id,
    CAST(population AS INT)             AS population,
    CAST(area AS FLOAT)                 AS area_km2,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_cities') }}
WHERE city_id IS NOT NULL
