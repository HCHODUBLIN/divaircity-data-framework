-- stg_admin_div_3.sql
-- Neighbourhood-level geographic boundary (ward level)
-- Finest geographic granularity for identifying disadvantaged areas

SELECT
    CAST(neighbourhood_id AS INT)       AS admin_div_3_id,
    TRIM(neighbourhood_name)            AS neighbourhood_name,
    CAST(borough_id AS INT)             AS admin_div_2_id,
    CAST(area AS FLOAT)                 AS area_km2,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_neighbourhoods') }}
WHERE neighbourhood_id IS NOT NULL
