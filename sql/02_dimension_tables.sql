-- ============================================
-- DivAirCity Data Framework
-- Dimension Tables (Silver Schema)
-- ============================================
-- Snowflake SQL dialect
-- Tables are organised by domain:
--   1. Geospatial Boundaries (snowflake schema)
--   2. Agents
--   3. Co-creation Governance
--   4. City Objects
--   5. Economic & Metrics
-- ============================================

USE DATABASE divaircity;
USE SCHEMA silver;

-- =============================================
-- 1. GEOSPATIAL BOUNDARIES
--    Normalised hierarchy (snowflake schema):
--    Country → City → Borough → Neighbourhood → Location
-- =============================================

CREATE OR REPLACE TABLE dim_country (
    country_id      INT             NOT NULL,
    country_name    VARCHAR(100)    NOT NULL,
    population      INT,
    area_km2        FLOAT,
    -- metadata
    loaded_at       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_country PRIMARY KEY (country_id)
);

COMMENT ON TABLE dim_country IS 'Highest level geographic boundary. Source: EU member state registries.';


CREATE OR REPLACE TABLE dim_admin_div_1 (
    admin_div_1_id  INT             NOT NULL,
    city_name       VARCHAR(100)    NOT NULL,
    country_id      INT             NOT NULL,
    population      INT,
    area_km2        FLOAT,
    loaded_at       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_admin_div_1 PRIMARY KEY (admin_div_1_id),
    CONSTRAINT fk_admin_div_1_country FOREIGN KEY (country_id)
        REFERENCES dim_country (country_id)
);

COMMENT ON TABLE dim_admin_div_1 IS 'City-level geographic boundary. Examples: London, Orvieto, Potsdam.';


CREATE OR REPLACE TABLE dim_admin_div_2 (
    admin_div_2_id  INT             NOT NULL,
    borough_name    VARCHAR(100)    NOT NULL,
    admin_div_1_id  INT             NOT NULL,
    area_km2        FLOAT,
    loaded_at       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_admin_div_2 PRIMARY KEY (admin_div_2_id),
    CONSTRAINT fk_admin_div_2_city FOREIGN KEY (admin_div_1_id)
        REFERENCES dim_admin_div_1 (admin_div_1_id)
);

COMMENT ON TABLE dim_admin_div_2 IS 'Borough-level geographic boundary. Examples: Lambeth (London), Scalo (Orvieto).';


CREATE OR REPLACE TABLE dim_admin_div_3 (
    admin_div_3_id      INT             NOT NULL,
    neighbourhood_name  VARCHAR(100)    NOT NULL,
    admin_div_2_id      INT             NOT NULL,
    area_km2            FLOAT,
    loaded_at           TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_admin_div_3 PRIMARY KEY (admin_div_3_id),
    CONSTRAINT fk_admin_div_3_borough FOREIGN KEY (admin_div_2_id)
        REFERENCES dim_admin_div_2 (admin_div_2_id)
);

COMMENT ON TABLE dim_admin_div_3 IS 'Neighbourhood-level boundary (ward level in UK system). Finest geographic granularity for identifying disadvantaged areas.';


CREATE OR REPLACE TABLE dim_location (
    location_id     INT             NOT NULL,
    admin_div_3_id  INT             NOT NULL,
    postcode        VARCHAR(20),
    address         VARCHAR(500),
    description     VARCHAR(500),
    latitude        FLOAT,
    longitude       FLOAT,
    loaded_at       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_location PRIMARY KEY (location_id),
    CONSTRAINT fk_location_neighbourhood FOREIGN KEY (admin_div_3_id)
        REFERENCES dim_admin_div_3 (admin_div_3_id)
);

CREATE INDEX idx_location_postcode ON dim_location (postcode);

COMMENT ON TABLE dim_location IS 'Physical location (address of building, sensor placement, NBS site).';


-- =============================================
-- 2. AGENTS
--    Normalised: Community → Organisation → Person
-- =============================================

