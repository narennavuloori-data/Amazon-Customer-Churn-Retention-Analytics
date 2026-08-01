# Churn Definition

## End-to-End Amazon Prime Customer Churn & Retention Analytics

### Project Type

Independent educational portfolio project using fully synthetic data.

### Assumed Role

**Customer Analytics Data Analyst — Amazon Prime Retention Team**

---

# 1. Purpose of This Document

This document defines exactly what **churn**, **retention**, **renewal**, **active membership** and **customer inactivity** mean in this project.

These definitions must remain consistent across:

- Dataset generation.
- Python data cleaning.
- Exploratory data analysis.
- BigQuery SQL.
- Customer segmentation.
- Machine-learning feature engineering.
- Churn-model training.
- Power BI reporting.
- GitHub documentation.

Without a clear churn definition, different parts of the project may produce different answers.

For example, one notebook might classify an expired customer as churned while another query might classify the same customer as active. This document prevents that problem.

---

# 2. Simple Explanation of Churn

Churn means that a customer has stopped being a Prime member.

In this project, a customer generally churns when:

1. The customer cancels the membership, or
2. The membership expires and the customer does not renew it.

A customer is not churned only because they stopped ordering or watching Prime Video.

Low activity may be a warning signal, but it is not the final churn outcome.

---

# 3. Important Project Dates

## 3.1 Complete Data Period

The planned synthetic-data period is:

**July 1, 2024 to June 30, 2026**

This period will be used for:

- Customer signups.
- Membership history.
- Orders.
- Prime Video activity.
- Payments.
- Support interactions.
- Churn and retention analysis.

---

## 3.2 Final Reporting Date

The recommended final reporting date is:

**June 30, 2026**

This date is also called the:

- Snapshot date.
- Analysis date.
- Reporting cut-off date.

It will be used to decide:

- Which memberships are currently active.
- Which customers have already churned.
- Customer membership tenure.
- Customer inactivity.
- Final dashboard KPIs.

---

## 3.3 Machine-Learning Scoring Date

For the first churn-model version, use:

**May 31, 2026**

The scoring date is the moment when the fictional retention team asks:

> Based only on information available today, which active customers may churn during the next 30 days?

Nothing that happens after May 31, 2026 may be used as a model input.

---

# 4. Source Fields Used for Churn Classification

The main churn logic will use fields from `memberships.csv`.

Expected fields include:

| Field | Purpose |
|---|---|
| `membership_id` | Unique membership record |
| `customer_id` | Connects the membership to a customer |
| `membership_start_date` | Date the membership period started |
| `renewal_date` | Date the membership renewed, when applicable |
| `membership_end_date` | Date the membership period ended or is expected to end |
| `membership_status` | Active, Cancelled, Expired, Paused or Payment Pending |
| `cancellation_date` | Date the customer cancelled |
| `cancellation_reason` | Synthetic reason for cancellation |
| `auto_renew_enabled` | Whether automatic renewal is enabled |
| `plan_type` | Membership plan |
| `billing_cycle` | Monthly or annual billing cycle |

The final dataset may include additional fields, but the core churn rules must still follow this document.

---

# 5. Latest Valid Membership Rule

A customer may have more than one membership record because of:

- Renewal.
- Plan changes.
- Cancellation followed by rejoining.
- A new membership period.

Therefore, we must not simply use the first membership record.

For each customer and reporting date:

1. Keep membership records whose start date is on or before the reporting date.
2. Sort those records by `membership_start_date`.
3. If two records have the same start date, use the latest `renewal_date` or latest `membership_id` according to the generated data rules.
4. Use the most recent valid record as the customer's current membership record.

This is called the **latest valid membership**.

---

# 6. Business Churn Definition

## 6.1 Official Business Definition

A customer is considered churned when the customer's Prime membership is cancelled or expires without a valid later renewal.

This can happen through:

### Voluntary Churn

The customer intentionally cancels the membership.

Examples of synthetic cancellation reasons:

- Too Expensive.
- Low Usage.
- Delivery Issues.
- Content Dissatisfaction.
- Switched Service.
- Temporary Membership.
- Unknown.

### Involuntary Churn

The membership ends without a successful renewal, possibly because of:

- Payment failure.
- Expired payment method.
- Repeated unsuccessful payment attempts.
- Auto-renewal problems.

The project may analyse voluntary and involuntary churn separately, but both are included in overall churn.

---

## 6.2 What Is Not Churn?

The following conditions do not automatically mean churn:

