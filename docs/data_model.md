# Data Model

## Project

**End-to-End Amazon Prime Customer Churn & Retention Analytics**

This project uses a simple BigQuery data model to support:

- Customer churn and retention analysis
- Customer segmentation
- Feature engineering
- Machine-learning predictions
- Power BI reporting

> This is an independent educational portfolio project. It is not affiliated with Amazon and does not use real, proprietary, or confidential Amazon customer data.

---

## Data-Model Overview

The project uses three BigQuery datasets:

```text
amazon_prime_staging
        ↓
amazon_prime_analytics
        ↓
amazon_prime_reporting
```

| Dataset | Purpose |
|---|---|
| `amazon_prime_staging` | Stores cleaned CSV data with explicit column types |
| `amazon_prime_analytics` | Stores dimensions, facts, customer-level analytical tables, and prediction outputs |
| `amazon_prime_reporting` | Stores final views used by Power BI |

---

## Source Data

The model starts from six cleaned CSV files:

| File | Main purpose |
|---|---|
| `customers.csv` | Customer profile and acquisition information |
| `memberships.csv` | Membership plan, status, renewal, and cancellation information |
| `orders.csv` | Shopping orders and delivery behaviour |
| `prime_video_activity.csv` | Prime Video engagement |
| `payments.csv` | Membership payment attempts and failures |
| `support_interactions.csv` | Customer support and satisfaction activity |

---

# 1. Staging Layer

Dataset:

```text
amazon_prime_staging
```

The staging layer contains cleaned source data with minimal transformation.

## Staging Tables

### `customers`

**Grain:** One row per customer

**Primary key:**

```text
customer_id
```

Important fields:

```text
customer_id
signup_date
country
state
city_tier
age_group
preferred_language
acquisition_channel
primary_device
email_marketing_opt_in
account_status
```

---

### `memberships`

**Grain:** One row per membership record

**Primary key:**

```text
membership_id
```

**Foreign key:**

```text
customer_id → customers.customer_id
```

Important fields:

```text
membership_id
customer_id
membership_start_date
plan_type
billing_cycle
membership_fee
auto_renew_enabled
renewal_date
membership_end_date
membership_status
cancellation_date
cancellation_reason
discount_applied
```

---

### `orders`

**Grain:** One row per order

**Primary key:**

```text
order_id
```

**Foreign key:**

```text
customer_id → customers.customer_id
```

Important fields:

```text
order_id
customer_id
order_date
order_value
product_category
items_count
delivery_speed
delivered_late_flag
returned_flag
shipping_fee_saved
order_status
```

Optimisation:

```text
Clustered by customer_id
```

Date partitioning was not used in the BigQuery Sandbox because historical partitions expire automatically.

---

### `prime_video_activity`

**Grain:** One row per customer activity record

**Primary key:**

```text
activity_id
```

**Foreign key:**

```text
customer_id → customers.customer_id
```

Important fields:

```text
activity_id
customer_id
activity_date
content_type
genre
watch_minutes
sessions_count
titles_watched
completion_rate
device_type
```

Optimisation:

```text
Clustered by customer_id
```

---

### `payments`

**Grain:** One row per payment attempt

**Primary key:**

```text
payment_id
```

**Foreign keys:**

```text
customer_id → customers.customer_id
membership_id → memberships.membership_id
```

Important fields:

```text
payment_id
membership_id
customer_id
payment_date
payment_amount
payment_method
payment_status
failure_reason
retry_count
refund_flag
```

Optimisation:

```text
Clustered by customer_id
```

---

### `support_interactions`

**Grain:** One row per support ticket

**Primary key:**

```text
ticket_id
```

**Foreign key:**

```text
customer_id → customers.customer_id
```

Important fields:

```text
ticket_id
customer_id
ticket_date
issue_category
support_channel
priority
resolution_hours
resolved_flag
satisfaction_score
repeat_contact_flag
```

Optimisation:

```text
Clustered by customer_id
```

---

# 2. Analytics Layer

Dataset:

```text
amazon_prime_analytics
```

The analytics layer contains a simple star schema and customer-level analytical tables.

---

## Star Schema

```text
                    dim_date
                       │
                       │
dim_customer ─── fact_memberships ─── dim_membership_plan
      │
      ├────────── fact_orders
      │
      ├────────── fact_video_activity
      │
      ├────────── fact_payments
      │
      └────────── fact_support_interactions
```

The model also includes:

```text
customer_360
customer_segments
customer_risk_predictions
```

These wide tables simplify customer-level analysis, machine learning, and Power BI reporting.

---

# Dimension Tables

## `dim_date`

