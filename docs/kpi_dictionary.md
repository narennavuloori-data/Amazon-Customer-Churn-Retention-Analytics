# KPI Dictionary

## End-to-End Amazon Prime Customer Churn & Retention Analytics

### Project Type

Independent educational portfolio project using fully synthetic data.

### Assumed Role

**Customer Analytics Data Analyst — Amazon Prime Retention Team**

---

# 1. Purpose of This Document

This document defines the key performance indicators used in the **End-to-End Amazon Prime Customer Churn & Retention Analytics** project.

A KPI, or Key Performance Indicator, is a measurable value that helps the business understand performance.

For example:

- **Total Customers** tells us the size of the customer base.
- **Churn Rate** tells us what percentage of members left.
- **Retention Rate** tells us what percentage of members stayed.
- **High-Risk Customers** tells us how many active members may churn soon.

This KPI dictionary ensures that every metric has one clear meaning across:

- Python analysis.
- BigQuery SQL.
- Machine-learning outputs.
- Power BI dashboards.
- GitHub documentation.
- Executive recommendations.

Without a KPI dictionary, two analysts may calculate the same metric differently. This document prevents that problem.

---

# 2. KPI Dictionary Structure

Each KPI includes:

| Field | Meaning |
|---|---|
| KPI ID | Unique identifier for the KPI |
| KPI Name | Business-friendly metric name |
| Category | Membership, Engagement, Experience or Prediction |
| Business Question | The question answered by the KPI |
| Definition | Simple explanation of the KPI |
| Formula | Business calculation |
| Required Fields | Dataset columns needed |
| Main Source Tables | Tables used to calculate the KPI |
| Reporting Grain | Level at which the KPI is calculated |
| Recommended Filters | Filters that can be applied |
| Display Format | How the KPI should appear |
| Interpretation | How to understand the result |
| Important Notes | Rules and limitations |

---

# 3. Common KPI Rules

These rules apply to the entire project.

## 3.1 Unique Customer Rule

A customer must be counted using:

`customer_id`

When counting customers, use a distinct customer count so the same person is not counted multiple times because of orders, payments or support tickets.

---

## 3.2 Reporting Date

The project should use a selected reporting date, also called an **analysis date** or **snapshot date**.

Recommended final reporting date:

**June 30, 2026**

This date determines:

- Whether a membership is active.
- How long a customer has been a member.
- How many days have passed since the last activity.
- Which customers are eligible for churn prediction.

---

## 3.3 Latest Membership Rule

When a customer has more than one membership record, the customer's latest valid membership should be used to determine the current membership status.

The latest membership can be identified using the most recent:

- `membership_start_date`, or
- `renewal_date`, depending on the final dataset structure.

The exact rule will be documented in:

`docs/churn_definition.md`

---

## 3.4 Churn Rule

A customer is generally considered churned when:

- The membership is cancelled, or
- The membership expires without a later renewal.

The detailed business and technical rules will be documented in:

`docs/churn_definition.md`

---

## 3.5 Eligible Customer Rule

Some KPI denominators should include only eligible customers.

Examples:

- Churn Rate should use customers who were active and at risk of churn.
- Renewal Rate should use memberships that reached a renewal opportunity.
- Prediction KPIs should use active customers who were scored by the model.

The denominator used by each KPI is defined separately below.

---

## 3.6 Date Filtering Rule

All time-based KPIs should respond to selected date filters where appropriate.

Examples:

- Monthly churn should use the selected month.
- Total orders should use orders inside the selected date range.
- Prime Video watch time should use activity inside the selected date range.
- Current active members should use membership status as of the reporting date.

---

## 3.7 Synthetic Data Rule

All KPI results are based on synthetic data.

The KPI values must not be presented as actual Amazon performance.

---

# 4. Membership KPIs

---

## KPI-M01 — Total Customers

| Field | Definition |
|---|---|
| KPI ID | KPI-M01 |
| KPI Name | Total Customers |
| Category | Membership |
| Business Question | How many unique customers are included in the analysis? |
| Definition | The total number of distinct customers in the selected reporting scope |
| Formula | Distinct count of `customer_id` |
| Required Fields | `customer_id` |
| Main Source Tables | `customers`, `dim_customer`, or `customer_360` |
| Reporting Grain | Overall, monthly signup cohort or selected customer group |
| Recommended Filters | Country, state, age group, acquisition channel, signup date, primary device |
| Display Format | Whole number with thousands separator |
| Power BI Visual | KPI card |
| Interpretation | A higher value means a larger customer population is included in the selected view |

### Business Formula

```text
Total Customers = Number of unique customer_id values
```

### Example

If the dataset contains 50,000 customer records and every `customer_id` is unique:

```text
Total Customers = 50,000
```

### Important Notes

- Do not count rows from orders or activity tables directly.
- One customer can have many orders, payments and video records.
- Always use a distinct customer count.

---

## KPI-M02 — Active Members

| Field | Definition |
|---|---|
| KPI ID | KPI-M02 |
| KPI Name | Active Members |
| Category | Membership |
| Business Question | How many customers currently have an active Prime membership? |
| Definition | The number of unique customers whose latest valid membership is active on the reporting date |
| Formula | Distinct count of eligible customers where latest membership status is Active |
| Required Fields | `customer_id`, `membership_status`, `membership_start_date`, `membership_end_date`, `renewal_date` |
| Main Source Tables | `memberships`, `fact_memberships`, `customer_360` |
| Reporting Grain | Reporting date, month, plan or customer group |
| Recommended Filters | Plan type, billing cycle, country, tenure band, acquisition channel, auto-renewal |
| Display Format | Whole number with thousands separator |
| Power BI Visual | KPI card |
| Interpretation | Shows the current fictional Prime membership base |