- The customer has not placed a recent order.
- The customer has not recently watched Prime Video.
- The customer opened a support ticket.
- The customer had one failed payment that was later resolved.
- The customer disabled marketing emails.
- The customer has low engagement.
- The customer temporarily paused the membership.
- The membership is still in a payment-pending state.
- The membership is active on the reporting date.

These may be risk signals, but they do not confirm churn.

---

# 7. Technical Churn Definition

## 7.1 Descriptive Analytics Churn Flag

The analytical churn field will be:

`churn_flag`

Allowed values:

```text
1 = Churned
0 = Not churned
```

A customer receives:

```text
churn_flag = 1
```

when either of the following is true as of the reporting date:

### Rule A — Cancelled Membership

- The latest valid membership has `membership_status = 'Cancelled'`.
- `cancellation_date` is not missing.
- `cancellation_date` is on or before the reporting date.
- There is no later valid membership that started after the cancellation.

### Rule B — Expired Without Renewal

- The latest valid membership has `membership_status = 'Expired'`, or its valid end date has passed.
- `membership_end_date` is on or before the reporting date.
- There is no valid later renewal or later membership record.
- The customer did not rejoin before the reporting date.

A customer receives:

```text
churn_flag = 0
```

when the latest valid membership is active on the reporting date.

---

## 7.2 SQL-Style Logical Rule

The future SQL logic will follow this simplified structure:

```sql
CASE
    WHEN membership_status = 'Cancelled'
         AND cancellation_date <= reporting_date
         AND no_later_membership = TRUE
        THEN 1

    WHEN membership_status = 'Expired'
         AND membership_end_date <= reporting_date
         AND no_later_renewal = TRUE
         AND no_later_membership = TRUE
        THEN 1

    ELSE 0
END AS churn_flag
```

This is documentation logic only. The final executable SQL will be created later.

---

# 8. Renewal Grace Period

To make expiry classification realistic, the project will use a small renewal grace period.

## 8.1 Grace-Period Rule

A membership may still be considered renewed when a valid renewal or next membership begins within:

**7 days after the previous membership end date**

Example:

```text
Membership end date: June 10, 2026
Next valid membership start: June 14, 2026
Difference: 4 days
Result: Renewed
```

Another example:

```text
Membership end date: June 10, 2026
No later membership by June 17, 2026
Result: Expired without renewal
```

---

## 8.2 End-of-Data Rule

The complete dataset ends on June 30, 2026.

A membership ending during the final seven days may not have enough future data to confirm whether it renews.

Therefore:

- Unrenewed memberships ending from June 24 to June 30, 2026 should not be treated as confirmed expiry churn unless the generated record explicitly states `Cancelled`.
- These records should be classified as `Pending Classification` or excluded from expiry-based churn calculations.
- The synthetic-data generator should preferably avoid unresolved expiry cases during the final seven days.

This rule prevents false churn labels caused by missing future observation time.

---

# 9. Active-Customer Definition

The phrase **active customer** can have two meanings. This project will keep them separate.

## 9.1 Active Member

An **Active Member** is a customer whose latest valid membership is active on the selected reporting date.

The customer must satisfy all of the following:

- `membership_start_date` is on or before the reporting date.
- `membership_status = 'Active'`.
- `cancellation_date` is missing or after the reporting date.
- `membership_end_date` is missing or on/after the reporting date.
- No later record shows that the customer has already churned.

This definition is used for:

- Active Members KPI.
- Churn-model eligibility.
- Current membership base.
- Retention reporting.

---

## 9.2 Engagement-Active Customer

An **Engagement-Active Customer** is an active member who performed at least one qualifying activity during the selected activity window.

Recommended initial activity window:

**Previous 30 days**

Qualifying activity includes at least one:

- Valid completed order, or
- Prime Video activity record with positive watch time.

This definition is used for:

- Active Customers KPI.
- Engagement analysis.
- Inactivity analysis.

---

## 9.3 Important Difference

A customer can be:

- An active member, and
- An inactive customer from an engagement perspective.

Example:

```text
Membership status: Active
No order in previous 30 days
No Prime Video activity in previous 30 days
```

Result:

```text
Active Member = Yes
Engagement-Active Customer = No
Inactive Customer = Yes
```

---

# 10. Retained-Customer Definition

A customer is considered retained during a selected period when:

1. The customer was an eligible active member at the beginning of the period, and
2. The customer remains active at the end of the period or successfully renews during the period.

The customer must not have a confirmed churn event during the period.

