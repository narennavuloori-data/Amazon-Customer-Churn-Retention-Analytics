# Business Requirements

## End-to-End Amazon Prime Customer Churn & Retention Analytics

### Project Type

Independent educational portfolio project using fully synthetic data.

### Assumed Role

**Customer Analytics Data Analyst — Amazon Prime Retention Team**

---

## 1. Purpose of This Document

This document defines the business requirements for the **End-to-End Amazon Prime Customer Churn & Retention Analytics** project.

It explains:

- Why the project is being created.
- Which business problems need to be solved.
- Which analytical questions must be answered.
- Which data areas will be analysed.
- Which outputs must be produced.
- How the completed project will be evaluated.

This document acts as a guide for the complete project. Every Python notebook, SQL query, machine-learning model and Power BI visual should support one or more requirements defined here.

---

## 2. Business Context

Amazon Prime is a subscription membership ecosystem that may provide customers with shopping, delivery and digital entertainment benefits.

In this fictional business scenario, some customers continue renewing their Prime memberships while others cancel or allow their memberships to expire.

The fictional Amazon Prime retention team needs to understand:

- How many customers are active and retained.
- How many customers have churned.
- Which customer groups have the highest churn risk.
- Which customer behaviours are associated with churn.
- Whether service issues and payment failures affect retention.
- Which active customers are likely to churn in the future.
- Which retention action may be suitable for each high-risk customer.

The project will use fully synthetic data and will not represent Amazon's actual customers, metrics, systems or business performance.

---

## 3. Main Business Problem

The fictional retention team currently lacks a complete customer-level view that combines:

- Customer profile information.
- Membership history.
- Shopping activity.
- Prime Video engagement.
- Payment behaviour.
- Customer-support interactions.

Without a combined view, it is difficult to understand why customers leave or to identify customers who may churn before cancellation occurs.

The project must create an analytical solution that helps the fictional retention team:

1. Measure churn and retention.
2. Understand important churn drivers.
3. Compare customer groups.
4. Identify high-risk customers.
5. Recommend relevant retention actions.
6. Communicate findings through a Power BI dashboard.

---

## 4. Business Objectives

The project must achieve the following objectives.

| Objective ID | Business Objective |
|---|---|
| BO-01 | Create a clear view of active, retained and churned Prime members |
| BO-02 | Measure churn and retention trends over time |
| BO-03 | Identify customer groups with higher churn rates |
| BO-04 | Analyse shopping and Prime Video engagement before churn |
| BO-05 | Understand the impact of payment, delivery and support issues |
| BO-06 | Segment customers using understandable business rules |
| BO-07 | Predict which active customers are likely to churn |
| BO-08 | Explain the major factors contributing to churn risk |
| BO-09 | Assign suitable retention actions to at-risk customers |
| BO-10 | Present findings in a recruiter-friendly Power BI dashboard |

---

## 5. Main Stakeholders

The project will simulate the needs of the following fictional stakeholders.

| Stakeholder | Main Interest |
|---|---|
| Retention Manager | Churn rate, high-risk customers and retention actions |
| Customer Analytics Team | Customer behaviour, churn drivers and segments |
| Membership Team | Renewals, cancellations, tenure and auto-renewal |
| Marketing Team | Target groups and personalised retention campaigns |
| Prime Video Team | Video engagement and content-related churn signals |
| Shopping and Delivery Team | Orders, returns and late-delivery experience |
| Payments Team | Payment failures, retries and renewal problems |
| Customer Support Team | Complaints, resolution time and satisfaction |
| Senior Management | Executive KPIs, revenue at risk and recommendations |

---

# 6. Customer and Membership Requirements

## 6.1 Active and Churned Members

### BR-C01 — Total Customers

The analysis must calculate the total number of unique customers included in the dataset.

**Required output:**

- Total customer count.
- Customer count by country.
- Customer count by acquisition channel.
- Customer count by age group.
- Customer count by signup month.

---

### BR-C02 — Active Members

The analysis must calculate the number of customers whose latest valid membership is active as of the selected reporting date.

**Required output:**

