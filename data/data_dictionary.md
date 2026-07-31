# Data Dictionary

## End-to-End Amazon Prime Customer Churn & Retention Analytics

### Project Type

Independent educational portfolio project using fully synthetic data.

### Assumed Role

**Customer Analytics Data Analyst — Amazon Prime Retention Team**

---

# 1. Purpose of This Document

This data dictionary explains the structure and business meaning of the six synthetic CSV files used in the project.

It allows a recruiter, analyst or reviewer to understand:

- What each file represents.
- What every column means.
- Which columns are primary and foreign keys.
- Which data types should be used after cleaning.
- Which values are allowed.
- How columns support churn, retention, engagement and customer-experience analysis.

The dictionary is based on the selected **ChatGPT-generated raw dataset ecosystem**.

---

# 2. Important Reading Notes

## 2.1 Raw Data Versus Processed Data

The files in `data/raw/` intentionally contain realistic data-quality issues such as:

- Exact duplicate rows.
- Duplicate primary-key values caused by those duplicate rows.
- Missing values.
- Invalid date strings.
- Leading or trailing spaces.
- Different capitalisation.
- Alternative spellings for the same category.

The data types shown in this dictionary are the **recommended cleaned analytical types**.

For example:

```text
Raw CSV value: "2026-06-30"
Recommended processed type: DATE
```

The raw files must remain unchanged. Cleaned and standardised versions will later be saved in:

```text
data/processed/
```

---

## 2.2 Primary-Key Rule

A primary key should uniquely identify one business record.

The raw files intentionally include exact duplicate rows. Therefore, the intended primary keys become unique only after exact duplicates are removed during cleaning.

---

## 2.3 Foreign-Key Rule

A foreign key connects one file to another.

Main relationships:

```text
customers.customer_id
    ├── memberships.customer_id
    ├── orders.customer_id
    ├── prime_video_activity.customer_id
    ├── payments.customer_id
    └── support_interactions.customer_id

memberships.membership_id
    └── payments.membership_id
```

---

## 2.4 Date Period

The current raw activity period is mainly:

**July 1, 2024 to June 30, 2026**

A small number of invalid date strings are intentionally included for cleaning practice.

---

## 2.5 Monetary Fields

The raw data currently contains normalised monetary values without an explicit currency column.

Before final reporting, the project should use one documented currency convention. The recommended simple approach is to treat the values as **USD-equivalent synthetic amounts** or add a `currency_code` field during processing.

---

# 3. Dataset Summary

| File Name | Raw Rows | Intended Unique Records | Main Grain | Intended Primary Key |
|---|---:|---:|---|---|
| `customers.csv` | 50,050 | 50,000 | One row per customer | `customer_id` |
| `memberships.csv` | 55,055 | 55,000 | One row per membership period | `membership_id` |
| `orders.csv` | 400,400 | 400,000 | One row per order | `order_id` |
| `prime_video_activity.csv` | 550,550 | 550,000 | One row per customer activity summary | `activity_id` |
| `payments.csv` | 125,125 | 125,000 | One row per payment attempt or transaction | `payment_id` |
| `support_interactions.csv` | 35,035 | 35,000 | One row per support ticket | `ticket_id` |

**Total raw rows:** 1,211,215  
**Total intended unique business records:** 1,210,000

---

# 4. Key Relationship Summary

| Parent File | Parent Key | Child File | Child Foreign Key | Relationship |
|---|---|---|---|---|
| `customers.csv` | `customer_id` | `memberships.csv` | `customer_id` | One customer can have one or more membership periods |
| `customers.csv` | `customer_id` | `orders.csv` | `customer_id` | One customer can place many orders |
| `customers.csv` | `customer_id` | `prime_video_activity.csv` | `customer_id` | One customer can have many video-activity records |
| `customers.csv` | `customer_id` | `payments.csv` | `customer_id` | One customer can make many payment attempts |
| `customers.csv` | `customer_id` | `support_interactions.csv` | `customer_id` | One customer can create many support tickets |
| `memberships.csv` | `membership_id` | `payments.csv` | `membership_id` | One membership can have many payment attempts |

