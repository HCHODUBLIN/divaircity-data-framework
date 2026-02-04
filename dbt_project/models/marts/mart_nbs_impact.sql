-- mart_nbs_impact.sql
-- Gold layer: Nature-Based Solutions impact analysis
-- Combines NBS project data with environmental measurements and cost metrics
-- Used for cost-benefit analysis and CO2 sequestration tracking
--
-- Grain: one row per NBS project

SELECT
    -- NBS project details
    ng.nbs_id,
    ng.nbs_name,
    ng.nbs_type,
    ng.description,
    ng.year_built,
    ng.project_area_m2,
    ng.project_area_ha,

    -- cost metrics
    ng.installation_cost,
    ng.maintenance_cost_annual,
    ng.co2_sequestration_potential_kg,
    ng.normalised_cost_per_m2_co2,

    -- derived cost metrics
    CASE
        WHEN ng.project_area_m2 > 0
        THEN ng.installation_cost / ng.project_area_m2
    END AS cost_per_m2,
    CASE
        WHEN ng.co2_sequestration_potential_kg > 0
        THEN ng.installation_cost / ng.co2_sequestration_potential_kg
    END AS cost_per_kg_co2,

    -- plan context
    ng.plan_id,
    ng.plan_name,
    ng.plan_focus,

    -- location
    ng.location_id,
    ng.latitude,
    ng.longitude,
    ng.postcode,

    -- geographic hierarchy
    ng.admin_div_3_id,
    ng.neighbourhood_name,
    ng.admin_div_2_id,
    ng.borough_name,
    ng.admin_div_1_id,
    ng.city_name,
    ng.country_name,

    -- sensor count (monitoring this NBS)
    sensor_stats.sensor_count,
    sensor_stats.measurement_count,

    -- environmental impact (from linked sensors)
    sensor_stats.avg_pm25_reduction,
    sensor_stats.avg_temperature_reduction

FROM {{ ref('int_nbs_with_geography') }} ng
LEFT JOIN (
    SELECT
        s.nbs_project_id,
        COUNT(DISTINCT s.sensor_id) AS sensor_count,
        COUNT(sm.measurement_id) AS measurement_count,
        AVG(CASE WHEN m.metric_name = 'PM2.5' AND sm.status = 'after' THEN sm.value END) -
        AVG(CASE WHEN m.metric_name = 'PM2.5' AND sm.status = 'before' THEN sm.value END) AS avg_pm25_reduction,
        AVG(CASE WHEN m.metric_name = 'Temperature' AND sm.status = 'after' THEN sm.value END) -
        AVG(CASE WHEN m.metric_name = 'Temperature' AND sm.status = 'before' THEN sm.value END) AS avg_temperature_reduction
    FROM {{ ref('stg_sensor') }} s
    LEFT JOIN {{ ref('stg_sensor_measurement') }} sm ON s.sensor_id = sm.sensor_id
    LEFT JOIN {{ ref('stg_metric') }} m ON sm.metric_id = m.metric_id
    WHERE s.nbs_project_id IS NOT NULL
    GROUP BY s.nbs_project_id
) sensor_stats ON ng.nbs_id = sensor_stats.nbs_project_id