CREATE OR REPLACE TABLE dim_community (
    community_id                    INT             NOT NULL,
    community_type                  VARCHAR(50),     -- place / demographic / interest / circumstances
    geographical_scope              VARCHAR(100),
    is_women                        BOOLEAN         DEFAULT FALSE,
    is_youth                        BOOLEAN         DEFAULT FALSE,
    is_elders                       BOOLEAN         DEFAULT FALSE,
    is_lgbtq                        BOOLEAN         DEFAULT FALSE,
    is_ethnic_minority              BOOLEAN         DEFAULT FALSE,
    is_disability                   BOOLEAN         DEFAULT FALSE,
    is_economically_disadvantaged   BOOLEAN         DEFAULT FALSE,
    admin_div_id                    INT,
    description                     VARCHAR(1000),
    loaded_at                       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_community PRIMARY KEY (community_id)
);

COMMENT ON TABLE dim_community IS 'Group of persons/organisations sharing common characteristics. 6+1 diversity categories tracked per DivAirCity framework.';


CREATE OR REPLACE TABLE dim_organisation (
    organisation_id     INT             NOT NULL,
    organisation_name   VARCHAR(200)    NOT NULL,
    organisation_type   VARCHAR(50),     -- private / community group / research / public
    admin_div_1_id      INT,
    community_id        INT,
    loaded_at           TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_organisation PRIMARY KEY (organisation_id),
    CONSTRAINT fk_org_city FOREIGN KEY (admin_div_1_id)
        REFERENCES dim_admin_div_1 (admin_div_1_id),
    CONSTRAINT fk_org_community FOREIGN KEY (community_id)
        REFERENCES dim_community (community_id)
);

COMMENT ON TABLE dim_organisation IS 'Group of persons with a common purpose, plan, resources, and decision-making capability.';


CREATE OR REPLACE TABLE dim_person (
    person_id       INT             NOT NULL,
    community_id    INT,
    organisation_id INT,
    loaded_at       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_person PRIMARY KEY (person_id),
    CONSTRAINT fk_person_community FOREIGN KEY (community_id)
        REFERENCES dim_community (community_id),
    CONSTRAINT fk_person_org FOREIGN KEY (organisation_id)
        REFERENCES dim_organisation (organisation_id)
);

COMMENT ON TABLE dim_person IS 'Individual person (anonymised). Used only to identify organisation and community membership.';


-- =============================================
-- 3. CO-CREATION GOVERNANCE
-- =============================================

CREATE OR REPLACE TABLE dim_plan (
    plan_id                 INT             NOT NULL,
    plan_name               VARCHAR(200)    NOT NULL,
    plan_type               VARCHAR(100),
    organisation_id         INT,
    scope                   VARCHAR(100),    -- national / regional / city / neighbourhood
    admin_div_id            INT,
    focus                   VARCHAR(200),    -- sustainability / transportation / regeneration
    timescale_years         INT,
    start_date              DATE,
    end_date                DATE,
    status                  VARCHAR(20),     -- active / achieved
    is_divaircity_plan      BOOLEAN         DEFAULT FALSE,
    target_area_ha          FLOAT,
    has_citizen_science      BOOLEAN         DEFAULT FALSE,
    outcomes                VARCHAR(2000),
    loaded_at               TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_plan PRIMARY KEY (plan_id),
    CONSTRAINT fk_plan_org FOREIGN KEY (organisation_id)
        REFERENCES dim_organisation (organisation_id)
);

COMMENT ON TABLE dim_plan IS 'A list of steps with times and resources to achieve an objective. Examples: local air pollution plan, national decarbonization action plan.';


CREATE OR REPLACE TABLE dim_objective (
    objective_id    INT             NOT NULL,
    objective_name  VARCHAR(200)    NOT NULL,
    plan_id         INT,
    description     VARCHAR(2000),
    loaded_at       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_objective PRIMARY KEY (objective_id),
    CONSTRAINT fk_objective_plan FOREIGN KEY (plan_id)
        REFERENCES dim_plan (plan_id)
);

COMMENT ON TABLE dim_objective IS 'An achievement desired by an agent. Example: Create new jobs in the energy sector.';


