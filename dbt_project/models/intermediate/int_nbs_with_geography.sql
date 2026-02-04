-- int_nbs_with_geography.sql
-- Intermediate model: enrich NBS projects with full geographic context

SELECT
    nbs.nbs_id,
    nbs.nbs_name,
    nbs.nbs_type,
    nbs.description,
    nbs.project_area_m2,
    nbs.project_area_ha,
    nbs.year_built,
    nbs.installation_cost,
    nbs.maintenance_cost_annual,
    nbs.co2_sequestration_potential_kg,
    nbs.normalised_cost_per_m2_co2,

    -- plan context
    nbs.plan_id,
    p.plan_name,
    p.focus             AS plan_focus,

    -- location
    loc.location_id,
    loc.latitude,
    loc.longitude,
    loc.postcode,

    -- geographic hierarchy (denormalised)
    a3.admin_div_3_id,
    a3.neighbourhood_name,
    a2.admin_div_2_id,
    a2.borough_name,
    a1.admin_div_1_id,
    a1.city_name,
    c.country_id,
    c.country_name

FROM {{ ref('stg_nbs_project') }} nbs
LEFT JOIN {{ ref('stg_plan') }} p            ON nbs.plan_id = p.plan_id
LEFT JOIN {{ ref('stg_location') }} loc      ON nbs.location_id = loc.location_id
LEFT JOIN {{ ref('stg_admin_div_3') }} a3    ON loc.admin_div_3_id = a3.admin_div_3_id
LEFT JOIN {{ ref('stg_admin_div_2') }} a2    ON a3.admin_div_2_id = a2.admin_div_2_id
LEFT JOIN {{ ref('stg_admin_div_1') }} a1    ON a2.admin_div_1_id = a1.admin_div_1_id
LEFT JOIN {{ ref('stg_country') }} c         ON a1.country_id = c.country_id