### Business Formula

```text
Active Members =
Distinct customers whose latest membership is active on the reporting date
```

### Important Notes

- Use only the latest valid membership for each customer.
- Do not count multiple membership records for the same customer.
- Customers with cancelled or expired latest memberships are not active.

---

## KPI-M03 — Churned Members

| Field | Definition |
|---|---|
| KPI ID | KPI-M03 |
| KPI Name | Churned Members |
| Category | Membership |
| Business Question | How many members cancelled or expired without renewal? |
| Definition | The number of unique customers classified as churned during the selected reporting period |
| Formula | Distinct count of customers where `churn_flag = 1` |
| Required Fields | `customer_id`, `membership_status`, `cancellation_date`, `membership_end_date`, `renewal_date`, `churn_flag` |
| Main Source Tables | `memberships`, `fact_memberships`, `customer_360` |
| Reporting Grain | Month, quarter, year or customer group |
| Recommended Filters | Churn month, plan, country, acquisition channel, tenure, cancellation reason |
| Display Format | Whole number with thousands separator |
| Power BI Visual | KPI card |
| Interpretation | Shows the number of customers lost during the selected period |

### Business Formula

```text
Churned Members =
Distinct customers classified as churned during the selected period
```

### Important Notes

- A customer should be counted once per churn event definition.
- Expired memberships should be treated as churn only when no later renewal exists.
- The final rule must match `docs/churn_definition.md`.

---

## KPI-M04 — Churn Rate

| Field | Definition |
|---|---|
| KPI ID | KPI-M04 |
| KPI Name | Churn Rate |
| Category | Membership |
| Business Question | What percentage of eligible members churned? |
| Definition | The percentage of members at risk of churn who cancelled or expired without renewal during the selected period |
| Formula | Churned Members ÷ Eligible Members at Start × 100 |
| Required Fields | `customer_id`, `churn_flag`, membership dates and status |
| Main Source Tables | `fact_memberships`, `customer_360`, reporting views |
| Reporting Grain | Month, quarter, year, plan or customer segment |
| Recommended Filters | Country, plan, tenure, acquisition channel, auto-renewal, segment |
| Display Format | Percentage with 1 or 2 decimal places |
| Power BI Visual | KPI card and line chart |
| Interpretation | A higher churn rate means a larger share of eligible members left |

### Preferred Business Formula

```text
Churn Rate (%) =
Churned Members During Period
÷
Eligible Active Members at Start of Period
× 100
```

### Example

If 1,500 members churned from 10,000 eligible members:

```text
Churn Rate = 1,500 ÷ 10,000 × 100 = 15%
```

### Important Notes

- Do not divide churned members by all historical customers.
- Use the member population that was actually at risk of churn.
- Monthly and annual churn rates should not be added together.
- Clearly label the time period used.

---

## KPI-M05 — Retention Rate

| Field | Definition |
|---|---|
| KPI ID | KPI-M05 |
| KPI Name | Retention Rate |
| Category | Membership |
| Business Question | What percentage of eligible members remained active? |
| Definition | The percentage of eligible members who stayed active through the selected period |
| Formula | Retained Members ÷ Eligible Members at Start × 100 |
| Required Fields | `customer_id`, membership dates, status, `churn_flag` |
| Main Source Tables | `fact_memberships`, `customer_360`, cohort tables |
| Reporting Grain | Month, quarter, year or cohort |
| Recommended Filters | Plan, country, acquisition channel, tenure, auto-renewal, segment |
| Display Format | Percentage with 1 or 2 decimal places |
| Power BI Visual | KPI card, line chart and cohort matrix |
| Interpretation | A higher retention rate means a larger share of members stayed |

### Business Formula

```text
Retention Rate (%) =
Retained Members
÷
Eligible Members at Start of Period
× 100
```

### Simplified Relationship

When churn and retention are measured using the same customer population and period:

```text
Retention Rate = 100% - Churn Rate
```

### Important Notes

- Use the same denominator as Churn Rate.
- Retention may also be calculated for cohorts at Month 1, Month 3, Month 6 and Month 12.
- Cohort retention and overall retention are related but not identical views.

---

## KPI-M06 — Renewal Rate

| Field | Definition |
|---|---|
| KPI ID | KPI-M06 |
| KPI Name | Renewal Rate |
| Category | Membership |
| Business Question | What percentage of memberships renewed when they became eligible for renewal? |
| Definition | The percentage of memberships that successfully renewed among memberships reaching a renewal opportunity |
| Formula | Successful Renewals ÷ Renewal-Eligible Memberships × 100 |
| Required Fields | `membership_id`, `customer_id`, `renewal_date`, `membership_status`, next membership record |
| Main Source Tables | `memberships`, `fact_memberships` |
| Reporting Grain | Renewal month, plan or billing cycle |
| Recommended Filters | Plan type, billing cycle, country, auto-renewal, tenure |
| Display Format | Percentage with 1 or 2 decimal places |
| Power BI Visual | KPI card and trend chart |
| Interpretation | A higher renewal rate means more eligible members continued their memberships |

### Business Formula

```text
Renewal Rate (%) =
Successfully Renewed Memberships
÷
Memberships Reaching Renewal Opportunity
× 100
```

### Example

If 8,400 out of 10,000 renewal-eligible memberships renewed:

```text
Renewal Rate = 8,400 ÷ 10,000 × 100 = 84%
```

### Important Notes

