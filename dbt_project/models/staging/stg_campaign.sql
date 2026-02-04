-- stg_campaign.sql
-- Policy campaigns and interventions

SELECT
    CAST(campaign_id AS INT)            AS campaign_id,
    TRIM(campaign_name)                 AS campaign_name,
    TRIM(campaign_type)                 AS campaign_type,
    CAST(borough_id AS INT)             AS admin_div_2_id,
    CAST(start_date AS DATE)            AS start_date,
    CAST(end_date AS DATE)              AS end_date,
    TRIM(description)                   AS description,
    TRIM(target_metric)                 AS target_metric,
    CAST(target_reduction_pct AS FLOAT) AS target_reduction_pct,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_campaigns') }}
WHERE campaign_id IS NOT NULL