---

# 5. Column-Level Data Dictionary

## 5.1 `customers.csv`

### File Purpose

Contains one master record per customer. It stores customer profile, geography, acquisition, device and account-level information.

### File Grain

**One row per customer after duplicate removal**

### Key Notes

- Intended primary key: `customer_id`
- Raw rows: 50,050
- Intended unique customers: 50,000
- Raw file contains 50 exact duplicate rows
- `customer_id` is referenced by all five other datasets

| File Name | Column Name | Description | Data Type | Example Value | Primary Key | Foreign Key | Allowed Values or Rule | Business Meaning |
|---|---|---|---|---|---|---|---|---|

| customers.csv | `customer_id` | Unique identifier assigned to each customer. | STRING | `CUST025026` | Yes — intended unique after duplicate removal | No | Pattern: `CUST` followed by 6 digits | Connects all customer behaviour, membership, payment and support records. |
| customers.csv | `signup_date` | Date on which the customer account was created. | DATE (raw CSV text) | `2025-09-22` | No | No | Valid date on or before the reporting date; current valid raw range: 2024-07-01 to 2026-06-15 | Supports signup trends, customer age, tenure and cohort analysis. |
| customers.csv | `country` | Customer's country or primary market. | STRING | `India` | No | No | Australia, Brazil, Canada, Germany, India, Japan, Mexico, United Kingdom, United States | Supports geographic churn, retention and customer-distribution analysis. |
| customers.csv | `state` | Customer's state, province or regional area. | STRING | `West Bengal` | No | No | Valid region matching `country`; missing values allowed in raw data | Provides more detailed geographic segmentation. |
| customers.csv | `city_tier` | Simplified classification of the customer's city or market size. | STRING | `Tier 1` | No | No | Metro, Tier 1, Tier 2, Tier 3 | Helps compare customer behaviour across large and smaller markets. |
| customers.csv | `age_group` | Customer age range rather than exact age. | STRING | `45-54` | No | No | 18-24, 25-34, 35-44, 45-54, 55-64, 65+ | Supports demographic segmentation while avoiding exact personal age. |
| customers.csv | `preferred_language` | Customer's preferred communication or interface language. | STRING | `English` | No | No | Bengali, English, French, German, Hindi, Japanese, Mandarin, Marathi, Portuguese, Spanish, Tamil, Telugu, Welsh; missing allowed in raw data | Supports language-based engagement and communication analysis. |
| customers.csv | `acquisition_channel` | Channel through which the customer was acquired. | STRING | `Paid Advertising` | No | No | Canonical values: Amazon Shopping, Device Promotion, Organic Search, Paid Advertising, Referral, Social Media, Student Promotion; raw spelling/case variants require standardisation | Measures customer acquisition quality and churn by source. |
| customers.csv | `primary_device` | Device most commonly associated with the customer. | STRING | `Mobile` | No | No | Canonical values: Desktop, Fire TV, Game Console, Mobile, Smart TV, Tablet; raw case and spacing variants require standardisation | Supports device-based engagement, churn and experience analysis. |
| customers.csv | `email_marketing_opt_in` | Whether the customer agreed to receive marketing emails. | BOOLEAN (raw Yes/No text) | `No` | No | No | Yes, No | Indicates whether email-based retention communication is permitted in the fictional scenario. |
| customers.csv | `account_status` | Current high-level customer-account state. | STRING | `Inactive` | No | No | Active, Closed, Inactive, Suspended | Supports descriptive account analysis; must be excluded from the churn model because it can act as outcome leakage. |

## 5.2 `memberships.csv`

### File Purpose

Contains membership periods, plan details, renewal settings, status and churn-related outcomes.

### File Grain

**One row per membership period after duplicate removal**

A customer can have more than one membership record because of renewal, plan change or rejoining.

### Key Notes

- Intended primary key: `membership_id`
- Foreign key: `customer_id`
- Raw rows: 55,055
- Intended unique memberships: 55,000
- Raw file contains 55 exact duplicate rows
- The latest valid membership determines the customer's current membership status

