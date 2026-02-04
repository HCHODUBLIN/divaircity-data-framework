-- stg_resource.sql
-- Financial resources allocated to plans

SELECT
    CAST(resource_id AS INT)            AS resource_id,
    CAST(organisation_id AS INT)        AS organisation_id,
    CAST(plan_id AS INT)                AS plan_id,
    TRIM(description)                   AS description,
    CAST(amount AS FLOAT)               AS amount,
    COALESCE(TRIM(currency), 'EUR')     AS currency,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_resources') }}
WHERE resource_id IS NOT NULL