- Do not include customers whose renewal date has not arrived.
- Monthly plans and annual plans should be comparable only when the renewal opportunity is correctly identified.

---

## KPI-M07 — Average Membership Tenure

| Field | Definition |
|---|---|
| KPI ID | KPI-M07 |
| KPI Name | Average Membership Tenure |
| Category | Membership |
| Business Question | How long has the average customer remained a member? |
| Definition | The average number of months between membership start and either the reporting date or membership end date |
| Formula | Sum of customer tenure months ÷ Number of customers |
| Required Fields | `membership_start_date`, `membership_end_date`, reporting date |
| Main Source Tables | `memberships`, `customer_360` |
| Reporting Grain | Overall or customer group |
| Recommended Filters | Membership status, plan, country, acquisition channel, segment |
| Display Format | Decimal number followed by `months` |
| Power BI Visual | KPI card |
| Interpretation | Higher tenure generally indicates longer customer relationships |

### Customer-Level Formula

For an active member:

```text
Tenure =
Reporting Date - Membership Start Date
```

For a churned member:

```text
Tenure =
Membership End Date - Membership Start Date
```

### KPI Formula

```text
Average Membership Tenure =
Sum of Customer Tenure Months
÷
Number of Customers
```

### Important Notes

- Use one consistent unit, preferably months.
- Report whether tenure includes only active customers or all customers.
- For the executive KPI, use all eligible customers unless otherwise stated.

---

## KPI-M08 — Auto-Renewal Adoption Rate

| Field | Definition |
|---|---|
| KPI ID | KPI-M08 |
| KPI Name | Auto-Renewal Adoption Rate |
| Category | Membership |
| Business Question | What percentage of active members have auto-renewal enabled? |
| Definition | The percentage of eligible active members with auto-renewal enabled |
| Formula | Active Members with Auto-Renewal Enabled ÷ Eligible Active Members × 100 |
| Required Fields | `customer_id`, `auto_renew_enabled`, latest membership status |
| Main Source Tables | `memberships`, `customer_360` |
| Reporting Grain | Reporting date or customer group |
| Recommended Filters | Plan, billing cycle, country, tenure, acquisition channel |
| Display Format | Percentage with 1 or 2 decimal places |
| Power BI Visual | KPI card and bar chart |
| Interpretation | Higher adoption may indicate a lower risk of unplanned membership expiry |

### Business Formula

```text
Auto-Renewal Adoption Rate (%) =
Active Members with Auto-Renewal Enabled
÷
Eligible Active Members
× 100
```

### Important Notes

- Use the latest membership record.
- Use active members as the preferred denominator.
- This KPI does not prove that auto-renewal causes retention.

---

# 5. Engagement KPIs

---

## KPI-E01 — Orders per Customer

| Field | Definition |
|---|---|
| KPI ID | KPI-E01 |
| KPI Name | Orders per Customer |
| Category | Engagement |
| Business Question | How frequently does the average customer place orders? |
| Definition | The average number of valid orders placed per customer in the selected period |
| Formula | Total Valid Orders ÷ Customers in Scope |
| Required Fields | `order_id`, `customer_id`, `order_date`, `order_status` |
| Main Source Tables | `orders`, `fact_orders`, `customer_360` |
| Reporting Grain | Selected date period or customer group |
| Recommended Filters | Country, plan, segment, product category, order month |
| Display Format | Decimal number with 1 or 2 decimal places |
| Power BI Visual | KPI card and bar chart |
| Interpretation | Higher values indicate stronger shopping engagement |

### Business Formula

```text
Orders per Customer =
Total Valid Orders
÷
Unique Customers in Scope
```

### Example

If 120,000 valid orders were placed by 40,000 customers:

```text
Orders per Customer = 120,000 ÷ 40,000 = 3.0
```

### Important Notes

- Exclude cancelled or invalid orders.
- Clearly define whether customers with zero orders are included.
- For a customer-base KPI, include eligible customers with zero orders.

---

## KPI-E02 — Average Order Value

| Field | Definition |
|---|---|
| KPI ID | KPI-E02 |
| KPI Name | Average Order Value |
| Category | Engagement |
| Business Question | What is the average value of a valid order? |
| Definition | The average monetary value of valid orders in the selected period |
| Formula | Total Valid Order Value ÷ Total Valid Orders |
| Required Fields | `order_id`, `order_value`, `order_status` |
| Main Source Tables | `orders`, `fact_orders` |
| Reporting Grain | Selected period, category or customer group |
| Recommended Filters | Product category, plan, segment, country, order month |
| Display Format | Currency |
| Power BI Visual | KPI card and column chart |
| Interpretation | Higher values indicate greater spending per order |

### Business Formula

```text
Average Order Value =
Total Value of Valid Orders
÷
Number of Valid Orders
```

### Important Notes

- Exclude invalid and cancelled orders.
- Refund treatment must remain consistent.
- Use the project currency selected during dataset generation.

---

## KPI-E03 — Prime Video Watch Hours

| Field | Definition |
|---|---|
| KPI ID | KPI-E03 |
| KPI Name | Prime Video Watch Hours |
| Category | Engagement |
| Business Question | How much Prime Video content was watched? |
| Definition | Total Prime Video watch minutes converted into hours |
| Formula | Sum of Valid Watch Minutes ÷ 60 |
| Required Fields | `customer_id`, `activity_date`, `watch_minutes` |
| Main Source Tables | `prime_video_activity`, `fact_video_activity` |
| Reporting Grain | Day, month, customer or customer group |
| Recommended Filters | Genre, content type, device, plan, customer segment |
| Display Format | Decimal number followed by `hours` |
| Power BI Visual | KPI card and trend chart |
| Interpretation | Higher values indicate stronger Prime Video engagement |

