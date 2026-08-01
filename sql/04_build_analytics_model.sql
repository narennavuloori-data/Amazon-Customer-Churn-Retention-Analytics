-- Build the analytics model
-- Project: naren-customer-churn-analytics
-- Reporting date: 2026-06-30

-- Date dimension
CREATE OR REPLACE TABLE
  `naren-customer-churn-analytics.amazon_prime_analytics.dim_date`
AS
SELECT
  CAST(FORMAT_DATE('%Y%m%d', full_date) AS INT64) AS date_key,
  full_date,
  EXTRACT(DAY FROM full_date) AS day_number,
  FORMAT_DATE('%A', full_date) AS day_name,
  EXTRACT(WEEK FROM full_date) AS week_number,
  EXTRACT(MONTH FROM full_date) AS month_number,
  FORMAT_DATE('%B', full_date) AS month_name,
  EXTRACT(QUARTER FROM full_date) AS quarter_number,
  EXTRACT(YEAR FROM full_date) AS year_number,
  DATE_TRUNC(full_date, MONTH) AS month_start_date,
  EXTRACT(DAYOFWEEK FROM full_date) IN (1, 7) AS is_weekend
FROM UNNEST(
  GENERATE_DATE_ARRAY(DATE '2024-07-01', DATE '2026-06-30')
) AS full_date;


-- Customer dimension
CREATE OR REPLACE TABLE
  `naren-customer-churn-analytics.amazon_prime_analytics.dim_customer`
CLUSTER BY customer_id
AS
SELECT
  customer_id,
  signup_date,
  country,
  state,
  city_tier,
  age_group,
  preferred_language,
  acquisition_channel,
  primary_device,
  email_marketing_opt_in,
  account_status
FROM
  `naren-customer-churn-analytics.amazon_prime_staging.customers`;


-- Membership plan dimension
CREATE OR REPLACE TABLE
  `naren-customer-churn-analytics.amazon_prime_analytics.dim_membership_plan`
AS
SELECT
  ROW_NUMBER() OVER (
    ORDER BY plan_type, billing_cycle
  ) AS membership_plan_key,
  plan_type,
  billing_cycle
FROM (
  SELECT DISTINCT
    plan_type,
    billing_cycle
  FROM
    `naren-customer-churn-analytics.amazon_prime_staging.memberships`
);


-- Membership fact
CREATE OR REPLACE TABLE
  `naren-customer-churn-analytics.amazon_prime_analytics.fact_memberships`
CLUSTER BY customer_id
AS
SELECT
  m.membership_id,
  m.customer_id,
  p.membership_plan_key,
  CAST(FORMAT_DATE('%Y%m%d', m.membership_start_date) AS INT64)
    AS membership_start_date_key,
  m.membership_start_date,
  CAST(FORMAT_DATE('%Y%m%d', m.renewal_date) AS INT64)
    AS renewal_date_key,
  m.renewal_date,
  CAST(FORMAT_DATE('%Y%m%d', m.membership_end_date) AS INT64)
    AS membership_end_date_key,
  m.membership_end_date,
  CAST(FORMAT_DATE('%Y%m%d', m.cancellation_date) AS INT64)
    AS cancellation_date_key,
  m.cancellation_date,
  m.membership_fee,
  m.auto_renew_enabled,
  m.membership_status,
  m.cancellation_reason,
  m.discount_applied
FROM
  `naren-customer-churn-analytics.amazon_prime_staging.memberships` m
LEFT JOIN
  `naren-customer-churn-analytics.amazon_prime_analytics.dim_membership_plan` p
  ON m.plan_type = p.plan_type
  AND m.billing_cycle = p.billing_cycle;


-- Order fact
CREATE OR REPLACE TABLE
  `naren-customer-churn-analytics.amazon_prime_analytics.fact_orders`
CLUSTER BY customer_id
AS
SELECT
  order_id,
  customer_id,
  CAST(FORMAT_DATE('%Y%m%d', order_date) AS INT64) AS order_date_key,
  order_date,
  order_value,
  product_category,
  items_count,
  delivery_speed,
  delivered_late_flag,
  returned_flag,
  shipping_fee_saved,
  order_status
