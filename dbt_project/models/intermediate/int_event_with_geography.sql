-- int_event_with_geography.sql
-- Intermediate model: enrich events with full geographic context
-- Resolves the snowflake schema hierarchy into a single reference

SELECT
    e.event_id,
    e.event_type,
    e.event_date,
    e.event_time,
    e.event_location,
    e.total_participants,
    e.description,

    -- plan context
    e.plan_id,
    p.plan_name,
    p.focus             AS plan_focus,
    p.scope             AS plan_scope,

    -- phase context
    e.phase_id,
    ph.phase_name,
    ph.phase_order,

    -- tool context
    e.tool_id,
    t.tool_name,
    t.tool_type,

    -- geographic hierarchy (denormalised)
    a3.admin_div_3_id,
    a3.neighbourhood_name,
    a2.admin_div_2_id,
    a2.borough_name,
    a1.admin_div_1_id,
    a1.city_name,
    c.country_id,
    c.country_name

FROM {{ ref('stg_event') }} e
LEFT JOIN {{ ref('stg_plan') }} p            ON e.plan_id = p.plan_id
LEFT JOIN {{ ref('stg_phase') }} ph          ON e.phase_id = ph.phase_id
LEFT JOIN {{ ref('stg_engagement_tool') }} t ON e.tool_id = t.tool_id
LEFT JOIN {{ ref('stg_admin_div_3') }} a3    ON e.admin_div_3_id = a3.admin_div_3_id
LEFT JOIN {{ ref('stg_admin_div_2') }} a2    ON a3.admin_div_2_id = a2.admin_div_2_id
LEFT JOIN {{ ref('stg_admin_div_1') }} a1    ON a2.admin_div_1_id = a1.admin_div_1_id
LEFT JOIN {{ ref('stg_country') }} c         ON a1.country_id = c.country_id