| File Name | Column Name | Description | Data Type | Example Value | Primary Key | Foreign Key | Allowed Values or Rule | Business Meaning |
|---|---|---|---|---|---|---|---|---|

| memberships.csv | `membership_id` | Unique identifier for a membership period. | STRING | `MEM0005338` | Yes — intended unique after duplicate removal | Referenced by `payments.membership_id` | Pattern: `MEM` followed by 7 digits | Identifies a specific membership period and links it to payment activity. |
| memberships.csv | `customer_id` | Identifier of the customer who owns the membership. | STRING | `CUST004843` | No | Yes → `customers.customer_id` | Must exist in `customers.csv` | Connects membership history with the customer's full behaviour. |
| memberships.csv | `membership_start_date` | Date on which the membership period began. | DATE (raw CSV text) | `2025-03-24` | No | No | Valid date on or before reporting date; current range: 2024-07-01 to 2026-06-15 | Used to calculate membership tenure and identify the latest valid membership. |
| memberships.csv | `plan_type` | Type of Prime membership plan. | STRING | `Prime Trial` | No | No | Canonical values: Prime Standard, Prime Student, Prime Trial; raw case/space variants require standardisation | Supports churn, renewal and engagement comparisons by plan. |
| memberships.csv | `billing_cycle` | Membership billing frequency. | STRING | `Trial` | No | No | Annual, Monthly, Trial | Determines payment frequency, renewal opportunity and expected membership fee. |
| memberships.csv | `membership_fee` | Fee charged for the membership period in the project's normalised currency. | NUMERIC(10,2) | `0.00` | No | No | Non-negative amount; current raw range: 0.00 to 139.00 | Supports membership revenue, plan-value and revenue-at-risk analysis. |
| memberships.csv | `auto_renew_enabled` | Whether automatic membership renewal is enabled. | BOOLEAN (raw Yes/No text) | `No` | No | No | Yes, No; missing values allowed in raw data | Important churn-risk and renewal-behaviour indicator. |
| memberships.csv | `renewal_date` | Raw renewal-related date supplied by the generator. | DATE (raw CSV text) | `2025-10-25` | No | No | Valid date; current valid raw range: 2024-08-05 to 2026-06-30; semantic meaning must be clarified during cleaning | Supports renewal analysis; recommended to rename to `last_renewal_date` and derive `next_renewal_date`. |
| memberships.csv | `membership_end_date` | Date on which a membership ended or was recorded to end. | DATE, nullable (raw CSV text) | `2025-10-25` | No | No | Valid date on/after start date; null for many active memberships | Used to classify ended memberships, but must not be used as a model input because it can reveal churn. |
| memberships.csv | `membership_status` | Recorded membership state. | STRING | `Cancelled` | No | No | Canonical values: Active, Cancelled, Expired, Paused, Payment Pending; raw variants include Canceled and case/space differences | Used for descriptive membership status and churn-label creation; excluded from model inputs. |
| memberships.csv | `cancellation_date` | Date on which cancellation became effective. | DATE, nullable (raw CSV text) | `2025-10-25` | No | No | Valid date for cancelled memberships; otherwise null | Directly identifies a churn event and therefore must be excluded from model inputs. |
| memberships.csv | `cancellation_reason` | Recorded reason associated with cancellation or non-renewal. | STRING, nullable | `Switched Service` | No | No | Content Dissatisfaction, Delivery Issues, Low Usage, Payment Failure, Switched Service, Temporary Membership, Too Expensive, Unknown | Explains simulated churn drivers; recommended processed name: `churn_reason`. Excluded from model inputs. |
| memberships.csv | `discount_applied` | Promotion or discount attached to the membership. | STRING | `Welcome Offer` | No | No | Device Bundle, No Discount, Prime Day Offer, Promo Code, Retention Offer, Student Discount, Welcome Offer; missing values allowed in raw data | Supports offer, acquisition and retention-response analysis. |

