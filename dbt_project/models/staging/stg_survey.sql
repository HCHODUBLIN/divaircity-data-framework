-- stg_survey.sql
-- Survey metadata

SELECT
    CAST(survey_id AS INT)              AS survey_id,
    CAST(event_id AS INT)               AS event_id,
    CAST(person_id AS INT)              AS person_id,
    TRIM(survey_type)                   AS survey_type,
    TRIM(contents)                      AS contents,
    CAST(response_date AS TIMESTAMP_NTZ) AS response_date,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_surveys') }}
WHERE survey_id IS NOT NULL
