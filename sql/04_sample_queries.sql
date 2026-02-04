-- ============================================
-- DivAirCity Data Framework
-- Sample Analytical Queries
-- ============================================
-- These queries demonstrate the join patterns
-- enabled by the star/snowflake schema design.
-- ============================================

USE DATABASE divaircity;
USE SCHEMA silver;


-- =============================================
-- QUERY 1: Average PM2.5 by city
-- Pattern: Fact → Sensor → Location → full geo hierarchy
-- Demonstrates: snowflake schema traversal (5-level join)
-- =============================================

SELECT
    c.country_name,
    a1.city_name,
    m.metric_name,
    ROUND(AVG(sm.value), 2)         AS avg_value,
    COUNT(sm.measurement_id)        AS reading_count,
    MIN(sm.collection_date)         AS first_reading,
    MAX(sm.collection_date)         AS last_reading
FROM fact_sensor_measurement sm
JOIN dim_sensor s        ON sm.sensor_id = s.sensor_id
JOIN dim_metric m        ON sm.metric_id = m.metric_id
JOIN dim_location loc    ON s.location_id = loc.location_id
JOIN dim_admin_div_3 a3  ON loc.admin_div_3_id = a3.admin_div_3_id
JOIN dim_admin_div_2 a2  ON a3.admin_div_2_id = a2.admin_div_2_id
JOIN dim_admin_div_1 a1  ON a2.admin_div_1_id = a1.admin_div_1_id
JOIN dim_country c       ON a1.country_id = c.country_id
WHERE m.metric_name = 'PM2.5'
GROUP BY c.country_name, a1.city_name, m.metric_name
ORDER BY avg_value DESC;


-- =============================================
-- QUERY 2: Air quality threshold exceedances by neighbourhood
-- Pattern: Fact → dimensions with conditional aggregation
-- Demonstrates: CASE WHEN, window functions
-- =============================================