## 5.3 `orders.csv`

### File Purpose

Contains customer shopping transactions, delivery experience, return behaviour and estimated Prime shipping savings.

### File Grain

**One row per order after duplicate removal**

### Key Notes

- Intended primary key: `order_id`
- Foreign key: `customer_id`
- Raw rows: 400,400
- Intended unique orders: 400,000
- Raw file contains 400 exact duplicate rows

| File Name | Column Name | Description | Data Type | Example Value | Primary Key | Foreign Key | Allowed Values or Rule | Business Meaning |
|---|---|---|---|---|---|---|---|---|

| orders.csv | `order_id` | Unique identifier assigned to each order. | STRING | `ORD000014115` | Yes — intended unique after duplicate removal | No | Pattern: `ORD` followed by 9 digits | Identifies one shopping transaction. |
| orders.csv | `customer_id` | Identifier of the customer who placed the order. | STRING | `CUST036423` | No | Yes → `customers.customer_id` | Must exist in `customers.csv` | Connects shopping behaviour with membership and churn. |
| orders.csv | `order_date` | Date on which the order was placed. | DATE (raw CSV text) | `2025-10-20` | No | No | Valid date within analysis period; current valid range: 2024-07-01 to 2026-06-30 | Supports shopping recency, frequency, trends and feature-window calculations. |
| orders.csv | `order_value` | Total value of the order in the project's normalised currency. | NUMERIC(12,2) | `42.35` | No | No | Positive amount; current raw range: 3.00 to 1,019.13 | Supports spending, average order value and customer-value analysis. |
| orders.csv | `product_category` | Primary category of products in the order. | STRING, nullable | `Fashion` | No | No | Canonical values: Apparel, Appliances, Automotive, Baby, Beauty, Books, Electronics, Fashion, Grocery, Health & Personal Care, Home & Kitchen, Pet Supplies, Sports & Outdoors, Toys & Games; raw spelling/case variants require standardisation | Supports category-level shopping and churn analysis. |
| orders.csv | `items_count` | Number of items included in the order. | INTEGER | `3` | No | No | Positive integer; current raw range: 1 to 12 | Measures order size and purchasing intensity. |
| orders.csv | `delivery_speed` | Selected or delivered shipping-speed category. | STRING, nullable | `Standard` | No | No | Canonical values: Same-Day, One-Day, Two-Day, Standard; raw variants such as 2-Day and case/spacing differences require standardisation | Supports delivery-experience and Prime-benefit analysis. |
| orders.csv | `delivered_late_flag` | Whether an eligible delivery arrived late. | BOOLEAN (raw Yes/No text) | `No` | No | No | Yes, No | Used to calculate Late Delivery Rate and study delivery-related churn. |
| orders.csv | `returned_flag` | Whether the order was returned. | BOOLEAN (raw Yes/No text) | `No` | No | No | Yes, No | Used to calculate Return Rate and analyse customer experience. |
| orders.csv | `shipping_fee_saved` | Estimated shipping fee saved through Prime benefits. | NUMERIC(10,2), nullable | `2.20` | No | No | Non-negative amount; current raw range: 0.00 to 20.68; missing values allowed in raw data | Measures shopping-related benefit value received by the customer. |
| orders.csv | `order_status` | Current or final order state. | STRING | `Delivered` | No | No | Cancelled, Delivered, In Transit, Returned | Determines which orders are eligible for spending, delivery and return KPIs. |

## 5.4 `prime_video_activity.csv`

### File Purpose

Contains customer-level Prime Video engagement records, including content, watch time, sessions and completion.

### File Grain

**One row per customer activity summary after duplicate removal**

The activity record represents a customer-content-date engagement summary rather than an individual video event.

### Key Notes

- Intended primary key: `activity_id`
- Foreign key: `customer_id`
- Raw rows: 550,550
- Intended unique activity records: 550,000
- Raw file contains 550 exact duplicate rows

| File Name | Column Name | Description | Data Type | Example Value | Primary Key | Foreign Key | Allowed Values or Rule | Business Meaning |
|---|---|---|---|---|---|---|---|---|

