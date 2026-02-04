-- mart_air_quality.sql
-- Gold layer: wide, analytics-ready table for air quality analysis
-- Pre-joins fact measurements with all relevant dimensions
-- Optimised for BI tools (Power BI, Tableau) — no joins needed at query time
--
-- Grain: one row per sensor measurement with full context

SELECT
    -- measurement facts
    sm.measurement_id,
    sm.collection_date,
    sm.collection_time,
    sm.value                    AS measurement_value,
    sm.unit                     AS measurement_unit,

    -- metric context
    m.metric_name,
    m.metric_type,

    -- sensor context
    sg.sensor_id,
    sg.sensor_type,

    -- geographic context (fully denormalised)
    sg.location_id,
    sg.latitude,
    sg.longitude,
    sg.neighbourhood_name,
    sg.borough_name,
    sg.city_name,
    sg.country_name,
    sg.city_population,

    -- NBS project context (if sensor monitors an NBS)
    nbs.nbs_name,
    nbs.nbs_type,
    nbs.project_area_ha         AS nbs_area_ha,
    nbs.year_built              AS nbs_year_built,

    -- EU air quality thresholds (hardcoded per directive 2008/50/EC)
    CASE
        WHEN m.metric_name = 'PM2.5' AND sm.value > 25 THEN TRUE
        WHEN m.metric_name = 'PM10'  AND sm.value > 50 THEN TRUE
        WHEN m.metric_name = 'NO2'   AND sm.value > 200 THEN TRUE
        WHEN m.metric_name = 'O3'    AND sm.value > 120 THEN TRUE
        ELSE FALSE
    END                         AS exceeds_eu_limit,

    -- time dimensions for BI slicing
    DAYOFWEEK(sm.collection_date)   AS day_of_week,
    MONTH(sm.collection_date)       AS month,
    QUARTER(sm.collection_date)     AS quarter,
    YEAR(sm.collection_date)        AS year

FROM {{ ref('stg_sensor_measurement') }} sm
JOIN {{ ref('int_sensor_with_geography') }} sg   ON sm.sensor_id = sg.sensor_id
JOIN {{ ref('stg_metric') }} m                   ON sm.metric_id = m.metric_id
LEFT JOIN {{ ref('stg_nbs_project') }} nbs       ON sg.nbs_project_id = nbs.nbs_id
