-- stg_geography.sql
-- Staging models for the geospatial boundary hierarchy
-- Pattern: 1:1 source mirror with clean naming and type casting
-- Source: city administration data (Bronze)
-- Target: Silver schema

-- ===================
-- COUNTRY
-- ===================

{{
    config(
        alias='stg_country'
    )
}}

-- stg_country: clean and standardise country reference data

SELECT
    CAST(country_id AS INT)             AS country_id,
    TRIM(UPPER(country_name))           AS country_name,
    CAST(population AS INT)             AS population,
    CAST(area AS FLOAT)                 AS area_km2,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_countries') }}
WHERE country_id IS NOT NULL