| prime_video_activity.csv | `activity_id` | Unique identifier assigned to a Prime Video activity record. | STRING | `VIDACT000384221` | Yes — intended unique after duplicate removal | No | Pattern: `VIDACT` followed by 9 digits | Identifies one customer video-engagement summary. |
| prime_video_activity.csv | `customer_id` | Identifier of the customer who performed the activity. | STRING | `CUST045533` | No | Yes → `customers.customer_id` | Must exist in `customers.csv` | Connects video engagement with membership, shopping and churn. |
| prime_video_activity.csv | `activity_date` | Date on which the viewing activity occurred. | DATE (raw CSV text) | `2026-06-27` | No | No | Valid date within analysis period; current valid range: 2024-07-02 to 2026-06-30 | Supports video recency, trends and machine-learning feature windows. |
| prime_video_activity.csv | `content_type` | High-level format of the viewed content. | STRING | `Movie` | No | No | Canonical values: Channel, Documentary, Kids, Live Channel, Live Sports, Movie, TV Series; raw case and singular/plural variants require standardisation | Supports engagement comparison by viewing format. |
| prime_video_activity.csv | `genre` | Primary genre associated with the activity record. | STRING, nullable | `Sci-Fi` | No | No | Action, Adventure, Animation, Basketball, Biography, Comedy, Cricket, Crime, Drama, Educational, Entertainment, Family, Football, History, Horror, Lifestyle, Motorsport, Music, Nature, News, Reality, Romance, Sci-Fi, Science, Sports, Tennis, Thriller, True Crime | Supports content-preference, recommendation and churn analysis. |
| prime_video_activity.csv | `watch_minutes` | Total minutes watched in the activity record. | NUMERIC(10,2) | `74.10` | No | No | Positive value; current raw range: 2.00 to 720.00 | Core Prime Video engagement metric used for watch hours and churn features. |
| prime_video_activity.csv | `sessions_count` | Number of viewing sessions represented by the activity row. | INTEGER | `2` | No | No | Positive integer; current raw range: 1 to 7 | Measures viewing frequency. |
| prime_video_activity.csv | `titles_watched` | Number of distinct titles watched in the activity record. | INTEGER | `1` | No | No | Positive integer; current raw range: 1 to 9 | Measures content breadth and engagement. |
| prime_video_activity.csv | `completion_rate` | Proportion of viewed content completed. | NUMERIC(5,3), nullable | `0.617` | No | No | Value from 0.00 to 1.00; current raw range: 0.03 to 1.00; missing values allowed | Measures depth of content engagement. |
| prime_video_activity.csv | `device_type` | Device used for Prime Video activity. | STRING, nullable | `Mobile` | No | No | Canonical values: Desktop, Fire TV, Game Console, Mobile, Smart TV, Tablet; raw case/spacing variants require standardisation | Supports device-level engagement and user-experience analysis. |

## 5.5 `payments.csv`

### File Purpose

Contains membership payment attempts, outcomes, failures, retries and refunds.

### File Grain

**One row per payment attempt or transaction after duplicate removal**

### Key Notes

- Intended primary key: `payment_id`
- Foreign keys: `membership_id`, `customer_id`
- Raw rows: 125,125
- Intended unique payments: 125,000
- Raw file contains 125 exact duplicate rows

| File Name | Column Name | Description | Data Type | Example Value | Primary Key | Foreign Key | Allowed Values or Rule | Business Meaning |
|---|---|---|---|---|---|---|---|---|