CREATE OR REPLACE TABLE dim_event (
    event_id            INT             NOT NULL,
    event_type          VARCHAR(100),    -- education / consultation / workshop
    admin_div_3_id      INT,
    plan_id             INT,
    phase_id            INT,
    tool_id             INT,
    event_date          DATE,
    event_time          TIME,
    event_location      VARCHAR(500),
    description         VARCHAR(2000),
    total_participants  INT,
    loaded_at           TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_event PRIMARY KEY (event_id),
    CONSTRAINT fk_event_neighbourhood FOREIGN KEY (admin_div_3_id)
        REFERENCES dim_admin_div_3 (admin_div_3_id),
    CONSTRAINT fk_event_plan FOREIGN KEY (plan_id)
        REFERENCES dim_plan (plan_id)
    -- Note: phase_id and tool_id FKs added after those tables are created
);

COMMENT ON TABLE dim_event IS 'An occurrence (meeting, workshop, educational event) linked to a plan, phase, and geographic area.';


CREATE OR REPLACE TABLE dim_decision (
    decision_id     INT             NOT NULL,
    plan_id         INT,
    person_id       INT,
    organisation_id INT,
    event_id        INT,
    description     VARCHAR(2000),
    loaded_at       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_decision PRIMARY KEY (decision_id),
    CONSTRAINT fk_decision_plan FOREIGN KEY (plan_id)
        REFERENCES dim_plan (plan_id),
    CONSTRAINT fk_decision_person FOREIGN KEY (person_id)
        REFERENCES dim_person (person_id),
    CONSTRAINT fk_decision_org FOREIGN KEY (organisation_id)
        REFERENCES dim_organisation (organisation_id),
    CONSTRAINT fk_decision_event FOREIGN KEY (event_id)
        REFERENCES dim_event (event_id)
);

COMMENT ON TABLE dim_decision IS 'A conclusion reached after consideration. Outcome of an event, not the event itself.';


CREATE OR REPLACE TABLE dim_phase (
    phase_id            INT             NOT NULL,
    plan_id             INT             NOT NULL,
    phase_name          VARCHAR(200)    NOT NULL,
    phase_order         INT,
    building_type       VARCHAR(100),    -- social rented / detached / semi-detached
    total_households    INT,
    description         VARCHAR(2000),
    loaded_at           TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_phase PRIMARY KEY (phase_id),
    CONSTRAINT fk_phase_plan FOREIGN KEY (plan_id)
        REFERENCES dim_plan (plan_id)
);

COMMENT ON TABLE dim_phase IS 'Co-creation phase within a plan. Tracks residential building types and households involved.';


CREATE OR REPLACE TABLE dim_engagement_tool (
    tool_id             INT             NOT NULL,
    tool_name           VARCHAR(200)    NOT NULL,
    tool_type           VARCHAR(100),    -- survey / workshop / app / sensor
    description         VARCHAR(2000),
    loaded_at           TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_engagement_tool PRIMARY KEY (tool_id)
);

COMMENT ON TABLE dim_engagement_tool IS 'Engagement tool used to collect citizen data. Examples: mood survey app, air quality sensor, workshop feedback form.';


-- =============================================
-- 4. CITY OBJECTS
-- =============================================

CREATE OR REPLACE TABLE dim_nbs_project (
    nbs_id                          INT             NOT NULL,
    nbs_name                        VARCHAR(200)    NOT NULL,
    nbs_type                        VARCHAR(100),    -- green wall / green roof / bioswale / etc
    plan_id                         INT,
    location_id                     INT,
    description                     VARCHAR(2000),
    project_area_m2                 FLOAT,
    project_area_ha                 FLOAT,
    year_built                      INT,
    -- cost metrics
    installation_cost               FLOAT,
    maintenance_cost_annual         FLOAT,
    -- environmental impact
    co2_sequestration_potential_kg  FLOAT,           -- kg/year at maturity
    normalised_cost_per_m2_co2      FLOAT,           -- cost efficiency metric
    loaded_at                       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_nbs PRIMARY KEY (nbs_id),
    CONSTRAINT fk_nbs_plan FOREIGN KEY (plan_id)
        REFERENCES dim_plan (plan_id),
    CONSTRAINT fk_nbs_location FOREIGN KEY (location_id)
        REFERENCES dim_location (location_id)
);

COMMENT ON TABLE dim_nbs_project IS 'Nature-Based Solution implemented through a plan. Includes cost-benefit and CO2 sequestration metrics.';


