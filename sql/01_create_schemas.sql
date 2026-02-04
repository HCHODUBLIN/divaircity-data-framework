-- ============================================
-- DivAirCity Data Framework
-- Schema Setup for Snowflake
-- ============================================
-- This script creates the database and schemas
-- following the medallion architecture pattern.
-- ============================================

-- Create database
CREATE DATABASE IF NOT EXISTS divaircity;
USE DATABASE divaircity;

-- Bronze: Raw ingested data (1:1 from sources)
CREATE SCHEMA IF NOT EXISTS bronze;

-- Silver: Cleaned, typed, deduplicated
CREATE SCHEMA IF NOT EXISTS silver;

-- Gold: Business-ready analytics tables
CREATE SCHEMA IF NOT EXISTS gold;

-- Utilities
CREATE SCHEMA IF NOT EXISTS utils;

COMMENT ON SCHEMA bronze IS 'Raw data ingested from city data sources, sensors, and surveys. Minimal transformation.';
COMMENT ON SCHEMA silver IS 'Cleaned and standardised dimension and fact tables with enforced data types and naming conventions.';
COMMENT ON SCHEMA gold IS 'Pre-joined, analytics-ready wide tables optimised for BI tools and end-user consumption.';
COMMENT ON SCHEMA utils IS 'Helper views, macros, and data quality monitoring.';