WITH daily_avg AS (
    SELECT
        a3.neighbourhood_name,
        a1.city_name,
        sm.collection_date,
        AVG(sm.value) AS daily_avg_pm25
    FROM fact_sensor_measurement sm
    JOIN dim_sensor s        ON sm.sensor_id = s.sensor_id
    JOIN dim_metric m        ON sm.metric_id = m.metric_id
    JOIN dim_location loc    ON s.location_id = loc.location_id
    JOIN dim_admin_div_3 a3  ON loc.admin_div_3_id = a3.admin_div_3_id
    JOIN dim_admin_div_2 a2  ON a3.admin_div_2_id = a2.admin_div_2_id
    JOIN dim_admin_div_1 a1  ON a2.admin_div_1_id = a1.admin_div_1_id
    WHERE m.metric_name = 'PM2.5'
    GROUP BY a3.neighbourhood_name, a1.city_name, sm.collection_date
)
SELECT
    city_name,
    neighbourhood_name,
    COUNT(*)                                                    AS total_days,
    SUM(CASE WHEN daily_avg_pm25 > 25 THEN 1 ELSE 0 END)      AS days_exceeding_eu_limit,
    ROUND(
        SUM(CASE WHEN daily_avg_pm25 > 25 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 1
    )                                                           AS pct_days_exceeding,
    ROUND(AVG(daily_avg_pm25), 2)                               AS avg_pm25
FROM daily_avg
GROUP BY city_name, neighbourhood_name
ORDER BY pct_days_exceeding DESC;


-- =============================================
-- QUERY 3: Co-creation participation by 6+1 diversity group
-- Pattern: Fact (participation) → Person → Community
-- Demonstrates: diversity & inclusion analysis
-- =============================================

SELECT
    e.event_type,
    p.plan_name,
    COUNT(DISTINCT fp.person_id)    AS total_participants,
    SUM(CASE WHEN com.is_women THEN 1 ELSE 0 END)                      AS women,
    SUM(CASE WHEN com.is_youth THEN 1 ELSE 0 END)                      AS youth,
    SUM(CASE WHEN com.is_elders THEN 1 ELSE 0 END)                     AS elders,
    SUM(CASE WHEN com.is_lgbtq THEN 1 ELSE 0 END)                      AS lgbtq,
    SUM(CASE WHEN com.is_ethnic_minority THEN 1 ELSE 0 END)            AS ethnic_minority,
    SUM(CASE WHEN com.is_disability THEN 1 ELSE 0 END)                 AS disability,
    SUM(CASE WHEN com.is_economically_disadvantaged THEN 1 ELSE 0 END) AS economically_disadvantaged
FROM fact_event_participation fp
JOIN dim_event e         ON fp.event_id = e.event_id
JOIN dim_plan p          ON e.plan_id = p.plan_id
JOIN dim_person per      ON fp.person_id = per.person_id
LEFT JOIN dim_community com ON per.community_id = com.community_id
GROUP BY e.event_type, p.plan_name
ORDER BY total_participants DESC;


-- =============================================
-- QUERY 4: NBS impact on air quality (before/after analysis)
-- Pattern: Sensor measurements near NBS projects
-- Demonstrates: date-based comparison, analytical thinking
-- =============================================

WITH nbs_air_quality AS (
    SELECT
        n.nbs_name,
        n.nbs_type,
        n.year_built,
        sm.collection_date,
        sm.value AS pm25_value,
        CASE
            WHEN YEAR(sm.collection_date) < n.year_built THEN 'before_nbs'
            ELSE 'after_nbs'
        END AS period
    FROM fact_sensor_measurement sm
    JOIN dim_sensor s         ON sm.sensor_id = s.sensor_id
    JOIN dim_metric m         ON sm.metric_id = m.metric_id
    JOIN dim_nbs_project n    ON s.nbs_project_id = n.nbs_id
    WHERE m.metric_name = 'PM2.5'
      AND n.year_built IS NOT NULL
)
SELECT
    nbs_name,
    nbs_type,
    year_built,
    ROUND(AVG(CASE WHEN period = 'before_nbs' THEN pm25_value END), 2)  AS avg_pm25_before,
    ROUND(AVG(CASE WHEN period = 'after_nbs' THEN pm25_value END), 2)   AS avg_pm25_after,
    ROUND(
        AVG(CASE WHEN period = 'before_nbs' THEN pm25_value END)
        - AVG(CASE WHEN period = 'after_nbs' THEN pm25_value END),
        2
    )                                                                    AS pm25_reduction,
    COUNT(DISTINCT CASE WHEN period = 'before_nbs' THEN collection_date END) AS days_before,
    COUNT(DISTINCT CASE WHEN period = 'after_nbs' THEN collection_date END)  AS days_after
FROM nbs_air_quality
GROUP BY nbs_name, nbs_type, year_built
HAVING avg_pm25_before IS NOT NULL AND avg_pm25_after IS NOT NULL
ORDER BY pm25_reduction DESC;


-- =============================================
-- QUERY 5: Resource allocation efficiency by plan
-- Pattern: Multiple dimension joins for cross-domain analysis
-- Demonstrates: combining social, environmental, economic data
-- =============================================

SELECT
    p.plan_name,
    p.focus,
    p.scope,
    a1.city_name,
    o.organisation_name,
    SUM(r.amount)                                       AS total_investment_eur,
    COUNT(DISTINCT n.nbs_id)                             AS nbs_projects_count,
    SUM(n.project_area_ha)                               AS total_nbs_area_ha,
    ROUND(SUM(r.amount) / NULLIF(SUM(n.project_area_ha), 0), 0) AS eur_per_hectare,
    COUNT(DISTINCT s.sensor_id)                          AS sensors_deployed
FROM dim_plan p
LEFT JOIN dim_organisation o     ON p.organisation_id = o.organisation_id
LEFT JOIN dim_admin_div_1 a1     ON p.admin_div_id = a1.admin_div_1_id
LEFT JOIN dim_resource r         ON r.plan_id = p.plan_id
LEFT JOIN dim_nbs_project n      ON n.plan_id = p.plan_id
LEFT JOIN dim_sensor s           ON s.nbs_project_id = n.nbs_id
GROUP BY p.plan_name, p.focus, p.scope, a1.city_name, o.organisation_name
ORDER BY total_investment_eur DESC NULLS LAST;