CREATE OR REPLACE TABLE dim_sensor (
    sensor_id       INT             NOT NULL,
    sensor_type     VARCHAR(100),
    nbs_project_id  INT,
    location_id     INT,
    description     VARCHAR(500),
    loaded_at       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_sensor PRIMARY KEY (sensor_id),
    CONSTRAINT fk_sensor_nbs FOREIGN KEY (nbs_project_id)
        REFERENCES dim_nbs_project (nbs_id),
    CONSTRAINT fk_sensor_location FOREIGN KEY (location_id)
        REFERENCES dim_location (location_id)
);

COMMENT ON TABLE dim_sensor IS 'Individual sensor deployed in a city to monitor environmental conditions.';


-- =============================================
-- 5. ECONOMIC & METRICS
-- =============================================

CREATE OR REPLACE TABLE dim_metric (
    metric_id       INT             NOT NULL,
    metric_name     VARCHAR(200)    NOT NULL,
    metric_type     VARCHAR(100),    -- social / environmental / economic
    description     VARCHAR(2000),
    loaded_at       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_metric PRIMARY KEY (metric_id)
);

COMMENT ON TABLE dim_metric IS 'A measure of demography, characteristics, activity, or performance. Examples: deprivation index, traffic count, PM2.5 concentration.';


CREATE OR REPLACE TABLE dim_resource (
    resource_id     INT             NOT NULL,
    organisation_id INT,
    plan_id         INT,
    description     VARCHAR(2000),
    amount          FLOAT,
    currency        VARCHAR(3)      DEFAULT 'EUR',
    loaded_at       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_resource PRIMARY KEY (resource_id),
    CONSTRAINT fk_resource_org FOREIGN KEY (organisation_id)
        REFERENCES dim_organisation (organisation_id),
    CONSTRAINT fk_resource_plan FOREIGN KEY (plan_id)
        REFERENCES dim_plan (plan_id)
);

COMMENT ON TABLE dim_resource IS 'Resource available to an agent to allocate to services and plans. Examples: public funding, private investment.';


-- =============================================
-- 6. SOCIAL METRICS & SURVEYS
-- =============================================

CREATE OR REPLACE TABLE dim_public_statistics (
    stat_id                     INT             NOT NULL,
    admin_div_3_id              INT             NOT NULL,
    stat_type                   VARCHAR(100),    -- demographics / deprivation / health
    breakdown                   VARCHAR(2000),   -- demographic breakdown details
    source                      VARCHAR(200),
    reference_year              INT,
    -- demographic percentages
    population                  INT,
    ethnic_asian_pct            FLOAT,
    ethnic_black_pct            FLOAT,
    ethnic_white_pct            FLOAT,
    ethnic_mixed_pct            FLOAT,
    ethnic_other_pct            FLOAT,
    -- economic
    household_income_avg        FLOAT,
    deprivation_index           FLOAT,
    -- health metrics
    asthma_admissions_0_14      INT,
    asthma_admissions_15_64     INT,
    asthma_admissions_65_plus   INT,
    copd_admissions_65_plus     INT,
    loaded_at                   TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_public_statistics PRIMARY KEY (stat_id),
    CONSTRAINT fk_stats_neighbourhood FOREIGN KEY (admin_div_3_id)
        REFERENCES dim_admin_div_3 (admin_div_3_id)
);

COMMENT ON TABLE dim_public_statistics IS 'Demographics, economics, and health statistics at neighbourhood level. Used for 6+1 diversity analysis and health-pollution correlation.';


CREATE OR REPLACE TABLE dim_survey (
    survey_id           INT             NOT NULL,
    event_id            INT,
    person_id           INT,
    survey_type         VARCHAR(100),    -- mood / satisfaction / health
    contents            VARCHAR(4000),
    response_date       TIMESTAMP_NTZ,
    loaded_at           TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_survey PRIMARY KEY (survey_id),
    CONSTRAINT fk_survey_event FOREIGN KEY (event_id)
        REFERENCES dim_event (event_id),
    CONSTRAINT fk_survey_person FOREIGN KEY (person_id)
        REFERENCES dim_person (person_id)
);

COMMENT ON TABLE dim_survey IS 'Survey responses from participants. Examples: mood status, satisfaction surveys.';


