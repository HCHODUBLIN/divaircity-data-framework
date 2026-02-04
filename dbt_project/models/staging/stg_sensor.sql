-- stg_sensor.sql
-- Environmental sensors deployed across cities

SELECT
    CAST(sensor_id AS INT)              AS sensor_id,
    TRIM(sensor_type)                   AS sensor_type,
    CAST(nbs_project_id AS INT)         AS nbs_project_id,
    CAST(location_id AS INT)            AS location_id,
    TRIM(description)                   AS description,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_sensors') }}
WHERE sensor_id IS NOT NULL
