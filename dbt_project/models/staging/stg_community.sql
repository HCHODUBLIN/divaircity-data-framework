-- stg_community.sql
-- Community groups with 6+1 diversity classifications
-- GDPR Note: Diversity attributes stored at aggregate community level, not individual

SELECT
    CAST(community_id AS INT)                       AS community_id,
    TRIM(community_type)                            AS community_type,
    TRIM(geographical_scope)                        AS geographical_scope,
    COALESCE(CAST(is_women AS BOOLEAN), FALSE)      AS is_women,
    COALESCE(CAST(is_youth AS BOOLEAN), FALSE)      AS is_youth,
    COALESCE(CAST(is_elders AS BOOLEAN), FALSE)     AS is_elders,
    COALESCE(CAST(is_lgbtq AS BOOLEAN), FALSE)      AS is_lgbtq,
    COALESCE(CAST(is_ethnic_minority AS BOOLEAN), FALSE) AS is_ethnic_minority,
    COALESCE(CAST(is_disability AS BOOLEAN), FALSE) AS is_disability,
    COALESCE(CAST(is_economically_disadvantaged AS BOOLEAN), FALSE) AS is_economically_disadvantaged,
    CAST(admin_div_id AS INT)                       AS admin_div_id,
    TRIM(description)                               AS description,
    {{ current_timestamp_utc() }}                             AS loaded_at

FROM {{ source('bronze', 'raw_communities') }}
WHERE community_id IS NOT NULL