| payments.csv | `payment_id` | Unique identifier assigned to a payment attempt or transaction. | STRING | `PAY000041447` | Yes — intended unique after duplicate removal | No | Pattern: `PAY` followed by 9 digits | Identifies a specific membership payment event. |
| payments.csv | `membership_id` | Identifier of the membership associated with the payment. | STRING | `MEM0037364` | No | Yes → `memberships.membership_id` | Must exist in `memberships.csv` | Connects payment outcomes to a specific membership period. |
| payments.csv | `customer_id` | Identifier of the customer associated with the payment. | STRING | `CUST033980` | No | Yes → `customers.customer_id` | Must exist in `customers.csv` and agree with the membership owner | Connects payment risk with the complete customer profile. |
| payments.csv | `payment_date` | Date on which the payment attempt or transaction occurred. | DATE (raw CSV text) | `2026-04-16` | No | No | Valid date within analysis period; current valid range: 2024-07-01 to 2026-06-30 | Supports payment recency, failure trends and feature-window calculations. |
| payments.csv | `payment_amount` | Payment amount in the project's normalised currency. | NUMERIC(10,2) | `20.65` | No | No | Non-negative amount; current raw range: 0.00 to 139.00 | Supports membership revenue and revenue-at-risk calculations. |
| payments.csv | `payment_method` | Method used for the payment. | STRING, nullable | `Credit Card` | No | No | Canonical values: Bank Account/Transfer, Credit Card, Debit Card, Digital Wallet/Wallet, Gift Balance, UPI; raw case and naming variants require standardisation | Supports payment-method performance and failure analysis. |
| payments.csv | `payment_status` | Outcome or current state of the payment. | STRING | `Successful` | No | No | Canonical values: Failed, Pending, Refunded, Successful; raw case/space variants require standardisation | Used to calculate Payment Failure Rate and identify involuntary-churn signals. |
| payments.csv | `failure_reason` | Reason a payment attempt failed. | STRING, nullable | `Payment Method Disabled` | No | No | Authentication Failed, Bank Declined, Expired Card, Insufficient Funds, Payment Method Disabled, Technical Error; should normally be null for non-failed payments | Explains simulated payment problems and supports targeted retention actions. |
| payments.csv | `retry_count` | Number of retry attempts associated with the payment. | INTEGER | `0` | No | No | Whole number from 0 to 2 in the current raw data | Measures repeated payment difficulty and involuntary-churn risk. |
| payments.csv | `refund_flag` | Whether the payment was refunded. | BOOLEAN (raw Yes/No text) | `No` | No | No | Yes, No | Separates refunded payments from retained membership revenue. |

## 5.6 `support_interactions.csv`

### File Purpose

Contains customer-support tickets, issue types, channels, resolution time, satisfaction and repeat-contact behaviour.

### File Grain

**One row per support ticket after duplicate removal**

### Key Notes

- Intended primary key: `ticket_id`
- Foreign key: `customer_id`
- Raw rows: 35,035
- Intended unique support tickets: 35,000
- Raw file contains 35 exact duplicate rows

| File Name | Column Name | Description | Data Type | Example Value | Primary Key | Foreign Key | Allowed Values or Rule | Business Meaning |
|---|---|---|---|---|---|---|---|---|