### Business Formula

```text
Prime Video Watch Hours =
Total Valid Watch Minutes
÷
60
```

### Example

```text
12,000 watch minutes ÷ 60 = 200 watch hours
```

### Important Notes

- Exclude negative or impossible watch-duration values.
- Watch time should not exceed realistic daily limits.
- This is an engagement metric, not a measure of customer satisfaction.

---

## KPI-E04 — Active Customers

| Field | Definition |
|---|---|
| KPI ID | KPI-E04 |
| KPI Name | Active Customers |
| Category | Engagement |
| Business Question | How many customers performed at least one qualifying activity during the selected period? |
| Definition | Unique customers with at least one valid shopping or Prime Video activity during the selected period |
| Formula | Distinct customers with qualifying activity |
| Required Fields | `customer_id`, `order_date`, `activity_date`, valid activity status |
| Main Source Tables | `orders`, `prime_video_activity`, `customer_360` |
| Reporting Grain | Day, week or month |
| Recommended Filters | Activity type, country, plan, segment, device |
| Display Format | Whole number with thousands separator |
| Power BI Visual | KPI card and trend chart |
| Interpretation | Shows how many customers actively used at least one selected benefit |

### Recommended Qualification Rule

A customer is active during the period when the customer has at least one:

- Valid completed order, or
- Valid Prime Video activity record with positive watch time.

### Important Notes

- **Active Customers** is an engagement metric.
- **Active Members** is a membership-status metric.
- These two KPIs must not be treated as the same thing.

---

## KPI-E05 — Benefits Used per Customer

| Field | Definition |
|---|---|
| KPI ID | KPI-E05 |
| KPI Name | Benefits Used per Customer |
| Category | Engagement |
| Business Question | How many different Prime benefit types does the average customer use? |
| Definition | The average number of qualifying benefit categories used by each customer |
| Formula | Sum of Customer Benefit Counts ÷ Customers in Scope |
| Required Fields | Shopping activity, delivery savings, Prime Video activity, discount usage |
| Main Source Tables | `orders`, `prime_video_activity`, `memberships`, `customer_360` |
| Reporting Grain | Customer or customer group |
| Recommended Filters | Plan, country, tenure, segment, churn status |
| Display Format | Decimal number with 1 or 2 decimal places |
| Power BI Visual | KPI card and bar chart |
| Interpretation | Higher values indicate broader use of the Prime ecosystem |

### Proposed Benefit Categories

For this project, a customer may receive one point for using each of the following:

1. Shopping activity.
2. Delivery savings.
3. Prime Video activity.
4. Membership discount or promotion.

### Customer-Level Formula

```text
Benefits Used Count =
Shopping Used
+ Delivery Savings Used
+ Prime Video Used
+ Discount Used
```

Each condition contributes either:

```text
1 = Used
0 = Not Used
```

### KPI Formula

```text
Benefits Used per Customer =
Sum of Benefits Used Count
÷
Customers in Scope
```

### Important Notes

- Final benefit rules must be fixed before SQL implementation.
- Do not count the number of transactions; count distinct benefit types.

---

## KPI-E06 — Inactive Customer Rate

| Field | Definition |
|---|---|
| KPI ID | KPI-E06 |
| KPI Name | Inactive Customer Rate |
| Category | Engagement |
| Business Question | What percentage of eligible members have not used a qualifying benefit recently? |
| Definition | The percentage of eligible active members with no qualifying activity during the chosen inactivity window |
| Formula | Inactive Eligible Customers ÷ Eligible Active Members × 100 |
| Required Fields | `customer_id`, last order date, last video activity date, latest membership status |
| Main Source Tables | `orders`, `prime_video_activity`, `customer_360` |
| Reporting Grain | Reporting date or customer group |
| Recommended Filters | Plan, tenure, country, segment, auto-renewal |
| Display Format | Percentage with 1 or 2 decimal places |
| Power BI Visual | KPI card and bar chart |
| Interpretation | A higher rate means a larger share of active members are not recently engaged |

### Recommended Initial Inactivity Rule

A customer is inactive when:

```text
No valid order
and
No Prime Video activity
during the previous 30 days
```

### Business Formula

```text
Inactive Customer Rate (%) =
Inactive Eligible Customers
÷
Eligible Active Members
× 100
```

### Important Notes

- The inactivity period must be clearly labelled.
- The project may also analyse 60-day and 90-day inactivity bands.
- Inactivity does not automatically mean churn.

---

# 6. Customer Experience KPIs

---

## KPI-X01 — Late Delivery Rate

| Field | Definition |
|---|---|
| KPI ID | KPI-X01 |
| KPI Name | Late Delivery Rate |
| Category | Experience |
| Business Question | What percentage of delivered orders arrived late? |
| Definition | The percentage of eligible delivered orders marked as late |
| Formula | Late Delivered Orders ÷ Eligible Delivered Orders × 100 |
| Required Fields | `order_id`, `order_status`, `delivered_late_flag` |
| Main Source Tables | `orders`, `fact_orders` |
| Reporting Grain | Month, customer, category or customer group |
| Recommended Filters | Country, product category, plan, customer segment |
| Display Format | Percentage with 1 or 2 decimal places |
| Power BI Visual | KPI card and bar chart |
| Interpretation | A higher rate indicates a worse fictional delivery experience |

### Business Formula

```text
Late Delivery Rate (%) =
Orders Delivered Late
÷
Eligible Delivered Orders
× 100
```

### Important Notes