## 10.1 Retention Flag

The future analytical field may be:

`retained_flag`

Allowed values:

```text
1 = Retained
0 = Not retained
```

A customer receives:

```text
retained_flag = 1
```

when the customer:

- Was active at the beginning of the period, and
- Is active or successfully renewed at the end.

A customer receives:

```text
retained_flag = 0
```

when the customer churned during the period.

---

## 10.2 Retention Formula

```text
Retention Rate (%) =
Retained Eligible Members
÷
Eligible Members at Start of Period
× 100
```

When churn and retention use the same population and time period:

```text
Retention Rate = 100% - Churn Rate
```

---

# 11. Renewed-Customer Definition

A customer is considered renewed when a membership reaches a renewal opportunity and the customer continues with another valid membership period.

A successful renewal can be identified when at least one of the following is true:

1. A valid `renewal_date` exists within the permitted renewal window.
2. A later valid membership record exists for the same customer.
3. The later membership starts no more than seven days after the previous membership ended.
4. A successful membership payment is connected with the new renewal period.

## 11.1 Renewal Flag

The future analytical field may be:

`renewed_flag`

Allowed values:

```text
1 = Successfully renewed
0 = Did not renew
```

Only memberships that actually reached a renewal opportunity should be included in the renewal-rate denominator.

---

## 11.2 Renewal-Eligible Customer

A customer is renewal eligible when:

- The membership has reached its expected renewal or end date, and
- Enough observation time exists to determine whether renewal happened.

Customers whose renewal date has not yet arrived must not be included in the renewal-rate denominator.

---

## 11.3 Renewal Formula

```text
Renewal Rate (%) =
Successfully Renewed Memberships
÷
Renewal-Eligible Memberships
× 100
```

---

# 12. Inactive-Customer Definition

An inactive customer is not necessarily churned.

An **Inactive Customer** is an active member who has no qualifying shopping or Prime Video activity during the selected inactivity window.

## 12.1 Recommended Initial Rule

Use a 30-day inactivity window.

A customer is inactive when:

```text
No valid completed order during the previous 30 days
AND
No Prime Video activity with positive watch time during the previous 30 days
```

---

## 12.2 Customer-Level Inactivity Flag

The future field may be:

`inactive_30d_flag`

Allowed values:

```text
1 = Inactive during previous 30 days
0 = At least one qualifying activity
```

---

## 12.3 Additional Inactivity Bands

For analysis, calculate:

| Inactivity Band | Meaning |
|---|---|
| 0–7 days | Very recent activity |
| 8–30 days | Recently active |
| 31–60 days | Moderately inactive |
| 61–90 days | Highly inactive |
| More than 90 days | Very highly inactive |

Use the most recent valid customer activity date.

Recommended combined activity date:

```text
last_activity_date =
Latest of:
- last valid order date
- last Prime Video activity date
```

Then calculate:

```text
days_since_last_activity =
reporting_date - last_activity_date
```

---

# 13. Paused and Payment-Pending Memberships

The planned synthetic membership statuses include:

- Active.
- Cancelled.
- Expired.
- Paused.
- Payment Pending.

## 13.1 Paused Membership

A paused membership is temporarily suspended.

Project rule:

- Do not classify it as churned unless it later becomes cancelled or expires without renewal.
- Do not include it in the strict active-member count while it remains paused.
- Report it separately when needed.
- Exclude unresolved paused customers from model training unless the business rule is later changed.

---

## 13.2 Payment-Pending Membership

A payment-pending membership has an unresolved payment outcome.

Project rule:

- Do not immediately classify it as churn.
- If the payment later succeeds, treat the membership according to the renewed or active status.
- If the payment ultimately fails and the membership expires without renewal, classify it as involuntary churn.
- Exclude unresolved payment-pending cases from model training and final churn-rate denominators.

---

# 14. Rejoined-Customer Definition

A customer may churn and later purchase a new Prime membership.

This customer has:

- A historical churn event, and
- A later rejoin event.

## 14.1 Current Status

If the customer has a later valid active membership on the reporting date:

```text
Current Active Member = Yes
Current Churn Flag = 0
```

## 14.2 Historical Churn

The earlier churn event should still remain available for historical event analysis.

Possible future fields:

```text
ever_churned_flag
rejoined_flag
historical_churn_count
```

The main `churn_flag` used for current-customer reporting should describe the customer's status as of the reporting date.

---

# 15. Prediction Objective

The machine-learning model will answer:

