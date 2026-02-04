-- stg_engagement_tool.sql
-- Tools used to collect citizen data (surveys, apps, sensors)

SELECT
    CAST(tool_id AS INT)                AS tool_id,
    TRIM(tool_name)                     AS tool_name,
    TRIM(tool_type)                     AS tool_type,
    TRIM(description)                   AS description,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_engagement_tools') }}
WHERE tool_id IS NOT NULL
