-- int_sensor_with_geography.sql
-- Intermediate model: enrich sensors with full geographic context
-- Resolves the snowflake schema hierarchy into a single reference
-- Used by marts layer to avoid repeated multi-level joins

SELECT
    s.sensor_id,
    s.sensor_type,
    s.nbs_project_id,

    -- location
    loc.location_id,
    loc.latitude,
    loc.longitude,

    -- geographic hierarchy (denormalised for downstream use)
    a3.admin_div_3_id,
    a3.neighbourhood_name,
    a2.admin_div_2_id,
    a2.borough_name,
    a1.admin_div_1_id,
    a1.city_name,
    c.country_id,
    c.country_name,
    a1.population      AS city_population

FROM {{ ref('stg_sensor') }} s
LEFT JOIN {{ ref('stg_location') }} loc     ON s.location_id = loc.location_id
LEFT JOIN {{ ref('stg_admin_div_3') }} a3   ON loc.admin_div_3_id = a3.admin_div_3_id
LEFT JOIN {{ ref('stg_admin_div_2') }} a2   ON a3.admin_div_2_id = a2.admin_div_2_id
LEFT JOIN {{ ref('stg_admin_div_1') }} a1   ON a2.admin_div_1_id = a1.admin_div_1_id
LEFT JOIN {{ ref('stg_country') }} c        ON a1.country_id = c.country_id