> Which customers who are active on May 31, 2026 are likely to churn between June 1 and June 30, 2026?

The model must use only information available on or before May 31, 2026.

---

# 16. Feature Window

## 16.1 Official Feature Window

The recommended feature window is the previous 90 calendar days ending on the scoring date.

For the first model version:

**March 3, 2026 to May 31, 2026**

This inclusive date range contains 90 calendar days.

The model can create features such as:

- Orders in the previous 30 days.
- Orders in the previous 90 days.
- Spending in the previous 90 days.
- Prime Video watch minutes in the previous 30 days.
- Prime Video watch minutes in the previous 90 days.
- Payment failures in the previous 90 days.
- Support tickets in the previous 90 days.
- Days since last order.
- Days since last Prime Video activity.
- Benefits used during the previous 90 days.

---

## 16.2 Long-Term Features

Some safe features may use history before the 90-day activity window.

Examples:

- Membership tenure up to the scoring date.
- Customer signup age.
- Lifetime order count up to the scoring date.
- Historical average satisfaction up to the scoring date.
- Previous successful renewal count up to the scoring date.

No feature may include information recorded after the scoring date.

---

# 17. Prediction Window

## 17.1 Official Prediction Window

The recommended prediction window is the next 30 calendar days after the scoring date.

For the first model version:

**June 1, 2026 to June 30, 2026**

The model target will be:

`churn_next_30_days`

Allowed values:

```text
1 = Customer churned during the next 30 days
0 = Customer did not churn during the next 30 days
```

---

## 17.2 Positive Target Rule

A customer receives:

```text
churn_next_30_days = 1
```

when the customer was active on May 31, 2026 and one of the following happens during June 1–30, 2026:

### Target Rule A — Cancellation

- A valid cancellation becomes effective during the prediction window.
- No later membership starts before the end of the prediction window.

### Target Rule B — Expiry Without Renewal

- The membership expires during the prediction window.
- No valid renewal or later membership exists within the allowed renewal rule.
- The outcome is fully observable inside the available data.

---

## 17.3 Negative Target Rule

A customer receives:

```text
churn_next_30_days = 0
```

when the customer:

- Was active on the scoring date, and
- Remained active through the prediction window, or
- Successfully renewed during the prediction window.

---

## 17.4 Uncertain Outcome Rule

A customer should be excluded from the model dataset when the 30-day outcome cannot be confidently determined.

Examples:

- Membership remains paused throughout the prediction window.
- Payment status remains pending at the end of the window.
- Membership expires during the final seven days and there is not enough data to observe the full renewal grace period.
- Required membership dates are missing.
- Conflicting membership records cannot be resolved.

This prevents incorrect labels.

---

# 18. Model-Eligible Customer Definition

A customer can enter the churn-model dataset only when all the following are true:

1. The customer has a valid `customer_id`.
2. The customer has a valid active membership on the scoring date.
3. The customer has sufficient historical information before the scoring date.
4. The customer has an observable 30-day future outcome.
5. The customer is not already churned on the scoring date.
6. The customer is not in an unresolved paused or payment-pending state.
7. The customer does not have conflicting membership records.
8. The target can be calculated without using ambiguous data.

---

# 19. Model Leakage

## 19.1 Simple Explanation

Model leakage happens when the model receives information that would not have been available when the prediction was made.

It is like giving a student the answer sheet before an exam.

The model may show excellent performance, but the result would be unrealistic and useless.

---

## 19.2 Required Leakage Fields to Exclude

Do not use the following fields as model inputs:

```text
membership_status
cancellation_date
membership_end_date
cancellation_reason
churn_flag
```

These fields directly reveal whether churn occurred or strongly expose the outcome.

---

## 19.3 Why Each Field Must Be Excluded

### `membership_status`

A final value such as `Cancelled` or `Expired` already tells the model that the customer churned.

### `cancellation_date`

A cancellation date directly reveals a churn event.

### `membership_end_date`

The final membership end date may reveal that the membership ended during the prediction window.

It must not be used directly in the initial model.

A safe alternative can be engineered only from information known at the scoring date, such as:

```text
days_until_scheduled_renewal
```

This should be created carefully and only if the expected renewal date was already known at the scoring date.

### `cancellation_reason`

A cancellation reason exists because cancellation has already happened.

### `churn_flag`

This is the outcome being predicted. It can never be a model input.

---

# 20. Additional Temporal Leakage to Prevent

Leakage is not limited to the five columns above.

The project must also exclude:

