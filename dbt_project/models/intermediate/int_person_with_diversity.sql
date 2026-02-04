-- int_person_with_diversity.sql
-- Intermediate model: enrich persons with community diversity attributes
-- GDPR Note: Diversity tracked at community level, not individual level

SELECT
    per.person_id,

    -- organisation context
    per.organisation_id,
    o.organisation_name,
    o.organisation_type,

    -- community context
    per.community_id,
    com.community_type,
    com.geographical_scope,

    -- 6+1 diversity categories (from community membership)
    COALESCE(com.is_women, FALSE)                       AS is_women,
    COALESCE(com.is_youth, FALSE)                       AS is_youth,
    COALESCE(com.is_elders, FALSE)                      AS is_elders,
    COALESCE(com.is_lgbtq, FALSE)                       AS is_lgbtq,
    COALESCE(com.is_ethnic_minority, FALSE)             AS is_ethnic_minority,
    COALESCE(com.is_disability, FALSE)                  AS is_disability,
    COALESCE(com.is_economically_disadvantaged, FALSE)  AS is_economically_disadvantaged

FROM {{ ref('stg_person') }} per
LEFT JOIN {{ ref('stg_organisation') }} o   ON per.organisation_id = o.organisation_id
LEFT JOIN {{ ref('stg_community') }} com    ON per.community_id = com.community_id
