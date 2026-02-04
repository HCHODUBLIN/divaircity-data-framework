-- int_statistics_with_geography.sql
-- Intermediate model: enrich public statistics with full geographic context
-- Used for health-pollution correlation analysis

SELECT
    ps.stat_id,
    ps.stat_type,
    ps.breakdown,
    ps.source,
    ps.reference_year,

    -- demographic data
    ps.population,
    ps.ethnic_asian_pct,
    ps.ethnic_black_pct,
    ps.ethnic_white_pct,
    ps.ethnic_mixed_pct,
    ps.ethnic_other_pct,

    -- economic data
    ps.household_income_avg,
    ps.deprivation_index,

    -- health data (aggregated)
    ps.asthma_admissions_0_14,
    ps.asthma_admissions_15_64,
    ps.asthma_admissions_65_plus,
    ps.copd_admissions_65_plus,

    -- geographic hierarchy (denormalised)
    a3.admin_div_3_id,
    a3.neighbourhood_name,
    a2.admin_div_2_id,
    a2.borough_name,
    a1.admin_div_1_id,
    a1.city_name,
    c.country_id,
    c.country_name

FROM {{ ref('stg_public_statistics') }} ps
LEFT JOIN {{ ref('stg_admin_div_3') }} a3    ON ps.admin_div_3_id = a3.admin_div_3_id
LEFT JOIN {{ ref('stg_admin_div_2') }} a2    ON a3.admin_div_2_id = a2.admin_div_2_id
LEFT JOIN {{ ref('stg_admin_div_1') }} a1    ON a2.admin_div_1_id = a1.admin_div_1_id
LEFT JOIN {{ ref('stg_country') }} c         ON a1.country_id = c.country_id
