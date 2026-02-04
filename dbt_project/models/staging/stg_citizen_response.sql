-- stg_citizen_response.sql
-- Citizen-generated data from engagement tools

SELECT
    CAST(response_id AS INT)            AS response_id,
    CAST(event_id AS INT)               AS event_id,
    CAST(person_id AS INT)              AS person_id,
    CAST(tool_id AS INT)                AS tool_id,
    TRIM(response_content)              AS response_content,
    CAST(response_date AS TIMESTAMP_NTZ) AS response_date,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_citizen_responses') }}
WHERE response_id IS NOT NULL