- Active member count.
- Active member percentage.
- Active members by plan.
- Active members by country.
- Active members by acquisition channel.
- Monthly active member trend.

---

### BR-C03 — Churned Members

The analysis must calculate the number of customers whose membership was cancelled or expired without a later renewal.

**Required output:**

- Churned member count.
- Churned member percentage.
- Churned members by month.
- Churned members by cancellation reason.
- Churned members by membership plan.

The detailed technical rule will be documented in:

`docs/churn_definition.md`

---

### BR-C04 — Churn Rate by Customer Group

The analysis must identify which customer groups have the highest churn rates.

**Required comparisons:**

- Country.
- State or region.
- Age group.
- Acquisition channel.
- Membership plan.
- Billing cycle.
- Primary device.
- Preferred language.
- Auto-renewal status.
- Membership tenure band.
- Customer segment.

---

### BR-C05 — Churn by Membership Tenure

The analysis must measure whether newer or longer-tenured customers have different churn rates.

**Recommended tenure bands:**

- 0–3 months.
- 4–6 months.
- 7–12 months.
- 13–24 months.
- More than 24 months.

**Required output:**

- Customers by tenure band.
- Churned customers by tenure band.
- Churn rate by tenure band.
- Average tenure of retained customers.
- Average tenure of churned customers.

---

### BR-C06 — Renewal and Retention

The analysis must measure membership renewal and retention performance.

**Required output:**

- Renewal rate.
- Retention rate.
- Monthly churn rate.
- Monthly retention rate.
- Retention by membership plan.
- Retention by acquisition channel.
- Retention by auto-renewal status.
- Cohort-retention matrix.

---

# 7. Customer Engagement Requirements

## 7.1 Shopping Engagement

### BR-E01 — Order Frequency and Churn

The analysis must determine whether customers with low order frequency have a higher churn rate.

**Required metrics:**

- Total orders per customer.
- Orders in the last 30 days.
- Orders in the last 90 days.
- Average monthly orders.
- Days since last order.
- Churn rate by order-frequency band.

**Recommended order-frequency bands:**

- No orders.
- Low frequency.
- Medium frequency.
- High frequency.

---

### BR-E02 — Shopping Value and Retention

The analysis must compare customer spending and shopping value between retained and churned customers.

**Required metrics:**

- Total order value.
- Average order value.
- Total items purchased.
- Shipping fees saved.
- Return rate.
- Shopping activity by customer segment.

---

## 7.2 Prime Video Engagement

### BR-E03 — Prime Video Activity and Churn

The analysis must determine whether reduced Prime Video activity is associated with higher churn.

**Required metrics:**

- Total watch minutes.
- Watch minutes in the last 30 days.
- Watch minutes in the last 90 days.
- Video sessions.
- Titles watched.
- Average completion rate.
- Days since last video activity.
- Churn rate by video-engagement band.

---

### BR-E04 — Declining Engagement

The analysis must identify customers whose recent activity is lower than their previous activity.

**Possible indicators:**

- Decline in order frequency.
- Decline in order value.
- Decline in Prime Video watch time.
- Decline in video sessions.
- Increase in inactivity days.

**Required output:**

- Customers with declining activity.
- Churn rate among customers with declining activity.
- Comparison with customers whose activity remained stable.

---

## 7.3 Multi-Benefit Usage

### BR-E05 — Benefits Used and Retention

The analysis must determine whether customers who use multiple Prime benefits retain longer.

For this project, benefit usage may include:

- Prime shopping activity.
- Prime delivery savings.
- Prime Video activity.
- Membership discounts or promotions.

**Required metrics:**

- Number of benefits used per customer.
- Churn rate by benefit count.
- Retention rate by benefit count.
- Average tenure by benefit count.
- Customer count by benefit-usage band.

---

### BR-E06 — Recent Customer Inactivity

The analysis must measure how recent inactivity affects churn.

**Required metrics:**

- Days since last order.
- Days since last Prime Video activity.
- Days since last payment.
- Days since last customer activity.
- Churn rate by inactivity band.

**Recommended inactivity bands:**