**Grain:** One row per calendar date

**Primary key:**

```text
date_key
```

Date range:

```text
2024-07-01 to 2026-06-30
```

Important fields:

```text
date_key
full_date
day_number
day_name
week_number
month_number
month_name
quarter_number
year_number
month_start_date
is_weekend
```

---

## `dim_customer`

**Grain:** One row per customer

**Primary key:**

```text
customer_id
```

Important fields:

```text
customer_id
signup_date
country
state
city_tier
age_group
preferred_language
acquisition_channel
primary_device
email_marketing_opt_in
account_status
```

Optimisation:

```text
Clustered by customer_id
```

---

## `dim_membership_plan`

**Grain:** One row per unique plan and billing-cycle combination

**Primary key:**

```text
membership_plan_key
```

Important fields:

```text
membership_plan_key
plan_type
billing_cycle
```

---

# Fact Tables

## `fact_memberships`

**Grain:** One row per membership record

**Primary key:**

```text
membership_id
```

**Foreign keys:**

```text
customer_id → dim_customer.customer_id
membership_plan_key → dim_membership_plan.membership_plan_key
membership_start_date_key → dim_date.date_key
renewal_date_key → dim_date.date_key
membership_end_date_key → dim_date.date_key
cancellation_date_key → dim_date.date_key
```

Important measures and attributes:

```text
membership_fee
auto_renew_enabled
membership_status
cancellation_reason
discount_applied
```

---

## `fact_orders`

**Grain:** One row per order

**Primary key:**

```text
order_id
```

**Foreign keys:**

```text
customer_id → dim_customer.customer_id
order_date_key → dim_date.date_key
```

Important measures:

```text
order_value
items_count
shipping_fee_saved
delivered_late_flag
returned_flag
```

Optimisation:

```text
Clustered by customer_id
```

---

## `fact_video_activity`

**Grain:** One row per customer video-activity record

**Primary key:**

```text
activity_id
```

**Foreign keys:**

```text
customer_id → dim_customer.customer_id
activity_date_key → dim_date.date_key
```

Important measures:

```text
watch_minutes
sessions_count
titles_watched
completion_rate
```

Optimisation:

```text
Clustered by customer_id
```

---

## `fact_payments`

**Grain:** One row per payment attempt

**Primary key:**

```text
payment_id
```

**Foreign keys:**

```text
customer_id → dim_customer.customer_id
membership_id → fact_memberships.membership_id
payment_date_key → dim_date.date_key
```

Important measures:

```text
payment_amount
retry_count
refund_flag
payment_status
```

Optimisation:

```text
Clustered by customer_id
```

---

## `fact_support_interactions`

**Grain:** One row per support ticket

**Primary key:**

```text
ticket_id
```

**Foreign keys:**

```text
customer_id → dim_customer.customer_id
ticket_date_key → dim_date.date_key
```

Important measures:

```text
resolution_hours
satisfaction_score
resolved_flag
repeat_contact_flag
```

Optimisation:

```text
Clustered by customer_id
```

---

# 3. Customer-Level Analytical Tables

## `customer_360`

**Grain:** One row per customer

`customer_360` combines customer profile, latest membership information, shopping activity, Prime Video usage, payments, support behaviour, and churn status.

Important fields:

```text
customer_id
signup_date
country
age_group
acquisition_channel
primary_device
plan_type
membership_status
tenure_months
total_orders
total_order_value
average_order_value
late_delivery_rate
return_rate
total_video_watch_minutes
video_sessions
benefits_used_count
payment_failures
support_tickets
average_satisfaction_score
days_since_last_order
days_since_last_video_activity
auto_renew_enabled
churn_flag
```

Main uses:

- SQL analysis
- KPI calculations
- Churn-driver analysis
- Customer segmentation
- Feature engineering
- Power BI reporting

Important note:

```text
membership_status
churn_flag
account_status
```

must not be used as machine-learning input features because they reveal or strongly indicate the final outcome.

---

## `customer_segments`

**Grain:** One row per customer

Important fields:

```text
customer_id
customer_segment
total_orders
video_watch_hours
benefits_used_count
payment_failures
support_tickets
satisfaction_score
days_since_last_activity
churn_flag
```

Segments:

```text
Multi-Benefit Power Users
Shopping-First Members
Video-First Members
New Members
Low-Engagement Members
Service-Risk Members
Payment-Risk Members
Churned Members
```

---

## `customer_risk_predictions`

**Grain:** One row per customer eligible for churn prediction

Important fields:

```text
customer_id
churn_probability
risk_level
top_risk_driver
recommended_action
membership_revenue_at_risk
```

