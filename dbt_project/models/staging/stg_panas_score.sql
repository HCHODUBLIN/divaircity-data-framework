-- stg_panas_score.sql
-- PANAS (Positive and Negative Affect Schedule) mood assessment scores
-- Links to walking routes for environmental-mood correlation

SELECT
    CAST(panas_id AS INT)               AS panas_id,
    CAST(person_id AS INT)              AS person_id,
    CAST(event_id AS INT)               AS event_id,
    TRIM(track_id)                      AS track_id,
    CAST(assessment_date AS DATE)       AS assessment_date,
    TRIM(status)                        AS status,
    -- Positive Affect (PANAS_P)
    CAST(pa_lively AS INT)              AS pa_lively,
    CAST(pa_cheerful AS INT)            AS pa_cheerful,
    CAST(pa_happy AS INT)               AS pa_happy,
    CAST(pa_joyful AS INT)              AS pa_joyful,
    CAST(pa_proud AS INT)               AS pa_proud,
    CAST(pa_total AS INT)               AS pa_total,
    -- Negative Affect (PANAS_N)
    CAST(na_scared AS INT)              AS na_scared,
    CAST(na_angry AS INT)               AS na_angry,
    CAST(na_afraid AS INT)              AS na_afraid,
    CAST(na_miserable AS INT)           AS na_miserable,
    CAST(na_sad AS INT)                 AS na_sad,
    CAST(na_total AS INT)               AS na_total,
    {{ current_timestamp_utc() }}                 AS loaded_at

FROM {{ source('bronze', 'raw_panas_scores') }}
WHERE panas_id IS NOT NULL