| support_interactions.csv | `ticket_id` | Unique identifier assigned to a support ticket. | STRING | `TKT00016822` | Yes — intended unique after duplicate removal | No | Pattern: `TKT` followed by 8 digits | Identifies one customer-service interaction. |
| support_interactions.csv | `customer_id` | Identifier of the customer who created the support ticket. | STRING | `CUST022702` | No | Yes → `customers.customer_id` | Must exist in `customers.csv` | Connects support experience with membership, engagement and churn. |
| support_interactions.csv | `ticket_date` | Date on which the support ticket was created. | DATE (raw CSV text) | `2025-11-10` | No | No | Valid date within analysis period; current valid range: 2024-07-07 to 2026-06-30 | Supports support-volume, recency and churn-driver analysis. |
| support_interactions.csv | `issue_category` | Main reason for the support interaction. | STRING | `Delivery Problem` | No | No | Canonical values: Account Access, Cancellation Request, Delivery Problem, General Question, Membership Billing, Payment Failure, Prime Video Issue, Refund Request; raw synonyms/case variants require standardisation | Identifies the customer problems most associated with churn. |
| support_interactions.csv | `support_channel` | Channel used to contact support. | STRING, nullable | `Chat` | No | No | Canonical values: Chat, Email, Help Center, Phone, Social Media; raw spelling/case variants require standardisation | Supports channel performance and service-experience analysis. |
| support_interactions.csv | `priority` | Assigned ticket priority. | STRING, nullable | `High` | No | No | Critical, High, Medium, Low | Indicates issue urgency and supports resolution-time analysis. |
| support_interactions.csv | `resolution_hours` | Number of hours required to resolve the ticket. | NUMERIC(10,2), nullable | `19.11` | No | No | Positive value for resolved tickets; current raw range: 0.25 to 157.26; null for unresolved tickets | Used to calculate Average Support Resolution Time. |
| support_interactions.csv | `resolved_flag` | Whether the ticket was resolved. | BOOLEAN (raw Yes/No text) | `Yes` | No | No | Yes, No | Distinguishes resolved from unresolved support cases. |
| support_interactions.csv | `satisfaction_score` | Customer satisfaction rating for the support interaction. | INTEGER, nullable | `4` | No | No | 1, 2, 3, 4, 5; null when no valid rating exists | Measures service satisfaction and its relationship with retention. |
| support_interactions.csv | `repeat_contact_flag` | Whether the customer needed to contact support again for the issue. | BOOLEAN (raw Yes/No text) | `No` | No | No | Yes, No | Used to calculate Repeat Contact Rate and identify unresolved customer friction. |
---

# 6. Raw Category Standardisation Guide

The raw files intentionally contain alternative values. During cleaning, convert them to the canonical values below.

## 6.1 Customer Category Standardisation

| Raw Examples | Canonical Value |
|---|---|
| `Paid Ads`, `Paid Advertising` | `Paid Advertising` |
| `Device promo`, `Device Promotion` | `Device Promotion` |
| `Student Promo`, `Student Promotion` | `Student Promotion` |
| `amazon shopping` | `Amazon Shopping` |
| `organic search` | `Organic Search` |
| `Social media` | `Social Media` |
| `referral ` | `Referral` |
| `Fire tv` | `Fire TV` |
| `SmartTV` | `Smart TV` |
| `desktop ` | `Desktop` |
| `game console` | `Game Console` |
| `mobile` | `Mobile` |
| `tablet` | `Tablet` |

---

## 6.2 Membership Category Standardisation

| Raw Examples | Canonical Value |
|---|---|
| `prime standard` | `Prime Standard` |
| `Prime student` | `Prime Student` |
| `Prime trial ` | `Prime Trial` |
| `Canceled` | `Cancelled` |
| `active` | `Active` |
| `expired` | `Expired` |
| `paused ` | `Paused` |
| `payment pending` | `Payment Pending` |

---

## 6.3 Order Category Standardisation

| Raw Examples | Canonical Value |
|---|---|
| `electronics` | `Electronics` |
| `grocery ` | `Grocery` |
| `Health and Personal Care` | `Health & Personal Care` |
| `Home and Kitchen` | `Home & Kitchen` |
| `Sports and Outdoors` | `Sports & Outdoors` |
| `Toys and Games` | `Toys & Games` |
| `Same Day`, `Same-Day` | `Same-Day` |
| `One-Day`, `one-day` | `One-Day` |
| `2-Day`, `Two-Day` | `Two-Day` |
| `standard ` | `Standard` |

---

## 6.4 Prime Video Category Standardisation

| Raw Examples | Canonical Value |
|---|---|
| `movie` | `Movie` |
| `documentary` | `Documentary` |
| `kids ` | `Kids` |
| `TV series` | `TV Series` |
| `Live Sport`, `Live Sports` | `Live Sports` |
| Device spelling/case variants | Same device standards used in `customers.csv` |

---

## 6.5 Payment Category Standardisation

| Raw Examples | Canonical Value |
|---|---|
| `credit card` | `Credit Card` |
| `Debit card` | `Debit Card` |
| `upi` | `UPI` |
| `Gift balance ` | `Gift Balance` |
| `Bank transfer`, `Bank Account` | Choose one documented standard, recommended `Bank Transfer` |
| `Wallet`, `Digital Wallet` | Choose one documented standard, recommended `Digital Wallet` |
| `failed ` | `Failed` |
| `refunded` | `Refunded` |
| `successful` | `Successful` |

