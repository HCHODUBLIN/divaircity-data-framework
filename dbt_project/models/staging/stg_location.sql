-- stg_location.sql
-- Physical location (address of building, sensor placement, NBS site)

SELECT
    CAST(location_id AS INT)            AS location_id,
    CAST(neighbourhood_id AS INT)       AS admin_div_3_id,
    TRIM(postcode)                      AS postcode,
    TRIM(address)                       AS address,
    TRIM(description)                   AS description,
    CAST(latitude AS FLOAT)             AS latitude,
    CAST(longitude AS FLOAT)            AS longitude,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_locations') }}
WHERE location_id IS NOT NULL