FROM
  `naren-customer-churn-analytics.amazon_prime_staging.orders`;


-- Prime Video fact
CREATE OR REPLACE TABLE
  `naren-customer-churn-analytics.amazon_prime_analytics.fact_video_activity`
CLUSTER BY customer_id
AS
SELECT
  activity_id,
  customer_id,
  CAST(FORMAT_DATE('%Y%m%d', activity_date) AS INT64)
    AS activity_date_key,
  activity_date,
  content_type,
  genre,
  watch_minutes,
  sessions_count,
  titles_watched,
  completion_rate,
  device_type
FROM
  `naren-customer-churn-analytics.amazon_prime_staging.prime_video_activity`;


-- Payment fact
CREATE OR REPLACE TABLE
  `naren-customer-churn-analytics.amazon_prime_analytics.fact_payments`
CLUSTER BY customer_id
AS
SELECT
  payment_id,
  membership_id,
  customer_id,
  CAST(FORMAT_DATE('%Y%m%d', payment_date) AS INT64)
    AS payment_date_key,
  payment_date,
  payment_amount,
  payment_method,
  payment_status,
  failure_reason,
  retry_count,
  refund_flag
FROM
  `naren-customer-churn-analytics.amazon_prime_staging.payments`;


-- Support fact
CREATE OR REPLACE TABLE
  `naren-customer-churn-analytics.amazon_prime_analytics.fact_support_interactions`
CLUSTER BY customer_id
AS
SELECT
  ticket_id,
  customer_id,
  CAST(FORMAT_DATE('%Y%m%d', ticket_date) AS INT64)
    AS ticket_date_key,
  ticket_date,
  issue_category,
  support_channel,
  priority,
  resolution_hours,
  resolved_flag,
  satisfaction_score,
  repeat_contact_flag
FROM
  `naren-customer-churn-analytics.amazon_prime_staging.support_interactions`;


-- One latest membership per customer
CREATE OR REPLACE TABLE
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_360`
CLUSTER BY customer_id
AS
WITH latest_membership AS (
  SELECT
    m.*,
    p.plan_type,
    p.billing_cycle
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_memberships` m
  LEFT JOIN
    `naren-customer-churn-analytics.amazon_prime_analytics.dim_membership_plan` p
    ON m.membership_plan_key = p.membership_plan_key
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY m.customer_id
    ORDER BY
      m.membership_start_date DESC,
      m.renewal_date DESC,
      m.membership_id DESC
  ) = 1
),

order_summary AS (
  SELECT
    customer_id,
    COUNTIF(order_status != 'Cancelled') AS total_orders,
    SUM(IF(order_status != 'Cancelled', order_value, 0))
      AS total_order_value,
    AVG(IF(order_status != 'Cancelled', order_value, NULL))
      AS average_order_value,
    SAFE_DIVIDE(
      COUNTIF(order_status = 'Delivered' AND delivered_late_flag),
      COUNTIF(order_status = 'Delivered')
    ) AS late_delivery_rate,
    SAFE_DIVIDE(
      COUNTIF(returned_flag),
      COUNTIF(order_status IN ('Delivered', 'Returned'))
    ) AS return_rate,
    SUM(IF(order_status != 'Cancelled', shipping_fee_saved, 0))
      AS total_shipping_fee_saved,
    MAX(IF(order_status != 'Cancelled', order_date, NULL))
      AS last_order_date
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_orders`
  GROUP BY
    customer_id
),

video_summary AS (
  SELECT
    customer_id,
    SUM(watch_minutes) AS total_video_watch_minutes,
    SUM(sessions_count) AS video_sessions,
    MAX(activity_date) AS last_video_activity_date
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_video_activity`
  GROUP BY
    customer_id
),

payment_summary AS (
  SELECT
    customer_id,
    COUNTIF(payment_status = 'Failed') AS payment_failures
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_payments`
  GROUP BY
    customer_id
),

support_summary AS (
  SELECT
    customer_id,
    COUNT(*) AS support_tickets,
    AVG(satisfaction_score) AS average_satisfaction_score
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_support_interactions`
  GROUP BY
    customer_id
)

