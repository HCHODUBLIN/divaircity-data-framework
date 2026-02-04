-- mart_survey_sentiment.sql
-- Gold layer: survey response analysis with sentiment
-- Used for text analysis of citizen feedback
--
-- Grain: one row per survey response

SELECT
    -- response details
    sr.response_id,
    sr.survey_id,
    sr.response_date,
    sr.key_phrases,
    sr.sentiment_score,
    sr.sentiment_label,

    -- survey context
    s.survey_type,
    s.contents                  AS survey_contents,

    -- participant (anonymised)
    sr.person_id,
    pd.organisation_name,
    pd.community_type,

    -- diversity categories
    pd.is_women,
    pd.is_youth,
    pd.is_elders,
    pd.is_lgbtq,
    pd.is_ethnic_minority,
    pd.is_disability,
    pd.is_economically_disadvantaged,

    -- event context
    eg.event_id,
    eg.event_type,
    eg.event_date,

    -- tool context
    sr.tool_id,
    t.tool_name,
    t.tool_type,

    -- geographic context
    eg.neighbourhood_name,
    eg.borough_name,
    eg.city_name,
    eg.country_name,

    -- time dimensions
    DAYOFWEEK(sr.response_date) AS day_of_week,
    MONTH(sr.response_date)     AS month,
    QUARTER(sr.response_date)   AS quarter,
    YEAR(sr.response_date)      AS year

FROM {{ ref('stg_survey_response') }} sr
LEFT JOIN {{ ref('stg_survey') }} s                     ON sr.survey_id = s.survey_id
LEFT JOIN {{ ref('int_person_with_diversity') }} pd     ON sr.person_id = pd.person_id
LEFT JOIN {{ ref('int_event_with_geography') }} eg      ON sr.event_id = eg.event_id
LEFT JOIN {{ ref('stg_engagement_tool') }} t            ON sr.tool_id = t.tool_id