- Use only delivered orders in the denominator.
- Cancelled orders should not be included.
- The flag should be standardised to a Boolean value.

---

## KPI-X02 — Return Rate

| Field | Definition |
|---|---|
| KPI ID | KPI-X02 |
| KPI Name | Return Rate |
| Category | Experience |
| Business Question | What percentage of eligible orders were returned? |
| Definition | The percentage of valid completed or delivered orders marked as returned |
| Formula | Returned Orders ÷ Eligible Orders × 100 |
| Required Fields | `order_id`, `order_status`, `returned_flag` |
| Main Source Tables | `orders`, `fact_orders` |
| Reporting Grain | Month, category, customer or customer group |
| Recommended Filters | Product category, country, plan, segment |
| Display Format | Percentage with 1 or 2 decimal places |
| Power BI Visual | KPI card and bar chart |
| Interpretation | A higher return rate may indicate product or experience problems |

### Business Formula

```text
Return Rate (%) =
Returned Eligible Orders
÷
Eligible Completed or Delivered Orders
× 100
```

### Important Notes

- The denominator must use orders that could actually be returned.
- This KPI does not prove dissatisfaction by itself.

---

## KPI-X03 — Payment Failure Rate

| Field | Definition |
|---|---|
| KPI ID | KPI-X03 |
| KPI Name | Payment Failure Rate |
| Category | Experience |
| Business Question | What percentage of membership payment attempts failed? |
| Definition | The percentage of eligible payment attempts with a failed status |
| Formula | Failed Payment Attempts ÷ Total Eligible Payment Attempts × 100 |
| Required Fields | `payment_id`, `payment_status`, `payment_date` |
| Main Source Tables | `payments`, `fact_payments` |
| Reporting Grain | Month, customer, payment method or membership plan |
| Recommended Filters | Payment method, plan, country, auto-renewal, risk level |
| Display Format | Percentage with 1 or 2 decimal places |
| Power BI Visual | KPI card and trend chart |
| Interpretation | A higher value indicates greater payment-related membership risk |

### Business Formula

```text
Payment Failure Rate (%) =
Failed Payment Attempts
÷
Total Eligible Payment Attempts
× 100
```

### Important Notes

- Exclude test, duplicate or invalid payment records.
- Decide whether pending payments are included; recommended approach is to exclude unresolved pending payments.
- Multiple retries may create multiple payment attempts.

---

## KPI-X04 — Average Support Resolution Time

| Field | Definition |
|---|---|
| KPI ID | KPI-X04 |
| KPI Name | Average Support Resolution Time |
| Category | Experience |
| Business Question | How long does it take to resolve the average support interaction? |
| Definition | The average number of hours required to resolve eligible support tickets |
| Formula | Sum of Resolution Hours ÷ Resolved Tickets |
| Required Fields | `ticket_id`, `resolution_hours`, `resolved_flag` |
| Main Source Tables | `support_interactions`, `fact_support_interactions` |
| Reporting Grain | Month, issue category, priority or support channel |
| Recommended Filters | Issue category, support channel, priority, churn status |
| Display Format | Decimal number followed by `hours` |
| Power BI Visual | KPI card and bar chart |
| Interpretation | A lower value generally indicates faster support resolution |

### Business Formula

```text
Average Support Resolution Time =
Total Resolution Hours for Resolved Tickets
÷
Number of Resolved Tickets
```

### Important Notes

- Use resolved tickets only.
- Unresolved tickets should be measured separately.
- Remove negative or impossible resolution times.

---

## KPI-X05 — Average Satisfaction Score

| Field | Definition |
|---|---|
| KPI ID | KPI-X05 |
| KPI Name | Average Satisfaction Score |
| Category | Experience |
| Business Question | How satisfied were customers with support interactions? |
| Definition | The average valid customer-satisfaction score across eligible support interactions |
| Formula | Sum of Valid Satisfaction Scores ÷ Rated Interactions |
| Required Fields | `satisfaction_score`, `ticket_id` |
| Main Source Tables | `support_interactions`, `fact_support_interactions` |
| Reporting Grain | Month, issue category, support channel or customer group |
| Recommended Filters | Issue category, channel, priority, churn status, segment |
| Display Format | Decimal number with 1 or 2 decimal places |
| Power BI Visual | KPI card and bar chart |
| Interpretation | A higher score indicates better reported support satisfaction |

### Recommended Scale

```text
1 = Very Dissatisfied
2 = Dissatisfied
3 = Neutral
4 = Satisfied
5 = Very Satisfied
```

### Business Formula

```text
Average Satisfaction Score =
Total Valid Satisfaction Scores
÷
Number of Rated Support Interactions
```

### Important Notes

- Exclude missing satisfaction ratings.
- Validate that scores remain within the selected scale.
- Do not replace missing ratings with zero.

---

## KPI-X06 — Repeat Contact Rate

| Field | Definition |
|---|---|
| KPI ID | KPI-X06 |
| KPI Name | Repeat Contact Rate |
| Category | Experience |
| Business Question | What percentage of support interactions required repeated customer contact? |
| Definition | The percentage of eligible support interactions marked as repeat contacts |
| Formula | Repeat Contact Tickets ÷ Eligible Support Tickets × 100 |
| Required Fields | `ticket_id`, `repeat_contact_flag` |
| Main Source Tables | `support_interactions`, `fact_support_interactions` |
| Reporting Grain | Month, issue category, support channel or customer group |
| Recommended Filters | Issue category, channel, priority, churn status |
| Display Format | Percentage with 1 or 2 decimal places |
| Power BI Visual | KPI card and bar chart |
| Interpretation | A higher rate may indicate unresolved or complicated customer issues |