- Orders placed after the scoring date.
- Prime Video activity after the scoring date.
- Payments recorded after the scoring date.
- Support tickets created after the scoring date.
- Support resolutions completed after the scoring date when the final resolution was unknown at scoring.
- Future satisfaction scores.
- Future renewal outcomes.
- Future plan changes.
- Future customer segments calculated using post-scoring behaviour.
- Any aggregate calculated using the entire dataset when part of that data occurred after the scoring date.

---

# 21. Safe and Unsafe Feature Examples

| Unsafe Feature | Why Unsafe | Safer Alternative |
|---|---|---|
| Final `membership_status` | Reveals cancellation or expiry | Plan and status known strictly at scoring date, but initial model should use active customers only |
| `cancellation_date` | Directly reveals churn | Exclude |
| Final `membership_end_date` | May reveal future outcome | `days_until_expected_renewal` known at scoring date, if safely available |
| `cancellation_reason` | Exists only after churn | Exclude |
| Final `churn_flag` | This is the target | Use only as `y`, never inside `X` |
| Total orders through June 30 | Includes prediction-window activity | Orders through May 31 only |
| Total June watch time | Occurs after scoring | Watch time through May 31 only |
| June payment failures | Future information | Payment failures through May 31 only |
| Final customer segment | May use future activity | Recalculate segment using data through scoring date |
| Final satisfaction score | May be collected later | Scores available on or before scoring date |

---

# 22. Safe Model Features

The model may use the following features when calculated only with data available on or before the scoring date.

## Membership Features

- Membership tenure as of scoring date.
- Plan type as of scoring date.
- Billing cycle as of scoring date.
- Auto-renewal setting as of scoring date.
- Discount used before scoring date.
- Previous renewal count.
- Days until expected renewal, if already known.

## Shopping Features

- Orders in previous 30 days.
- Orders in previous 90 days.
- Spend in previous 90 days.
- Average order value before scoring date.
- Days since last order.
- Late-delivery rate before scoring date.
- Return rate before scoring date.
- Shipping savings before scoring date.

## Prime Video Features

- Watch minutes in previous 30 days.
- Watch minutes in previous 90 days.
- Sessions in previous 90 days.
- Titles watched in previous 90 days.
- Average completion rate before scoring date.
- Days since last video activity.

## Payment Features

- Payment failures in previous 90 days.
- Payment retries in previous 90 days.
- Last known payment status as of scoring date, provided it does not contain the future outcome.
- Days since last successful payment.

## Support Features

- Support tickets in previous 90 days.
- Repeat contacts before scoring date.
- Average support resolution time using only completed cases known by scoring date.
- Average satisfaction score recorded by scoring date.
- Unresolved tickets as of scoring date.

## Combined Features

- Benefits used before scoring date.
- Days since last qualifying activity.
- Engagement trend before scoring date.
- Customer segment calculated using pre-scoring information.
- Acquisition channel.
- Country or region.
- Primary device.

---

# 23. Churn Classification Decision Table

| Latest Valid Situation | Churned? | Active? | Retained? | Notes |
|---|---:|---:|---:|---|
| Active membership on reporting date | No | Yes | Yes, if active at period start | Normal active member |
| Cancelled before reporting date with no later membership | Yes | No | No | Voluntary churn |
| Expired with no later renewal | Yes | No | No | Expiry churn |
| Expired but renewed within allowed window | No | Yes | Yes | Successful renewal |
| Paused with no final outcome | No | No | Exclude | Temporary unresolved state |
| Payment Pending with no final outcome | No | No | Exclude | Outcome unresolved |
| Cancelled and later rejoined | No for current status | Yes if latest membership active | Depends on selected period | Historical churn still retained |
| Active membership but no activity in 30 days | No | Yes | Yes if still active | Inactive engagement, not churn |
| One failed payment followed by success | No | Yes | Yes | Risk signal only |
| Final-week expiry without enough observation time | Unknown | No | Exclude | Prevent false classification |

---

# 24. Example Customers

## Example 1 — Active and Engaged

```text
Membership status: Active
Membership end date: December 31, 2026
Last order date: June 25, 2026
Last video activity: June 29, 2026
```

Result:

```text
churn_flag = 0
active_member_flag = 1
inactive_30d_flag = 0
```

---

## Example 2 — Active but Inactive

```text
Membership status: Active
Membership end date: December 31, 2026
Last order date: March 15, 2026
Last video activity: April 1, 2026
Reporting date: June 30, 2026
```

Result:

