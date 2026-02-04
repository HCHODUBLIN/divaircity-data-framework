-- mart_health_pollution.sql
-- Gold layer: health-pollution correlation analysis
-- Combines public health statistics with air quality measurements
-- Used for analysing relationship between air quality and health outcomes
--
-- Grain: one row per neighbourhood per reference year

SELECT
    -- geographic context
    sg.admin_div_3_id,
    sg.neighbourhood_name,
    sg.admin_div_2_id,
    sg.borough_name,
    sg.admin_div_1_id,
    sg.city_name,
    sg.country_name,

    -- demographic data
    sg.reference_year,
    sg.population,
    sg.ethnic_asian_pct,
    sg.ethnic_black_pct,
    sg.ethnic_white_pct,
    sg.ethnic_mixed_pct,
    sg.ethnic_other_pct,

    -- economic data
    sg.household_income_avg,
    sg.deprivation_index,

    -- health outcomes (aggregated)
    sg.asthma_admissions_0_14,
    sg.asthma_admissions_15_64,
    sg.asthma_admissions_65_plus,
    (sg.asthma_admissions_0_14 + sg.asthma_admissions_15_64 + sg.asthma_admissions_65_plus) AS total_asthma_admissions,
    sg.copd_admissions_65_plus,

    -- air quality metrics (aggregated by neighbourhood)
    aq.avg_pm25,
    aq.avg_pm10,
    aq.avg_no2,
    aq.max_pm25,
    aq.max_pm10,
    aq.days_exceeding_pm25_limit,
    aq.days_exceeding_pm10_limit

FROM {{ ref('int_statistics_with_geography') }} sg
LEFT JOIN (
    SELECT
        sg_inner.admin_div_3_id,
        YEAR(sm.collection_date)        AS measurement_year,
        AVG(CASE WHEN m.metric_name = 'PM2.5' THEN sm.value END) AS avg_pm25,
        AVG(CASE WHEN m.metric_name = 'PM10' THEN sm.value END)  AS avg_pm10,
        AVG(CASE WHEN m.metric_name = 'NO2' THEN sm.value END)   AS avg_no2,
        MAX(CASE WHEN m.metric_name = 'PM2.5' THEN sm.value END) AS max_pm25,
        MAX(CASE WHEN m.metric_name = 'PM10' THEN sm.value END)  AS max_pm10,
        COUNT(DISTINCT CASE WHEN m.metric_name = 'PM2.5' AND sm.value > 25 THEN sm.collection_date END) AS days_exceeding_pm25_limit,
        COUNT(DISTINCT CASE WHEN m.metric_name = 'PM10' AND sm.value > 50 THEN sm.collection_date END)  AS days_exceeding_pm10_limit
    FROM {{ ref('stg_sensor_measurement') }} sm
    JOIN {{ ref('int_sensor_with_geography') }} sg_inner ON sm.sensor_id = sg_inner.sensor_id
    JOIN {{ ref('stg_metric') }} m ON sm.metric_id = m.metric_id
    WHERE m.metric_name IN ('PM2.5', 'PM10', 'NO2')
    GROUP BY sg_inner.admin_div_3_id, YEAR(sm.collection_date)
) aq ON sg.admin_div_3_id = aq.admin_div_3_id AND sg.reference_year = aq.measurement_year