### Business Formula

```text
Repeat Contact Rate (%) =
Support Tickets Marked as Repeat Contact
÷
Eligible Support Tickets
× 100
```

### Important Notes

- Standardise the repeat-contact flag.
- A repeat contact may be related to an existing issue rather than a new issue.
- The synthetic dataset should use a clear flag definition.

---

# 7. Prediction KPIs

---

## KPI-P01 — High-Risk Customers

| Field | Definition |
|---|---|
| KPI ID | KPI-P01 |
| KPI Name | High-Risk Customers |
| Category | Prediction |
| Business Question | How many scored customers have a high probability of future churn? |
| Definition | The number of eligible scored customers classified as High Risk |
| Formula | Distinct scored customers where risk level is High |
| Required Fields | `customer_id`, `churn_probability`, `risk_level` |
| Main Source Tables | Model prediction output, `vw_customer_risk_predictions` |
| Reporting Grain | Scoring date, segment, plan or country |
| Recommended Filters | Segment, plan, country, top risk driver, recommended action |
| Display Format | Whole number with thousands separator |
| Power BI Visual | KPI card |
| Interpretation | Shows the customers who should receive the highest retention priority |

### Recommended Initial Rule

```text
High Risk =
Churn Probability greater than or equal to 0.70
```

### Important Notes

- This threshold may be changed after model evaluation.
- High risk does not mean the customer will definitely churn.
- Only eligible and successfully scored customers should be included.

---

## KPI-P02 — Medium-Risk Customers

| Field | Definition |
|---|---|
| KPI ID | KPI-P02 |
| KPI Name | Medium-Risk Customers |
| Category | Prediction |
| Business Question | How many scored customers have a moderate probability of future churn? |
| Definition | The number of eligible scored customers classified as Medium Risk |
| Formula | Distinct scored customers where risk level is Medium |
| Required Fields | `customer_id`, `churn_probability`, `risk_level` |
| Main Source Tables | Model prediction output, reporting views |
| Reporting Grain | Scoring date or customer group |
| Recommended Filters | Segment, plan, country, top risk driver |
| Display Format | Whole number with thousands separator |
| Power BI Visual | KPI card |
| Interpretation | These customers may need lower-cost or automated retention actions |

### Recommended Initial Rule

```text
Medium Risk =
Churn Probability from 0.30 to below 0.70
```

### Important Notes

- Thresholds must not overlap.
- Medium-risk customers should be monitored but may not require the highest-cost action.

---

## KPI-P03 — Low-Risk Customers

| Field | Definition |
|---|---|
| KPI ID | KPI-P03 |
| KPI Name | Low-Risk Customers |
| Category | Prediction |
| Business Question | How many scored customers have a low probability of future churn? |
| Definition | The number of eligible scored customers classified as Low Risk |
| Formula | Distinct scored customers where risk level is Low |
| Required Fields | `customer_id`, `churn_probability`, `risk_level` |
| Main Source Tables | Model prediction output, reporting views |
| Reporting Grain | Scoring date or customer group |
| Recommended Filters | Segment, plan, country |
| Display Format | Whole number with thousands separator |
| Power BI Visual | KPI card |
| Interpretation | These customers currently show fewer modelled churn-risk signals |

### Recommended Initial Rule

```text
Low Risk =
Churn Probability below 0.30
```

### Important Notes

- Low risk does not guarantee future retention.
- These customers may still require normal engagement monitoring.

---

## KPI-P04 — Membership Revenue at Risk

| Field | Definition |
|---|---|
| KPI ID | KPI-P04 |
| KPI Name | Membership Revenue at Risk |
| Category | Prediction |
| Business Question | How much future membership revenue is associated with medium-risk and high-risk customers? |
| Definition | The estimated membership-fee value exposed to churn risk among selected scored customers |
| Formula | Sum of Expected Membership Fee Value for Selected At-Risk Customers |
| Required Fields | `customer_id`, `risk_level`, `churn_probability`, `membership_fee`, `billing_cycle` |
| Main Source Tables | Model predictions, memberships, customer-level reporting view |
| Reporting Grain | Scoring date, risk level, plan or segment |
| Recommended Filters | Risk level, plan, segment, country, recommended action |
| Display Format | Currency with thousands separator |
| Power BI Visual | KPI card and bar chart |
| Interpretation | Higher values indicate a larger amount of fictional membership revenue exposed to churn |

### Simple Portfolio Formula

```text
Membership Revenue at Risk =
Sum of Next Membership Fee
for Medium-Risk and High-Risk Customers
```

### Probability-Weighted Formula

A more analytical version is:

```text
Probability-Weighted Revenue at Risk =
Sum of Membership Fee × Churn Probability
```

### Recommended Project Use

Use the probability-weighted version in the final project:

```text
Membership Revenue at Risk =
Sum of Next Membership Fee × Churn Probability
for Eligible Scored Customers
```

### Important Notes

- This is an estimated exposure, not guaranteed lost revenue.
- Monthly and annual plans should be converted to a consistent next-renewal value.
- Clearly state which version is used in Power BI.

---

## KPI-P05 — Model Recall

| Field | Definition |
|---|---|
| KPI ID | KPI-P05 |
| KPI Name | Model Recall |
| Category | Prediction |
| Business Question | Of all customers who actually churned, how many did the model correctly identify? |
| Definition | The percentage of actual churners correctly predicted as churners |
| Formula | True Positives ÷ (True Positives + False Negatives) |
| Required Fields | Actual churn target and predicted churn class |
| Main Source Tables | Model test results, `model_metrics.csv` |
| Reporting Grain | Model evaluation dataset |
| Recommended Filters | Model name or probability threshold |
| Display Format | Percentage with 1 or 2 decimal places |
| Power BI Visual | KPI card or model-comparison table |
| Interpretation | Higher recall means fewer actual churners were missed |