SELECT
  c.customer_id,
  c.signup_date,
  c.country,
  c.age_group,
  c.acquisition_channel,
  c.primary_device,
  m.plan_type,
  m.membership_status,
  GREATEST(
    DATE_DIFF(
      CASE
        WHEN m.membership_status IN ('Cancelled', 'Expired')
          THEN COALESCE(
            m.cancellation_date,
            m.membership_end_date,
            DATE '2026-06-30'
          )
        ELSE DATE '2026-06-30'
      END,
      m.membership_start_date,
      MONTH
    ),
    0
  ) AS tenure_months,
  COALESCE(o.total_orders, 0) AS total_orders,
  ROUND(COALESCE(o.total_order_value, 0), 2) AS total_order_value,
  ROUND(COALESCE(o.average_order_value, 0), 2) AS average_order_value,
  ROUND(COALESCE(o.late_delivery_rate, 0), 4) AS late_delivery_rate,
  ROUND(COALESCE(o.return_rate, 0), 4) AS return_rate,
  ROUND(COALESCE(v.total_video_watch_minutes, 0), 2)
    AS total_video_watch_minutes,
  COALESCE(v.video_sessions, 0) AS video_sessions,
  (
    IF(COALESCE(o.total_orders, 0) > 0, 1, 0)
    + IF(COALESCE(o.total_shipping_fee_saved, 0) > 0, 1, 0)
    + IF(COALESCE(v.total_video_watch_minutes, 0) > 0, 1, 0)
    + IF(
        m.discount_applied IS NOT NULL
        AND m.discount_applied NOT IN (
          'No Discount',
          'Not Applicable',
          'Unknown'
        ),
        1,
        0
      )
  ) AS benefits_used_count,
  COALESCE(p.payment_failures, 0) AS payment_failures,
  COALESCE(s.support_tickets, 0) AS support_tickets,
  ROUND(s.average_satisfaction_score, 2) AS average_satisfaction_score,
  CASE
    WHEN o.last_order_date IS NULL THEN NULL
    ELSE DATE_DIFF(DATE '2026-06-30', o.last_order_date, DAY)
  END AS days_since_last_order,
  CASE
    WHEN v.last_video_activity_date IS NULL THEN NULL
    ELSE DATE_DIFF(
      DATE '2026-06-30',
      v.last_video_activity_date,
      DAY
    )
  END AS days_since_last_video_activity,
  m.auto_renew_enabled,
  CASE
    WHEN m.membership_status IN ('Cancelled', 'Expired') THEN 1
    WHEN m.membership_status = 'Active' THEN 0
    ELSE NULL
  END AS churn_flag
FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.dim_customer` c
LEFT JOIN latest_membership m
  ON c.customer_id = m.customer_id
LEFT JOIN order_summary o
  ON c.customer_id = o.customer_id
LEFT JOIN video_summary v
  ON c.customer_id = v.customer_id
LEFT JOIN payment_summary p
  ON c.customer_id = p.customer_id
LEFT JOIN support_summary s
  ON c.customer_id = s.customer_id;


-- Check the analytics table row counts
SELECT
  'dim_date' AS table_name,
  COUNT(*) AS row_count
FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.dim_date`

UNION ALL

SELECT
  'dim_customer',
  COUNT(*)
FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.dim_customer`

UNION ALL

SELECT
  'dim_membership_plan',
  COUNT(*)
FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.dim_membership_plan`

UNION ALL

SELECT
  'fact_memberships',
  COUNT(*)
FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.fact_memberships`

UNION ALL

SELECT
  'fact_orders',
  COUNT(*)
FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.fact_orders`

UNION ALL

SELECT
  'fact_video_activity',
  COUNT(*)
FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.fact_video_activity`

UNION ALL

SELECT
  'fact_payments',
  COUNT(*)
FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.fact_payments`

UNION ALL

SELECT
  'fact_support_interactions',
  COUNT(*)
FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.fact_support_interactions`

UNION ALL

SELECT
  'customer_360',
  COUNT(*)
FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_360`

ORDER BY
  table_name;