- 0–7 days.
- 8–30 days.
- 31–60 days.
- 61–90 days.
- More than 90 days.

---

# 8. Customer Experience Requirements

## 8.1 Delivery and Returns

### BR-X01 — Late Deliveries and Churn

The analysis must determine whether customers who experience late deliveries have a higher churn rate.

**Required metrics:**

- Total deliveries.
- Late deliveries.
- Late-delivery rate.
- Customers with repeated late deliveries.
- Churn rate by late-delivery band.
- Churned versus retained late-delivery comparison.

---

### BR-X02 — Returns and Churn

The analysis must measure whether frequent returns are associated with churn.

**Required metrics:**

- Total returned orders.
- Return rate.
- Customers with repeated returns.
- Churn rate by return-rate band.

---

## 8.2 Customer Support

### BR-X03 — Support Contacts and Churn

The analysis must determine whether repeated support contacts are associated with higher churn.

**Required metrics:**

- Total support tickets.
- Support tickets in the last 90 days.
- Repeat-contact rate.
- Average resolution time.
- Unresolved-ticket count.
- Churn rate by support-ticket band.

---

### BR-X04 — Customer Satisfaction and Retention

The analysis must measure whether customer satisfaction affects retention.

**Required metrics:**

- Average satisfaction score.
- Satisfaction distribution.
- Retention rate by satisfaction band.
- Churn rate by satisfaction band.
- Satisfaction by issue category.
- Satisfaction by support channel.

---

### BR-X05 — Support Issue Categories

The analysis must identify the support issues most strongly associated with churn.

**Example issue categories:**

- Membership Billing.
- Delivery Problem.
- Refund Request.
- Prime Video Issue.
- Account Access.
- Cancellation Request.
- Payment Failure.
- General Question.

**Required output:**

- Ticket count by issue category.
- Churn rate by issue category.
- Average satisfaction by issue category.
- Average resolution time by issue category.

---

## 8.3 Payments

### BR-X06 — Payment Failures and Cancellation

The analysis must determine whether payment failures lead to membership cancellation or expiry.

**Required metrics:**

- Total payments.
- Successful payments.
- Failed payments.
- Payment failure rate.
- Retry count.
- Last payment status.
- Churn rate by payment-failure count.
- Churn rate after a recent payment failure.

---

### BR-X07 — Auto-Renewal and Payment Risk

The analysis must compare churn between customers with auto-renewal enabled and disabled.

**Required output:**

- Auto-renewal adoption rate.
- Churn rate by auto-renewal status.
- Payment failure rate by auto-renewal status.
- Renewal rate by auto-renewal status.

---

# 9. Customer Segmentation Requirements

### BR-S01 — Create Understandable Customer Segments

The project must assign each eligible customer to one main business segment.

**Recommended segments:**

1. Multi-Benefit Power Users.
2. Shopping-First Members.
3. Video-First Members.
4. New Members.
5. Low-Engagement Members.
6. Service-Risk Members.
7. Payment-Risk Members.
8. Churned Members.

---

### BR-S02 — Segment Performance

The analysis must compare segments using:

- Customer count.
- Churn rate.
- Retention rate.
- Average tenure.
- Average order value.
- Average orders.
- Average video watch hours.
- Average satisfaction.
- Payment failure rate.
- Revenue at risk.

---

### BR-S03 — Segment Actionability

Each segment must have a simple business meaning and an appropriate action.

| Customer Segment | Example Business Action |
|---|---|
| Multi-Benefit Power Users | Protect loyalty and avoid unnecessary discounting |
| Shopping-First Members | Promote unused digital benefits |
| Video-First Members | Recommend relevant content and shopping benefits |
| New Members | Improve onboarding and benefit education |
| Low-Engagement Members | Send re-engagement communication |
| Service-Risk Members | Provide customer-care follow-up |
| Payment-Risk Members | Send payment-update and renewal reminders |
| Churned Members | Analyse causes and possible win-back eligibility |

---

# 10. Churn-Prediction Requirements

## 10.1 Prediction Goal

### BR-P01 — Predict Future Churn

The machine-learning model must use historical customer behaviour to estimate whether an active customer is likely to churn during a future prediction window.

