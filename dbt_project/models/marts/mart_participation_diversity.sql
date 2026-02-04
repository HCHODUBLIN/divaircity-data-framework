-- mart_participation_diversity.sql
-- Gold layer: co-creation participation with diversity breakdown
-- Supports the DivAirCity 6+1 diversity group analysis
-- Used for monitoring inclusiveness of the co-creation process
--
-- Grain: one row per participant per event

SELECT
    -- event context
    fp.participation_id,
    eg.event_id,
    eg.event_type,
    eg.event_date,
    eg.total_participants,

    -- plan context
    eg.plan_id,
    eg.plan_name,
    eg.plan_focus,
    eg.plan_scope,

    -- phase context
    eg.phase_id,
    eg.phase_name,

    -- tool context
    eg.tool_id,
    eg.tool_name,

    -- participant
    fp.person_id,
    fp.role                     AS participation_role,

    -- organisation
    pd.organisation_id,
    pd.organisation_name,
    pd.organisation_type,

    -- 6+1 diversity categories (from community membership)
    pd.is_women,
    pd.is_youth,
    pd.is_elders,
    pd.is_lgbtq,
    pd.is_ethnic_minority,
    pd.is_disability,
    pd.is_economically_disadvantaged,
    pd.community_type,

    -- geographic context
    eg.admin_div_3_id,
    eg.neighbourhood_name       AS event_neighbourhood,
    eg.admin_div_2_id,
    eg.borough_name             AS event_borough,
    eg.admin_div_1_id,
    eg.city_name                AS event_city,
    eg.country_name             AS event_country,

    -- time dimensions for BI slicing
    DAYOFWEEK(eg.event_date)    AS day_of_week,
    MONTH(eg.event_date)        AS month,
    QUARTER(eg.event_date)      AS quarter,
    YEAR(eg.event_date)         AS year

FROM {{ ref('stg_event_participation') }} fp
JOIN {{ ref('int_event_with_geography') }} eg       ON fp.event_id = eg.event_id
LEFT JOIN {{ ref('int_person_with_diversity') }} pd ON fp.person_id = pd.person_id
