-- mart_panas_environmental.sql
-- Gold layer: PANAS mood scores correlated with environmental conditions
-- Links walking route mood assessments with air quality measurements
-- Used for analysing environment-mood relationship
--
-- Grain: one row per PANAS assessment

SELECT
    -- PANAS assessment
    pa.panas_id,
    pa.person_id,
    pa.assessment_date,
    pa.status,
    pa.track_id,

    -- Positive Affect scores
    pa.pa_lively,
    pa.pa_cheerful,
    pa.pa_happy,
    pa.pa_joyful,
    pa.pa_proud,
    pa.pa_total,

    -- Negative Affect scores
    pa.na_scared,
    pa.na_angry,
    pa.na_afraid,
    pa.na_miserable,
    pa.na_sad,
    pa.na_total,

    -- Affect balance (positive - negative)
    (pa.pa_total - pa.na_total) AS affect_balance,

    -- participant diversity context
    pd.community_type,
    pd.is_women,
    pd.is_youth,
    pd.is_elders,
    pd.is_ethnic_minority,

    -- event context
    eg.event_id,
    eg.event_type,
    eg.city_name,
    eg.neighbourhood_name,

    -- environmental conditions during route (aggregated by track_id)
    route_env.avg_pm25,
    route_env.avg_pm10,
    route_env.avg_no2,
    route_env.avg_temperature,
    route_env.total_distance_m,
    route_env.measurement_count,

    -- time dimensions
    DAYOFWEEK(pa.assessment_date)   AS day_of_week,
    MONTH(pa.assessment_date)       AS month,
    YEAR(pa.assessment_date)        AS year

FROM {{ ref('stg_panas_score') }} pa
LEFT JOIN {{ ref('int_person_with_diversity') }} pd ON pa.person_id = pd.person_id
LEFT JOIN {{ ref('int_event_with_geography') }} eg  ON pa.event_id = eg.event_id
LEFT JOIN (
    SELECT
        sm.track_id,
        AVG(CASE WHEN m.metric_name = 'PM2.5' THEN sm.value END)       AS avg_pm25,
        AVG(CASE WHEN m.metric_name = 'PM10' THEN sm.value END)        AS avg_pm10,
        AVG(CASE WHEN m.metric_name = 'NO2' THEN sm.value END)         AS avg_no2,
        AVG(CASE WHEN m.metric_name = 'Temperature' THEN sm.value END) AS avg_temperature,
        MAX(sm.distance_m)                                              AS total_distance_m,
        COUNT(*)                                                        AS measurement_count
    FROM {{ ref('stg_sensor_measurement') }} sm
    JOIN {{ ref('stg_metric') }} m ON sm.metric_id = m.metric_id
    WHERE sm.track_id IS NOT NULL
    GROUP BY sm.track_id
) route_env ON pa.track_id = route_env.track_id