Risk groups:

```text
Low Risk    → probability below 0.30
Medium Risk → probability from 0.30 to below 0.70
High Risk   → probability 0.70 or higher
```

This table is produced by the machine-learning workflow and loaded into BigQuery for Power BI reporting.

---

# 4. Reporting Layer

Dataset:

```text
amazon_prime_reporting
```

Power BI connects only to the reporting views.

## Reporting Views

| View | Purpose |
|---|---|
| `vw_executive_kpis` | Executive KPI cards |
| `vw_churn_retention_trends` | Monthly churn and retention trends |
| `vw_customer_segments` | Customer-segment analysis |
| `vw_churn_drivers` | Churn-rate analysis by driver band |
| `vw_retention_cohorts` | Membership cohort-retention matrix |
| `vw_customer_risk_predictions` | Customer-level churn risk and actions |
| `vw_retention_actions` | Recommended-action summary |

This keeps the Power BI model small and easy to understand.

Power BI does not need to import every staging, dimension, or fact table.

---

# 5. Main Relationships

| From | To | Relationship |
|---|---|---|
| `dim_customer.customer_id` | `fact_memberships.customer_id` | One-to-many |
| `dim_customer.customer_id` | `fact_orders.customer_id` | One-to-many |
| `dim_customer.customer_id` | `fact_video_activity.customer_id` | One-to-many |
| `dim_customer.customer_id` | `fact_payments.customer_id` | One-to-many |
| `dim_customer.customer_id` | `fact_support_interactions.customer_id` | One-to-many |
| `dim_membership_plan.membership_plan_key` | `fact_memberships.membership_plan_key` | One-to-many |
| `dim_date.date_key` | Fact date-key columns | One-to-many |
| `fact_memberships.membership_id` | `fact_payments.membership_id` | One-to-many |

BigQuery does not enforce these relationships as traditional database constraints. They are validated through SQL data-quality checks.

---

# 6. Table Grain Summary

| Table | Grain |
|---|---|
| `dim_date` | One row per date |
| `dim_customer` | One row per customer |
| `dim_membership_plan` | One row per plan and billing cycle |
| `fact_memberships` | One row per membership |
| `fact_orders` | One row per order |
| `fact_video_activity` | One row per video-activity record |
| `fact_payments` | One row per payment attempt |
| `fact_support_interactions` | One row per support ticket |
| `customer_360` | One row per customer |
| `customer_segments` | One row per customer |
| `customer_risk_predictions` | One row per model-eligible customer |

---

# 7. Data Flow

```text
Synthetic CSV files
        ↓
Python validation and cleaning
        ↓
BigQuery staging tables
        ↓
SQL data-quality checks
        ↓
Dimensions and fact tables
        ↓
customer_360
        ↓
Customer segmentation
        ↓
Machine-learning feature dataset
        ↓
Churn model and risk predictions
        ↓
BigQuery reporting views
        ↓
Power BI dashboard
        ↓
Business recommendations
```

---

# 8. Design Decisions

## Simple star schema

The star schema demonstrates data-modelling skills while remaining easy to understand.

## Wide customer table

`customer_360` avoids repeatedly joining large fact tables for customer-level analysis.

## Reporting views

Power BI connects to prepared views instead of raw and analytics tables.

## BigQuery clustering

Large customer-activity tables are clustered by `customer_id` to support customer-level filtering and joins.

## No historical date partitioning in Sandbox

Date partitioning was removed because BigQuery Sandbox automatically expires historical partitions after 60 days.

## Leakage-safe machine-learning dataset

The churn model uses customer behaviour available before the scoring date and excludes fields that reveal the churn outcome.

---

# 9. Model and Reporting Dates

```text
Analysis period:
2024-07-01 to 2026-06-30

Machine-learning scoring date:
2026-05-31

Feature window:
2026-03-03 to 2026-05-31

Prediction window:
2026-06-01 to 2026-06-30

Reporting date:
2026-06-30
```

---

# 10. Related Project Files

```text
images/star_schema.png
images/architecture.png
sql/04_build_analytics_model.sql
sql/09_create_power_bi_views.sql
notebooks/03_feature_engineering.ipynb
notebooks/04_churn_modeling.ipynb
notebooks/05_model_explanation_and_retention_actions.ipynb
```

---

## Final Model Summary

The project uses two complementary approaches:

```text
Star schema
→ Supports structured SQL analysis and demonstrates data-modelling skills.

customer_360
→ Supports simple customer-level analysis, segmentation, machine learning, and reporting.
```

Together, they create a clear end-to-end analytics workflow from raw synthetic customer activity to business-ready retention actions.