```text
churn_flag = 0
active_member_flag = 1
inactive_30d_flag = 1
```

The customer is inactive, but has not churned.

---

## Example 3 — Voluntary Churn

```text
Membership status: Cancelled
Cancellation date: June 12, 2026
No later membership
```

Result:

```text
churn_flag = 1
churn_type = Voluntary
```

---

## Example 4 — Involuntary Churn

```text
Membership end date: June 10, 2026
Membership status: Expired
Several failed payments
No renewal by June 17, 2026
```

Result:

```text
churn_flag = 1
churn_type = Involuntary
```

---

## Example 5 — Successful Renewal

```text
Previous membership end date: June 10, 2026
New membership start date: June 12, 2026
```

Result:

```text
renewed_flag = 1
churn_flag = 0
```

---

## Example 6 — Rejoined Customer

```text
First membership cancelled: January 10, 2026
New membership started: April 5, 2026
Latest status on June 30, 2026: Active
```

Result:

```text
current churn_flag = 0
active_member_flag = 1
ever_churned_flag = 1
rejoined_flag = 1
```

---

# 25. Recommended Analytical Fields

The future `customer_360` table should contain fields such as:

```text
customer_id
latest_membership_id
membership_start_date
latest_membership_status
current_plan_type
billing_cycle
auto_renew_enabled
membership_tenure_months
active_member_flag
engagement_active_30d_flag
inactive_30d_flag
last_activity_date
days_since_last_activity
renewed_flag
retained_flag
ever_churned_flag
rejoined_flag
churn_flag
churn_type
churn_date
```

The machine-learning dataset should contain:

```text
customer_id
scoring_date
feature_window_start
feature_window_end
prediction_window_start
prediction_window_end
safe model features
churn_next_30_days
```

Outcome-revealing fields must not be included inside the model feature matrix.

---

# 26. Recommended Validation Checks

Before using the churn labels, validate:

- Every churned customer has a valid customer ID.
- Cancellation dates are not before membership start dates.
- Membership end dates are not before membership start dates.
- Churn dates do not occur before signup.
- Active customers do not have an effective past cancellation with no later membership.
- Expired customers classified as churned have no valid later renewal.
- Renewed customers have a valid later membership or renewal date.
- A customer is not simultaneously active and currently churned.
- Model features contain no dates after the scoring date.
- Prediction outcomes occur only inside the prediction window.
- Uncertain end-of-data cases are excluded.
- Paused and unresolved payment-pending memberships are not incorrectly labelled as churn.
- Rejoined customers use their latest membership for current status.

---

# 27. Final Churn Rules Summary

## Descriptive Churn

```text
Churned =
Cancelled before reporting date with no later membership
OR
Expired before reporting date with no valid later renewal
```

## Active Member

```text
Active Member =
Latest valid membership is active on reporting date
```

## Retained Customer

```text
Retained =
Active at start of period
AND
Active or successfully renewed at end of period
```

## Renewed Customer

```text
Renewed =
Reached renewal opportunity
AND
Started a valid next membership within the permitted renewal window
```

## Inactive Customer

```text
Inactive =
Active member
AND
No valid order
AND
No Prime Video activity
during previous 30 days
```

## Machine-Learning Target

```text
churn_next_30_days =
Customer active on May 31, 2026
AND
Confirmed cancellation or non-renewed expiry
between June 1 and June 30, 2026
```

## Model Feature Cut-Off

```text
No model feature may use information after May 31, 2026
```

---

# 28. Educational Disclaimer

This is an independent educational portfolio project created to demonstrate customer analytics, SQL, Python, cloud data warehousing, machine learning and Power BI skills.

Amazon and Amazon Prime are trademarks of Amazon.com, Inc. This project is not affiliated with, endorsed by or sponsored by Amazon.

All data used in the project is fully synthetic and generated solely for educational purposes. It does not contain actual Amazon customer information, confidential business data, proprietary metrics or internal records.

The churn definitions, renewal rules, grace period, prediction windows and business assumptions in this document are simplified project rules created for an educational simulation. They must not be interpreted as Amazon's actual internal definitions or business practices.

---

# 29. Final Governance Rule

This document is the official churn-definition source for the project.

When churn logic changes:

1. Update this document first.
2. Update dataset-generation rules.
3. Update Python cleaning and feature engineering.
4. Update BigQuery SQL.
5. Update machine-learning labels.
6. Update Power BI measures.
7. Validate that every layer returns consistent results.

The same customer must not be classified differently across Python, SQL, machine learning and Power BI.
