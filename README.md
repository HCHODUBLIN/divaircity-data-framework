# DivAirCity Urban Data Framework

**End-to-end data modeling and pipeline implementation for a multi-city EU Horizon 2020 sustainability project.**

## Project Context

The [DivAirCity project](https://divaircity.eu/) (EU Horizon 2020, Grant No. 101003799) analysed diversity, inclusion, and air quality across 5 European pilot cities (Orvieto, Potsdam, Aarhus, Castellon, Bucharest) plus London as an additional data source. The project required a unified data framework to manage urban data spanning social, environmental, and economic domains.

**My role:** As **Senior Urban Data Analytics Expert at EcoWise** and **WP2 Leader**, I designed the conceptual data model and entity specifications for the project's data management framework (Deliverable 2.2), defining 25 entities with full attribute specifications, relationship diagrams, and 60+ KPI/indicator methodologies based on [BSI PAS 182 Smart City Concept Model](https://www.bsigroup.com/en-GB/smart-cities/smart-cities-pas-182/) standards.

**This repo:** A personal portfolio project that reconstructs the original framework as a working data pipeline using **dbt + Snowflake**. Demonstrates the full journey from conceptual model → physical schema → dbt transformation pipeline. All data has been replaced with **mock/synthetic data** for demonstration purposes.

## What This Demonstrates

| Skill | Implementation |
|-------|---------------|
| **Conceptual Data Modeling** | ERD with normalized dimensional hierarchies based on BSI PAS 182 |
| **Snowflake Schema Design** | Geographic hierarchy: Country → City → Borough → Neighbourhood → Location |
| **Star Schema / Fact-Dimension** | `fact_sensor_measurement`, `fact_event_participation`, `fact_survey_response` |
| **SQL DDL** | Snowflake-dialect `CREATE TABLE` with PK/FK constraints and data types |
| **dbt Transformation** | Staging → Intermediate → Marts (medallion-aligned) |
| **Data Visualization** | Power BI dashboards with geospatial mapping, sentiment analysis, KPI tracking |
| **Data Governance** | Entity specifications with data types, relationships, and usage notes |

## Architecture

```
Conceptual Model (BSI PAS 182)
        │
        ▼
┌─────────────────────┐
│   ERD / Data Model   │  ← docs/erd/
│   22 entities,       │
│   6 domains          │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│   Snowflake DDL      │  ← sql/
│   CREATE TABLE       │
│   with PK/FK         │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│   dbt Project        │  ← dbt_project/
│   staging → marts    │
│   medallion arch.    │
└─────────────────────┘
```

## Data Model Overview

The framework organises urban data into six domains:

### 1. Geospatial Boundaries (Snowflake Schema)
- `COUNTRY` → `ADMIN_DIV_1` (city) → `ADMIN_DIV_2` (borough) → `ADMIN_DIV_3` (neighbourhood) → `LOCATION`

### 2. Agents
- `COMMUNITY` (6+1 diversity groups)
- `ORGANISATION`
- `PERSON`

### 3. Co-creation Governance
- `PLAN`, `PHASE`, `OBJECTIVE`
- `ENGAGEMENT_TOOL`
- `EVENT`, `DECISION`

### 4. Social Metrics & Surveys
- `PUBLIC_STATISTICS` (demographics)
- `SURVEY`
- `CITIZEN_RESPONSE`

### 5. City Objects & Environmental
- `NBS_PROJECT` (Nature-Based Solutions)
- `SENSOR`
- `SENSOR_MEASUREMENT`

### 6. Economic
- `RESOURCE`, `METRIC`

> See [`docs/erd/divaircity_erd.mermaid`](docs/erd/divaircity_erd.mermaid) for the full entity-relationship diagram.

## Dashboards

Interactive Power BI dashboards built on top of the data model. See [`docs/dashboards/data_map_exercise.pdf`](docs/dashboards/data_map_exercise.pdf).

| Dashboard | Description |
|-----------|-------------|
| **Co-creation Process Monitoring** | Participant tracking by city, 6+1 diversity groups, engagement tools |
| **Text Analysis** | Sentiment analysis of citizen feedback, word clouds, key phrase extraction |
| **Environmental Health Sensor** | Air quality along walking routes, PANAS mood scores |
| **Ethnic Groups & Air Pollution** | Geographic correlation between demographics, income, and PM2.5 |
| **Postcode-level Air Pollution** | Time-series PM10, PM2.5, NOx by London postcodes |
| **Health & Air Pollution** | Asthma admissions correlated with pollution levels by borough |
| **Carbon Emissions Transport** | Campaign impact tracking, avoided CO2/NO2 over time |
| **NBS Impact Analysis** | Nature-Based Solutions cost-benefit, CO2 sequestration potential |

## Repo Structure

```
DivAirCity/
├── README.md
├── .gitignore
├── data/
│   └── raw/                             # Raw data sources (gitignored)
│       ├── environmental/               # Emissions, air pollution, UHI
│       ├── indicators/                  # KPI definitions
│       ├── transportation/              # Cycling, walking data
│       ├── health/                      # Health indicators
│       └── carbon/                      # Decarbonization data
├── docs/
│   ├── dashboards/
│   │   └── data_map_exercise.pdf        # Power BI dashboard export
│   ├── erd/
│   │   └── divaircity_erd.mermaid       # ERD (renders on GitHub)
│   └── reference/
│       ├── appendix_3_entity_specs.txt  # Full entity specifications
│       └── original_diagrams/           # Original Miro diagrams
├── sql/
│   ├── 01_create_schemas.sql            # Snowflake schema setup
│   ├── 02_dimension_tables.sql          # 19 dimension tables
│   ├── 03_fact_tables.sql               # 3 fact tables
│   └── 04_sample_queries.sql            # Analytical queries
└── dbt_project/
    ├── dbt_project.yml
    ├── models/
    │   ├── staging/                      # Bronze → Silver
    │   ├── intermediate/                 # Business logic
    │   └── marts/                        # Gold (analytics-ready)
    └── seeds/                            # Reference data (CSV)
```

## Data Privacy & GDPR Compliance

This data model was designed in accordance with the **GDPR and ethics guidelines** established for the DivAirCity project. The privacy requirements were defined in Deliverable 2.3, developed by Blockchain Intelligence (K. Miller, A. de la Mata) as part of WP2.

I applied these guidelines when designing the data framework to ensure privacy-by-design principles for handling sensitive urban data.

> ⚠️ **Note:** All data in this repository is **mock/synthetic data** for demonstration purposes. No real personal data is included.

### Privacy-Aware Design Decisions

| GDPR Principle | Implementation in This Framework |
|----------------|----------------------------------|
| **Data Minimisation** | `dim_person` stores only `person_id` with no directly identifying attributes (name, email, etc.) |
| **Special Category Protection** | Diversity attributes (`is_ethnic_minority`, `is_lgbtq`, `is_disability`) stored at `dim_community` level, not individual level |
| **Anonymisation** | Person-level data linked through surrogate keys; no PII columns in any table |
| **Purpose Limitation** | Separate fact tables for different analytical purposes (participation vs. measurements vs. surveys) |
| **Storage Limitation** | `loaded_at` timestamps on all tables to support data retention policies |

### Sensitive Data Handling

The framework handles **special categories of personal data** (GDPR Article 9):

```
dim_community (aggregate level)          dim_person (individual level)
├── is_women                             ├── person_id (surrogate key)
├── is_youth                             ├── community_id (FK)
├── is_elders                            └── organisation_id (FK)
├── is_lgbtq
├── is_ethnic_minority                   → No PII stored at person level
├── is_disability                        → Diversity tracked at community level
└── is_economically_disadvantaged        → Enables aggregate analysis without individual exposure
```

### Health Data Considerations

- `dim_public_statistics`: Contains **aggregated** health metrics (asthma/COPD admissions) at neighbourhood level, not individual level
- `dim_panas_score`: Mood assessments linked via `person_id` surrogate key; requires informed consent in production

### WP2 Deliverable Ownership

| Deliverable | Scope | Lead |
|-------------|-------|------|
| **D2.2** - Data Management Framework | Entity specifications, ERD, KPIs | EcoWise (H. Cho, WP2 Leader) |
| **D2.3** - Ethics & GDPR Requirements | Privacy guidelines, risk framework | Blockchain Intelligence (K. Miller, A. de la Mata) |

This repo implements D2.2, applying the privacy requirements defined in D2.3.

### Reference Documents

- **D2.3** - Ethics, Privacy and Security Data Management Requirements (DivAirCity, 2022)
- **GDPR** - Regulation (EU) 2016/679
- **HRBAD** - UN Human Rights-Based Approach to Data principles
- **ALLEA** - European Code of Conduct for Research Integrity
- **Project website** - [divaircity.eu](https://divaircity.eu/)

## Key Design Decisions

### Why Snowflake Schema for Geography?
The geographic hierarchy is normalised into separate dimension tables because:
- Cities report data at different administrative levels
- Each level has its own attributes (population, area) updated independently
- Cross-city comparisons require consistent geographic granularity

### Why Star Schema for Measurements?
`fact_sensor_measurement` uses a classic star schema because:
- High-volume time-series data (sensor readings every 15 minutes)
- Query patterns are analytical: aggregate by time, location, sensor type
- Wide denormalised table in the marts layer for end-user consumption

### Why Medallion Architecture in dbt?
- **Staging (Bronze→Silver):** Clean, rename, type-cast raw source data
- **Intermediate:** Apply business logic, resolve relationships
- **Marts (Gold):** Pre-joined wide tables optimised for BI tools and analysts

## Tech Stack

- **Data Warehouse:** Snowflake
- **Transformation:** dbt (data build tool)
- **Modeling Standard:** BSI PAS 182 Smart City Concept Model
- **Source Project:** EU Horizon 2020 DivAirCity (Grant No. 101003799)

## About

This repository is a **personal portfolio project** reconstructed from my work on the DivAirCity project.

- **Original work:** Conceptual data model and entity specifications (D2.2) designed during the project
- **Portfolio reconstruction:** SQL DDL and dbt pipeline newly implemented for this portfolio to demonstrate end-to-end data engineering capabilities
- **Data:** All data in this repo is **mock/synthetic data** — no real project data is included

---

*This is a personal portfolio project based on my work during the DivAirCity project (EU Horizon 2020, Grant No. 101003799). All implementations and data in this repository are newly created for demonstration purposes.*