CREATE OR REPLACE TABLE dim_citizen_response (
    response_id         INT             NOT NULL,
    event_id            INT,
    person_id           INT,
    tool_id             INT,
    response_content    VARCHAR(4000),
    response_date       TIMESTAMP_NTZ,
    loaded_at           TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_citizen_response PRIMARY KEY (response_id),
    CONSTRAINT fk_response_event FOREIGN KEY (event_id)
        REFERENCES dim_event (event_id),
    CONSTRAINT fk_response_person FOREIGN KEY (person_id)
        REFERENCES dim_person (person_id),
    CONSTRAINT fk_response_tool FOREIGN KEY (tool_id)
        REFERENCES dim_engagement_tool (tool_id)
);

COMMENT ON TABLE dim_citizen_response IS 'Citizen-generated data collected through engagement tools.';


-- =============================================
-- 7. CAMPAIGN & INTERVENTION TRACKING
-- =============================================

CREATE OR REPLACE TABLE dim_campaign (
    campaign_id         INT             NOT NULL,
    campaign_name       VARCHAR(200)    NOT NULL,
    campaign_type       VARCHAR(100),    -- transport / emissions / nbs / health
    admin_div_2_id      INT,             -- borough level
    start_date          DATE,
    end_date            DATE,
    description         VARCHAR(2000),
    target_metric       VARCHAR(100),    -- CO2 / NOx / PM2.5
    target_reduction_pct FLOAT,
    loaded_at           TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_campaign PRIMARY KEY (campaign_id),
    CONSTRAINT fk_campaign_borough FOREIGN KEY (admin_div_2_id)
        REFERENCES dim_admin_div_2 (admin_div_2_id)
);

COMMENT ON TABLE dim_campaign IS 'Policy campaigns and interventions (e.g., low emission zones, cycling initiatives). Tracks before/after impact.';


CREATE OR REPLACE TABLE dim_building (
    building_id         INT             NOT NULL,
    location_id         INT,
    building_type       VARCHAR(100),    -- residential / commercial / public
    building_use        VARCHAR(100),    -- housing / office / school / hospital
    year_built          INT,
    floor_area_m2       FLOAT,
    nbs_proximity_pre   FLOAT,           -- distance to nearest NBS before intervention (m)
    nbs_proximity_post  FLOAT,           -- distance to nearest NBS after intervention (m)
    loaded_at           TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_building PRIMARY KEY (building_id),
    CONSTRAINT fk_building_location FOREIGN KEY (location_id)
        REFERENCES dim_location (location_id)
);

COMMENT ON TABLE dim_building IS 'Buildings for NBS proximity analysis. Tracks pre/post intervention distance to nature.';


-- =============================================
-- 8. PANAS MOOD ASSESSMENT
-- =============================================

CREATE OR REPLACE TABLE dim_panas_score (
    panas_id            INT             NOT NULL,
    person_id           INT             NOT NULL,
    event_id            INT,
    track_id            VARCHAR(50),     -- links to sensor measurement route
    assessment_date     DATE            NOT NULL,
    status              VARCHAR(20),     -- before / after
    -- Positive Affect (PANAS_P)
    pa_lively           INT,             -- 1-5 scale
    pa_cheerful         INT,
    pa_happy            INT,
    pa_joyful           INT,
    pa_proud            INT,
    pa_total            INT,             -- sum of positive
    -- Negative Affect (PANAS_N)
    na_scared           INT,
    na_angry            INT,
    na_afraid           INT,
    na_miserable        INT,
    na_sad              INT,
    na_total            INT,             -- sum of negative
    loaded_at           TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_panas PRIMARY KEY (panas_id),
    CONSTRAINT fk_panas_person FOREIGN KEY (person_id)
        REFERENCES dim_person (person_id),
    CONSTRAINT fk_panas_event FOREIGN KEY (event_id)
        REFERENCES dim_event (event_id)
);

CREATE INDEX idx_panas_track ON dim_panas_score (track_id);

COMMENT ON TABLE dim_panas_score IS 'PANAS (Positive and Negative Affect Schedule) mood assessment scores. Links to walking routes for environmental-mood correlation.';
