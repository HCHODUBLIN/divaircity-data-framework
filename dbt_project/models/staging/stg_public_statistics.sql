-- stg_public_statistics.sql
-- Demographics, economics, and health statistics at neighbourhood level
-- GDPR Note: Aggregated data only - no individual-level health records

SELECT
    CAST(stat_id AS INT)                AS stat_id,
    CAST(neighbourhood_id AS INT)       AS admin_div_3_id,
    TRIM(stat_type)                     AS stat_type,
    TRIM(breakdown)                     AS breakdown,
    TRIM(source)                        AS source,
    CAST(reference_year AS INT)         AS reference_year,
    CAST(population AS INT)             AS population,
    CAST(ethnic_asian_pct AS FLOAT)     AS ethnic_asian_pct,
    CAST(ethnic_black_pct AS FLOAT)     AS ethnic_black_pct,
    CAST(ethnic_white_pct AS FLOAT)     AS ethnic_white_pct,
    CAST(ethnic_mixed_pct AS FLOAT)     AS ethnic_mixed_pct,
    CAST(ethnic_other_pct AS FLOAT)     AS ethnic_other_pct,
    CAST(household_income_avg AS FLOAT) AS household_income_avg,
    CAST(deprivation_index AS FLOAT)    AS deprivation_index,
    CAST(asthma_admissions_0_14 AS INT) AS asthma_admissions_0_14,
    CAST(asthma_admissions_15_64 AS INT) AS asthma_admissions_15_64,
    CAST(asthma_admissions_65_plus AS INT) AS asthma_admissions_65_plus,
    CAST(copd_admissions_65_plus AS INT) AS copd_admissions_65_plus,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_public_statistics') }}
WHERE stat_id IS NOT NULL