**Recommended design:**

- Feature window: Previous 90 days.
- Prediction window: Next 30 days.
- Target: `churn_next_30_days`.

---

## 10.2 Eligible Customers

### BR-P02 — Prediction Population

The model should score only customers who are eligible for prediction.

Eligible customers should generally:

- Have an active membership at the scoring date.
- Have sufficient historical data.
- Not already be churned.
- Not have an already-recorded future cancellation outcome included as an input.

---

## 10.3 Model Features

### BR-P03 — Feature Groups

The model should consider:

- Membership tenure.
- Membership plan.
- Billing cycle.
- Auto-renewal status.
- Recent order frequency.
- Recent order value.
- Recent Prime Video activity.
- Days since last activity.
- Payment failures.
- Payment retries.
- Support-ticket frequency.
- Satisfaction score.
- Late-delivery rate.
- Return rate.
- Number of Prime benefits used.
- Customer segment.

---

## 10.4 Leakage Prevention

### BR-P04 — Exclude Outcome-Revealing Fields

The following fields must not be used as model inputs:

- Final membership status.
- Cancellation date.
- Cancellation reason.
- Membership end date when it reveals future churn.
- Existing churn flag.
- Any activity recorded after the prediction date.

These fields directly reveal the outcome and would make the model unrealistic.

---

## 10.5 Model Comparison

### BR-P05 — Train and Compare Models

At least three understandable models should be compared:

1. Logistic Regression.
2. Random Forest.
3. Gradient Boosting.

The selected model must be evaluated using:

- Accuracy.
- Precision.
- Recall.
- F1 score.
- ROC-AUC.
- Confusion matrix.

Accuracy must not be used as the only model-selection metric.

---

## 10.6 Customer Risk Levels

### BR-P06 — Assign Risk Levels

Each scored customer must be assigned one risk level.

**Recommended initial rules:**

- Low Risk: Churn probability below 0.30.
- Medium Risk: Churn probability from 0.30 to 0.69.
- High Risk: Churn probability of 0.70 or higher.

The thresholds may be adjusted after reviewing the model results.

---

## 10.7 High-Risk Customers

### BR-P07 — Measure High-Risk Population

The analysis must calculate:

- Number of high-risk customers.
- Percentage of eligible customers who are high risk.
- High-risk customers by plan.
- High-risk customers by segment.
- High-risk customers by country.
- Estimated membership revenue at risk.

---

## 10.8 Model Explanation

### BR-P08 — Explain Churn Risk

The project must identify the most important churn drivers at the overall model level.

The project should also provide a simple main risk driver for each high-risk customer where possible.

**Expected outputs:**

- Feature-importance table.
- Top churn-driver chart.
- Customer-level top risk driver.
- Plain-language explanation of major drivers.

---

## 10.9 Retention Recommendations

### BR-P09 — Recommend a Retention Action

Each medium-risk or high-risk customer should receive one understandable recommended action based on the main risk driver.

| Main Risk Driver | Recommended Action |
|---|---|
| Low recent engagement | Send personalised re-engagement communication |
| No recent shopping activity | Remind customer about shopping and delivery benefits |
| Low Prime Video activity | Recommend relevant content |
| Payment failure | Send payment-update reminder |
| Auto-renewal disabled | Send renewal reminder |
| Delivery complaints | Provide service-recovery communication |
| Low satisfaction | Route customer for support follow-up |
| Limited benefit usage | Provide benefit-education campaign |
| New member with low usage | Send onboarding guidance |
| High price sensitivity | Consider a suitable renewal incentive |

These actions are simulated educational recommendations and are not actual Amazon strategies.

---

# 11. KPI Requirements

The project must calculate the following major KPIs.

## Membership KPIs

- Total Customers.
- Active Members.
- Churned Members.
- Churn Rate.
- Retention Rate.
- Renewal Rate.
- Average Membership Tenure.
- Auto-Renewal Adoption Rate.

## Engagement KPIs

- Orders per Customer.
- Average Order Value.
- Prime Video Watch Hours.
- Video Sessions per Customer.
- Benefits Used per Customer.
- Inactive Customer Rate.

