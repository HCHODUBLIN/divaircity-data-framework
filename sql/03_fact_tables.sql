-- ============================================
-- DivAirCity Data Framework
-- Fact Tables (Silver Schema)
-- ============================================
-- Primary fact table: sensor_measurement
-- Grain: one row per sensor reading
-- ============================================

USE DATABASE divaircity;
USE SCHEMA silver;

-- =============================================
-- FACT: SENSOR MEASUREMENT
-- Grain: one measurement per sensor per timestamp
-- This is the core analytical table.
-- =============================================

CREATE OR REPLACE TABLE fact_sensor_measurement (
    measurement_id  INT             NOT NULL,
    sensor_id       INT             NOT NULL,
    metric_id       INT             NOT NULL,
    person_id       INT,                        -- reporter/carrier (nullable)
    track_id        VARCHAR(50),                -- route tracking ID (e.g., TRACKER_1)
    collection_date DATE            NOT NULL,
    collection_time TIME,
    value           FLOAT,
    unit            VARCHAR(50),
    -- route tracking fields
    distance_m      FLOAT,                      -- cumulative distance in meters
    latitude        FLOAT,
    longitude       FLOAT,
    status          VARCHAR(20),                -- before / after (for pre-post analysis)
    description     VARCHAR(500),
    loaded_at       TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_measurement PRIMARY KEY (measurement_id),
    CONSTRAINT fk_meas_sensor FOREIGN KEY (sensor_id)
        REFERENCES dim_sensor (sensor_id),
    CONSTRAINT fk_meas_metric FOREIGN KEY (metric_id)
        REFERENCES dim_metric (metric_id),
    CONSTRAINT fk_meas_person FOREIGN KEY (person_id)
        REFERENCES dim_person (person_id)
);

CREATE INDEX idx_measurement_track ON fact_sensor_measurement (track_id);
CREATE INDEX idx_measurement_date ON fact_sensor_measurement (collection_date);

COMMENT ON TABLE fact_sensor_measurement IS 'Time-series sensor readings with route tracking. Supports mobile sensor data (walking routes) and stationary measurements.';


-- =============================================
-- FACT: EVENT PARTICIPATION
-- Grain: one row per person per event
-- Tracks who participated in co-creation events
-- =============================================

CREATE OR REPLACE TABLE fact_event_participation (
    participation_id    INT             NOT NULL,
    event_id            INT             NOT NULL,
    person_id           INT             NOT NULL,
    organisation_id     INT,
    role                VARCHAR(100),    -- facilitator / participant / observer
    loaded_at           TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_participation PRIMARY KEY (participation_id),
    CONSTRAINT fk_part_event FOREIGN KEY (event_id)
        REFERENCES dim_event (event_id),
    CONSTRAINT fk_part_person FOREIGN KEY (person_id)
        REFERENCES dim_person (person_id),
    CONSTRAINT fk_part_org FOREIGN KEY (organisation_id)
        REFERENCES dim_organisation (organisation_id)
);

COMMENT ON TABLE fact_event_participation IS 'Tracks participation in co-creation events. Used for 6+1 diversity analysis of engagement across demographic groups.';


-- =============================================
-- FACT: SURVEY RESPONSE
-- Grain: one row per survey response
-- Tracks survey answers and sentiment analysis
-- =============================================

CREATE OR REPLACE TABLE fact_survey_response (
    response_id         INT             NOT NULL,
    survey_id           INT             NOT NULL,
    event_id            INT,
    person_id           INT,
    tool_id             INT,
    response_date       DATE            NOT NULL,
    key_phrases         VARCHAR(2000),
    sentiment_score     FLOAT,           -- -1.0 to 1.0
    sentiment_label     VARCHAR(50),     -- positive / negative / neutral
    loaded_at           TIMESTAMP_NTZ   DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_survey_response PRIMARY KEY (response_id),
    CONSTRAINT fk_sr_survey FOREIGN KEY (survey_id)
        REFERENCES dim_survey (survey_id),
    CONSTRAINT fk_sr_event FOREIGN KEY (event_id)
        REFERENCES dim_event (event_id),
    CONSTRAINT fk_sr_person FOREIGN KEY (person_id)
        REFERENCES dim_person (person_id),
    CONSTRAINT fk_sr_tool FOREIGN KEY (tool_id)
        REFERENCES dim_engagement_tool (tool_id)
);

COMMENT ON TABLE fact_survey_response IS 'Survey response analysis with sentiment scoring. Used for text analysis of citizen feedback.';
