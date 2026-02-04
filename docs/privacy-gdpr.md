# Data Privacy & GDPR Compliance

This data model was designed in accordance with the **GDPR and ethics guidelines** established for the DivAirCity project. The privacy requirements were defined in Deliverable 2.3, developed by Blockchain Intelligence (K. Miller, A. de la Mata) as part of WP2.

> ⚠️ **Note:** All data in this repository is **mock/synthetic data** for demonstration purposes. No real personal data is included.

## Privacy-Aware Design Decisions

| GDPR Principle                  | Implementation in This Framework                                                                                               |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| **Data Minimisation**           | `dim_person` stores only `person_id` with no directly identifying attributes (e.g. name, email)                                |
| **Special Category Protection** | Diversity attributes (`is_ethnic_minority`, `is_lgbtq`, `is_disability`) stored at `dim_community` level, not individual level |
| **Anonymisation**               | Person-level data linked through surrogate keys; no PII stored in any table                                                    |
| **Purpose Limitation**          | Separate fact tables for different analytical purposes (participation vs. measurements vs. surveys)                            |
| **Storage Limitation**          | `loaded_at` timestamps on all tables to support data retention policies                                                        |

## Sensitive Data Handling

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

Diversity attributes are intentionally modelled at the community level to avoid individual-level exposure of special category data.

## Health Data Considerations

- `dim_public_statistics`: Contains **aggregated** health metrics (asthma/COPD admissions) at neighbourhood level, not individual level
- `dim_panas_score`: Mood assessments linked via `person_id` surrogate key; informed consent would be required in a production setting

## WP2 Deliverable Ownership

| Deliverable                           | Scope                              | Lead                                               |
| ------------------------------------- | ---------------------------------- | -------------------------------------------------- |
| **D2.2** - Data Management Framework  | Entity specifications, ERD, KPIs   | EcoWise (H. Cho, WP2 Leader)                       |
| **D2.3** - Ethics & GDPR Requirements | Privacy guidelines, risk framework | Blockchain Intelligence (K. Miller, A. de la Mata) |

This repo implements D2.2, applying the privacy requirements defined in D2.3.

## Reference Documents

- **D2.3** - Ethics, Privacy and Security Data Management Requirements (DivAirCity, 2022)
- **GDPR** - Regulation (EU) 2016/679
- **HRBAD** - UN Human Rights-Based Approach to Data principles
- **ALLEA** - European Code of Conduct for Research Integrity
- **Project website** – https://divaircity.eu/
