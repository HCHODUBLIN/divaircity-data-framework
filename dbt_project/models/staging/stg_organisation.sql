-- stg_organisation.sql
-- Partner organisations and local authorities

SELECT
    CAST(organisation_id AS INT)        AS organisation_id,
    TRIM(organisation_name)             AS organisation_name,
    TRIM(organisation_type)             AS organisation_type,
    CAST(city_id AS INT)                AS admin_div_1_id,
    CAST(community_id AS INT)           AS community_id,
    CURRENT_TIMESTAMP()                 AS loaded_at

FROM {{ source('bronze', 'raw_organisations') }}
WHERE organisation_id IS NOT NULL
