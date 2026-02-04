-- stg_survey_response.sql
-- Survey response analysis with sentiment
-- Grain: one row per survey response

SELECT
    CAST(response_id AS INT)            AS response_id,
    CAST(survey_id AS INT)              AS survey_id,
    CAST(event_id AS INT)               AS event_id,
    CAST(person_id AS INT)              AS person_id,
    CAST(tool_id AS INT)                AS tool_id,
    CAST(response_date AS DATE)         AS response_date,
    TRIM(key_phrases)                   AS key_phrases,
    CAST(sentiment_score AS FLOAT)      AS sentiment_score,
    TRIM(sentiment_label)               AS sentiment_label,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_survey_responses') }}
WHERE response_id IS NOT NULL
