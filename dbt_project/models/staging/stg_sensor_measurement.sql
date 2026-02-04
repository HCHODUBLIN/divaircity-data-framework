-- stg_sensor_measurement.sql
-- Staging layer for raw sensor readings
-- This feeds the primary fact table
-- Grain: one measurement per sensor per timestamp

SELECT
    CAST(measurement_id AS INT)         AS measurement_id,
    CAST(sensor_id AS INT)              AS sensor_id,
    CAST(metric_id AS INT)              AS metric_id,
    CAST(person_id AS INT)              AS person_id,
    TRIM(track_id)                      AS track_id,
    CAST(collection_date AS DATE)       AS collection_date,
    CAST(collection_time AS TIME)       AS collection_time,
    CAST(value AS FLOAT)                AS value,
    TRIM(LOWER(unit))                   AS unit,
    CAST(distance_m AS FLOAT)           AS distance_m,
    CAST(latitude AS FLOAT)             AS latitude,
    CAST(longitude AS FLOAT)            AS longitude,
    TRIM(status)                        AS status,
    TRIM(description)                   AS description,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_sensor_measurements') }}
WHERE measurement_id IS NOT NULL
  AND sensor_id IS NOT NULL
  AND value IS NOT NULL  -- drop null readings