## Experience KPIs

- Late-Delivery Rate.
- Return Rate.
- Payment Failure Rate.
- Average Support Resolution Time.
- Average Satisfaction Score.
- Repeat-Contact Rate.

## Prediction KPIs

- Low-Risk Customers.
- Medium-Risk Customers.
- High-Risk Customers.
- Average Churn Probability.
- Membership Revenue at Risk.
- Model Precision.
- Model Recall.
- Model F1 Score.
- Model ROC-AUC.

The detailed business definition and formula for each KPI will be documented in:

`docs/kpi_dictionary.md`

---

# 12. Data Requirements

The analysis requires six related synthetic CSV files.

| File | Required Information |
|---|---|
| `customers.csv` | Customer profile, signup and acquisition details |
| `memberships.csv` | Plan, tenure, renewal, cancellation and membership status |
| `orders.csv` | Shopping, delivery, return and order-value behaviour |
| `prime_video_activity.csv` | Watch time, sessions, titles and engagement |
| `payments.csv` | Successful, failed, retried and refunded payments |
| `support_interactions.csv` | Issue type, support channel, resolution and satisfaction |

## Data Relationship Requirements

- Every membership must belong to a valid customer.
- Every order must belong to a valid customer.
- Every video activity record must belong to a valid customer.
- Every support interaction must belong to a valid customer.
- Every payment must belong to a valid customer and membership.
- Primary keys must be unique after cleaning.
- Foreign-key relationships must be valid after cleaning.

---

# 13. Time and Reporting Requirements

The recommended analysis period is:

**July 1, 2024 to June 30, 2026**

The project must support:

- Daily activity dates.
- Monthly trends.
- Monthly membership cohorts.
- Year-over-year comparisons where meaningful.
- 30-day and 90-day behavioural windows.
- Customer-level prediction at a selected scoring date.

All reporting must use a proper date dimension in BigQuery and Power BI.

---

# 14. BigQuery Requirements

The project must use three simple data layers.

| BigQuery Dataset | Purpose |
|---|---|
| `amazon_prime_staging` | Store cleaned source tables |
| `amazon_prime_analytics` | Store dimensions, facts, customer features and segments |
| `amazon_prime_reporting` | Store final Power BI views |

The analytics layer must include a one-row-per-customer table called:

`customer_360`

This table will combine major customer, membership, shopping, video, payment, support and churn fields.

---

# 15. Power BI Requirements

The final Power BI report must contain five pages.

## Page 1 — Executive Overview

Must show:

- Total Customers.
- Active Members.
- Churn Rate.
- Retention Rate.
- Average Tenure.
- High-Risk Customers.
- Membership Revenue at Risk.
- Monthly churn trend.
- Churn by plan.
- Churn by country.
- Churn by acquisition channel.

---

## Page 2 — Churn and Retention

Must show:

- Monthly churn trend.
- Monthly retention trend.
- Cohort-retention matrix.
- Churn by tenure.
- Churn by auto-renewal.
- Churn by benefits used.
- Renewal rate.

---

## Page 3 — Customer Segmentation

Must show:

- Customers by segment.
- Churn rate by segment.
- Average orders by segment.
- Average order value by segment.
- Video watch hours by segment.
- Benefit usage by segment.

---

## Page 4 — Churn Drivers

Must show:

- Top model features.
- Churn by inactivity.
- Churn by payment failures.
- Churn by support tickets.
- Churn by satisfaction score.
- Churn by late-delivery rate.
- Comparison of retained and churned customers.

---

## Page 5 — Prediction and Retention Actions

Must show:

- Customers by risk level.
- High-risk customers by segment.
- Main customer risk drivers.
- Recommended retention actions.
- Membership revenue at risk.
- Customer-level risk table.

---

# 16. Required Project Outputs

The completed project must produce the following outputs.

## Documentation

- `docs/project_definition.md`
- `docs/business_requirements.md`
- `docs/kpi_dictionary.md`
- `docs/churn_definition.md`
- `docs/data_model.md`
- `docs/executive_summary.md`