### Formula

```text
Recall =
True Positives
÷
(True Positives + False Negatives)
```

### Simple Meaning

Imagine 100 customers actually churned.

If the model correctly identified 80 of them:

```text
Recall = 80%
```

### Important Notes

- Recall is important because the business wants to find customers likely to leave.
- Very high recall may reduce precision if too many non-churners are also flagged.
- Report the probability threshold used.

---

## KPI-P06 — Model Precision

| Field | Definition |
|---|---|
| KPI ID | KPI-P06 |
| KPI Name | Model Precision |
| Category | Prediction |
| Business Question | Of the customers predicted to churn, how many actually churned? |
| Definition | The percentage of predicted churners who were actual churners |
| Formula | True Positives ÷ (True Positives + False Positives) |
| Required Fields | Actual churn target and predicted churn class |
| Main Source Tables | Model test results, `model_metrics.csv` |
| Reporting Grain | Model evaluation dataset |
| Recommended Filters | Model name or probability threshold |
| Display Format | Percentage with 1 or 2 decimal places |
| Power BI Visual | KPI card or model-comparison table |
| Interpretation | Higher precision means retention resources are directed more accurately |

### Formula

```text
Precision =
True Positives
÷
(True Positives + False Positives)
```

### Simple Meaning

Imagine the model flagged 100 customers as likely churners.

If 70 of them actually churned:

```text
Precision = 70%
```

### Important Notes

- Low precision means many customers may receive unnecessary retention actions.
- Precision should be evaluated together with recall.

---

## KPI-P07 — Model F1 Score

| Field | Definition |
|---|---|
| KPI ID | KPI-P07 |
| KPI Name | Model F1 Score |
| Category | Prediction |
| Business Question | How well does the model balance precision and recall? |
| Definition | The harmonic mean of precision and recall |
| Formula | 2 × (Precision × Recall) ÷ (Precision + Recall) |
| Required Fields | Precision and recall |
| Main Source Tables | Model evaluation output, `model_metrics.csv` |
| Reporting Grain | Model evaluation dataset |
| Recommended Filters | Model name or threshold |
| Display Format | Decimal or percentage with 2 decimal places |
| Power BI Visual | Model-comparison table |
| Interpretation | A higher F1 score indicates a stronger balance between finding churners and avoiding false alerts |

### Formula

```text
F1 Score =
2 × (Precision × Recall)
÷
(Precision + Recall)
```

### Important Notes

- F1 is useful when the churn target is imbalanced.
- It should not replace ROC-AUC, precision or recall.
- The same threshold must be used for precision, recall and F1 comparison.

---

## KPI-P08 — ROC-AUC

| Field | Definition |
|---|---|
| KPI ID | KPI-P08 |
| KPI Name | ROC-AUC |
| Category | Prediction |
| Business Question | How well can the model separate churners from non-churners across different thresholds? |
| Definition | A threshold-independent measure of the model's ability to rank churners above non-churners |
| Formula | Area under the Receiver Operating Characteristic curve |
| Required Fields | Actual churn target and predicted churn probability |
| Main Source Tables | Model evaluation output, `model_metrics.csv` |
| Reporting Grain | Model evaluation dataset |
| Recommended Filters | Model name |
| Display Format | Decimal from 0.00 to 1.00 |
| Power BI Visual | Model-comparison table |
| Interpretation | Higher ROC-AUC means better overall separation between churners and non-churners |

### Interpretation Guide

| ROC-AUC | Simple Interpretation |
|---:|---|
| 0.50 | No better than random guessing |
| 0.60–0.69 | Weak |
| 0.70–0.79 | Acceptable |
| 0.80–0.89 | Good |
| 0.90–1.00 | Very strong and should be checked carefully for leakage |

### Recommended Realistic Target

For this synthetic portfolio project, a believable target may be approximately:

```text
0.75 to 0.88
```

### Important Notes

- A very high value may indicate unrealistic synthetic patterns or data leakage.
- ROC-AUC should be evaluated with precision, recall and F1 score.
- Use predicted probabilities, not only predicted classes.

---

# 8. KPI Summary Table

| KPI ID | KPI Name | Category | Recommended Display |
|---|---|---|---|
| KPI-M01 | Total Customers | Membership | Whole number |
| KPI-M02 | Active Members | Membership | Whole number |
| KPI-M03 | Churned Members | Membership | Whole number |
| KPI-M04 | Churn Rate | Membership | Percentage |
| KPI-M05 | Retention Rate | Membership | Percentage |
| KPI-M06 | Renewal Rate | Membership | Percentage |
| KPI-M07 | Average Membership Tenure | Membership | Months |
| KPI-M08 | Auto-Renewal Adoption Rate | Membership | Percentage |
| KPI-E01 | Orders per Customer | Engagement | Decimal |
| KPI-E02 | Average Order Value | Engagement | Currency |
| KPI-E03 | Prime Video Watch Hours | Engagement | Hours |
| KPI-E04 | Active Customers | Engagement | Whole number |
| KPI-E05 | Benefits Used per Customer | Engagement | Decimal |
| KPI-E06 | Inactive Customer Rate | Engagement | Percentage |
| KPI-X01 | Late Delivery Rate | Experience | Percentage |
| KPI-X02 | Return Rate | Experience | Percentage |
| KPI-X03 | Payment Failure Rate | Experience | Percentage |
| KPI-X04 | Average Support Resolution Time | Experience | Hours |
| KPI-X05 | Average Satisfaction Score | Experience | Score |
| KPI-X06 | Repeat Contact Rate | Experience | Percentage |
| KPI-P01 | High-Risk Customers | Prediction | Whole number |
| KPI-P02 | Medium-Risk Customers | Prediction | Whole number |
| KPI-P03 | Low-Risk Customers | Prediction | Whole number |
| KPI-P04 | Membership Revenue at Risk | Prediction | Currency |
| KPI-P05 | Model Recall | Prediction | Percentage |
| KPI-P06 | Model Precision | Prediction | Percentage |
| KPI-P07 | Model F1 Score | Prediction | Decimal or percentage |
| KPI-P08 | ROC-AUC | Prediction | Decimal |