---

## 6.6 Support Category Standardisation

| Raw Examples | Canonical Value |
|---|---|
| `Account Login`, `Account Access` | `Account Access` |
| `Cancel Request`, `Cancellation Request` | `Cancellation Request` |
| `Delivery issue`, `Delivery Problem` | `Delivery Problem` |
| `General query`, `General Question` | `General Question` |
| `membership billing` | `Membership Billing` |
| `payment failure` | `Payment Failure` |
| `Prime video issue` | `Prime Video Issue` |
| `refund request ` | `Refund Request` |
| `e-mail` | `Email` |
| `Help centre` | `Help Center` |
| `chat` | `Chat` |
| `phone ` | `Phone` |
| `social media` | `Social Media` |

---

# 7. Required Data-Quality Rules

The following rules should be implemented during Phase 8.

## 7.1 Key Rules

- Remove exact duplicate rows.
- Confirm each primary key is unique after duplicate removal.
- Confirm every foreign key exists in its parent table.
- Confirm `payments.customer_id` matches the owner of `payments.membership_id`.

## 7.2 Date Rules

- Convert valid dates to proper date types.
- Convert impossible values such as `2025-02-30`, `2026-13-05`, `31/31/2025` and `not_available` to null before deciding whether to repair or remove them.
- Ensure activity dates do not occur before customer signup.
- Ensure membership end and cancellation dates do not occur before membership start.
- Ensure model features use no information after the scoring date.

## 7.3 Numeric Rules

- Monetary values must not be negative.
- `items_count`, `sessions_count` and `titles_watched` must be positive integers.
- `completion_rate` must remain between 0 and 1.
- `satisfaction_score` must remain between 1 and 5.
- `resolution_hours` must be positive when present.
- `retry_count` must be a non-negative integer.

## 7.4 Business-Logic Rules

- Only delivered orders should be eligible for late-delivery calculations.
- Returned orders must have a consistent returned flag and status.
- Failure reasons should normally exist only for failed payments.
- Resolved tickets should have valid resolution hours.
- Missing satisfaction scores must remain null and must not be replaced with zero.
- Free-trial payments should be excluded from normal paid-membership revenue unless a clear charging rule is documented.
- `account_status`, `membership_status`, `cancellation_date`, `membership_end_date`, `cancellation_reason` and `churn_flag` must not be used as churn-model inputs.

---

# 8. Recommended Processed Data Types

| General Field Type | Recommended BigQuery Type |
|---|---|
| Identifier | `STRING` |
| Category or label | `STRING` |
| Date | `DATE` |
| Yes/No flag | `BOOL` |
| Whole-number count | `INT64` |
| Currency or decimal amount | `NUMERIC` |
| Rate or score with decimals | `FLOAT64` or `NUMERIC` |

---

# 9. How This Dictionary Will Be Used

This file will guide:

- Python data validation and cleaning.
- BigQuery staging-table creation.
- Data-quality checks.
- Analytics-table design.
- Customer-level `customer_360` creation.
- Churn-feature engineering.
- Power BI field descriptions.
- GitHub project documentation.

When a source column is renamed, removed or redefined, this dictionary should be updated before the later project layers are changed.

---

# 10. Educational Disclaimer

This is an independent educational portfolio project created to demonstrate customer analytics, Python, SQL, cloud data warehousing, machine learning and Power BI skills.

Amazon and Amazon Prime are trademarks of Amazon.com, Inc. This project is not affiliated with, endorsed by or sponsored by Amazon.

All data documented here is fully synthetic and generated solely for educational purposes. It does not contain actual Amazon customer information, confidential business data, proprietary metrics or internal records.

The column definitions, categories, allowed values, business rules and data relationships are simplified assumptions designed for this portfolio project. They must not be interpreted as Amazon's actual data model or internal business definitions.
