-- stg_metric.sql
-- Metric definitions (KPIs, indicators)

SELECT
    CAST(metric_id AS INT)              AS metric_id,
    TRIM(metric_name)                   AS metric_name,
    TRIM(metric_type)                   AS metric_type,
    TRIM(description)                   AS description,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_metrics') }}
WHERE metric_id IS NOT NULL