## Data

- Six raw synthetic CSV files.
- Six cleaned CSV files.
- One customer-level churn-model dataset.
- One data dictionary.

## Python

- Data validation and cleaning notebook.
- Exploratory data analysis notebook.
- Feature-engineering notebook.
- Churn-modelling notebook.
- Model-explanation and retention-actions notebook.

## SQL and BigQuery

- Staging tables.
- Data-quality checks.
- Dimensions and fact tables.
- `customer_360` table.
- KPI queries.
- Churn-driver queries.
- Cohort and retention queries.
- Customer segments.
- Power BI reporting views.

## Machine Learning

- Model comparison.
- Selected churn model.
- Model metrics.
- Feature importance.
- Churn probabilities.
- Risk levels.
- Recommended actions.

## Power BI

- One `.pbix` file.
- Five completed dashboard pages.
- Dashboard screenshots for GitHub.

---

# 17. Business Rules and Assumptions

The project will use the following initial assumptions:

1. All customers and transactions are fictional.
2. A customer's latest valid membership determines the current membership status.
3. Churn generally means cancellation or expiry without a later renewal.
4. Retention means that the customer remains active or renews during the required period.
5. Customers may use shopping benefits, Prime Video benefits or both.
6. Low engagement may increase churn probability but does not guarantee churn.
7. Payment failures may cause unintentional churn.
8. Service problems may affect satisfaction and retention.
9. Some high-engagement customers may still churn.
10. Some low-engagement customers may remain loyal.
11. The model should contain realistic uncertainty.
12. Final definitions may be refined after the dataset is generated and validated.

---

# 18. Out-of-Scope Requirements

The project will not include:

- Actual Amazon customer data.
- Internal Amazon systems or confidential business logic.
- Real-time streaming data.
- Production model deployment.
- Automated campaign execution.
- Direct customer communication.
- Live payment processing.
- Personal customer-identification data.
- Claims about Amazon's actual churn or retention performance.
- More than five main Power BI report pages.

---

# 19. Acceptance Criteria

Phase 3 and the final project will be considered successful when the following conditions are met.

## Documentation Acceptance

- Every major business question is documented.
- Every requirement has a clear analytical purpose.
- The scope and assumptions are understandable.
- The synthetic-data disclaimer is included.
- Requirements are written in simple business language.

## Data Acceptance

- Six related datasets are available.
- Primary keys are unique after cleaning.
- Foreign-key relationships are valid.
- Dates and business values are usable.
- Controlled messy-data issues are documented.

## Analytics Acceptance

- Active and churned members are calculated.
- Churn and retention trends are available.
- Customer groups are compared.
- Engagement and experience drivers are analysed.
- Retention cohorts are produced.
- Customer segments are created.

## Machine-Learning Acceptance

- At least three models are compared.
- Leakage fields are excluded.
- Precision, recall, F1 score and ROC-AUC are reported.
- Eligible customers receive churn probabilities.
- Risk levels and retention actions are created.

## Dashboard Acceptance

- All five report pages are completed.
- KPIs match the documented definitions.
- Filters and dates work correctly.
- Visuals answer the documented business questions.
- The educational disclaimer is visible.

---

# 20. Educational Disclaimer

This is an independent educational portfolio project created to demonstrate customer analytics, SQL, Python, cloud data warehousing, machine learning and Power BI skills.

Amazon and Amazon Prime are trademarks of Amazon.com, Inc. This project is not affiliated with, endorsed by or sponsored by Amazon.

All data used in the project is fully synthetic and generated solely for educational purposes. It does not contain actual Amazon customer information, confidential business data, proprietary metrics or internal records.

The business scenarios, churn relationships, analytical findings and retention recommendations are simulated and must not be interpreted as statements about Amazon's actual customers, operations or strategy.

---

# 21. Final Requirement Statement

The final solution must help a fictional Amazon Prime retention team move from four basic questions:

1. What happened?
2. Why did it happen?
3. Who may churn next?
4. What action should be taken?

The project must answer these questions using a clear combination of synthetic data, Python, BigQuery SQL, machine learning and Power BI.