---

# 9. Recommended Power BI Placement

## Page 1 — Executive Overview

Recommended KPI cards:

- Total Customers.
- Active Members.
- Churn Rate.
- Retention Rate.
- Average Membership Tenure.
- High-Risk Customers.
- Membership Revenue at Risk.

---

## Page 2 — Churn and Retention

Recommended KPI cards:

- Churned Members.
- Churn Rate.
- Retention Rate.
- Renewal Rate.
- Auto-Renewal Adoption Rate.

---

## Page 3 — Customer Segmentation

Recommended KPI cards:

- Active Customers.
- Orders per Customer.
- Average Order Value.
- Prime Video Watch Hours.
- Benefits Used per Customer.
- Inactive Customer Rate.

---

## Page 4 — Churn Drivers

Recommended KPI cards:

- Late Delivery Rate.
- Return Rate.
- Payment Failure Rate.
- Average Support Resolution Time.
- Average Satisfaction Score.
- Repeat Contact Rate.

---

## Page 5 — Prediction and Retention Actions

Recommended KPI cards:

- High-Risk Customers.
- Medium-Risk Customers.
- Low-Risk Customers.
- Membership Revenue at Risk.

Recommended model metrics table:

- Model Recall.
- Model Precision.
- Model F1 Score.
- ROC-AUC.

---

# 10. KPI Validation Checklist

Before approving any KPI, confirm:

- The numerator is clearly defined.
- The denominator is clearly defined.
- Distinct customers are used where needed.
- The time period is clear.
- The latest membership record is used where required.
- Invalid or duplicate rows are excluded.
- Null values are handled correctly.
- Filters affect the KPI as intended.
- Python, SQL and Power BI return matching results.
- Percentage KPIs are not multiplied by 100 twice.
- Currency and decimal formats are correct.
- The KPI does not expose future information or cause model leakage.
- The synthetic-data disclaimer remains visible.

---

# 11. Common Mistakes to Avoid

## Mistake 1 — Counting Customer Rows Instead of Unique Customers

Incorrect:

```text
Count of rows in orders table
```

Correct:

```text
Distinct count of customer_id
```

---

## Mistake 2 — Confusing Active Members with Active Customers

**Active Members** have an active membership.

**Active Customers** performed a qualifying activity during the selected period.

A member can be active but have no recent activity.

---

## Mistake 3 — Using All Historical Customers in the Churn-Rate Denominator

Churn Rate should use members who were actually eligible to churn during the period.

---

## Mistake 4 — Including Cancelled Orders in Average Order Value

Use only valid eligible orders.

---

## Mistake 5 — Treating Missing Satisfaction as Zero

Missing means the customer did not provide a rating.

Zero is not part of the recommended 1–5 scale.

---

## Mistake 6 — Counting Payment Retries as Unique Customers

Payment Failure Rate measures payment attempts.

High-risk customer analysis may instead count unique customers with one or more failures.

These are different metrics.

---

## Mistake 7 — Calling Model Accuracy the Main Success Metric

Churn is usually imbalanced.

Use:

- Recall.
- Precision.
- F1 score.
- ROC-AUC.

---

## Mistake 8 — Treating Churn Probability as Certainty

A customer with an 80% churn probability is high risk, but churn is not guaranteed.

---

# 12. KPI Ownership and Project Usage

For this portfolio project, the assumed analytical owner is:

**Customer Analytics Data Analyst — Amazon Prime Retention Team**

The KPI dictionary will be used when creating:

- `notebooks/02_exploratory_data_analysis.ipynb`
- `sql/05_customer_kpi_analysis.sql`
- `sql/06_churn_driver_analysis.sql`
- `sql/07_retention_and_cohort_analysis.sql`
- `sql/09_create_power_bi_views.sql`
- `power-bi/amazon_prime_churn_retention_dashboard.pbix`
- `docs/executive_summary.md`
- `README.md`

---

# 13. Final KPI Requirement

All KPI calculations in Python, BigQuery and Power BI must follow the same business definitions documented here.

When a KPI definition changes, this document should be updated first. The SQL queries, Python logic and Power BI measures should then be updated to match it.

This ensures that the final project remains consistent, understandable and reliable.

---

# 14. Educational Disclaimer

This is an independent educational portfolio project created to demonstrate customer analytics, SQL, Python, cloud data warehousing, machine learning and Power BI skills.

Amazon and Amazon Prime are trademarks of Amazon.com, Inc. This project is not affiliated with, endorsed by or sponsored by Amazon.

All data used in the project is fully synthetic and generated solely for educational purposes. It does not contain actual Amazon customer information, confidential business data, proprietary metrics or internal records.

All KPI values, trends, customer behaviours, model results and business recommendations produced by this project are simulated. They must not be interpreted as statements about Amazon's actual customers, operations or business performance.
