-- Churn-driver analysis
-- Project: naren-customer-churn-analytics

-- Prepare customer-level churn fields

CREATE TEMP TABLE churn_base AS

WITH prepared AS (
  SELECT
    *,
    CASE
      WHEN days_since_last_order IS NULL
        AND days_since_last_video_activity IS NULL
        THEN NULL
      WHEN days_since_last_order IS NULL
        THEN days_since_last_video_activity
      WHEN days_since_last_video_activity IS NULL
        THEN days_since_last_order
      ELSE LEAST(
        days_since_last_order,
        days_since_last_video_activity
      )
    END AS days_since_last_activity
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.customer_360`
  WHERE
    churn_flag IS NOT NULL
)

SELECT
  customer_id,
  IF(churn_flag = 1, 'Churned', 'Retained') AS customer_group,
  churn_flag,
  total_orders,
  total_order_value,
  average_order_value,
  total_video_watch_minutes / 60 AS video_watch_hours,
  video_sessions,
  days_since_last_activity,
  payment_failures,
  support_tickets,
  average_satisfaction_score,
  late_delivery_rate,
  return_rate,
  auto_renew_enabled,
  benefits_used_count,
  tenure_months,

  CASE
    WHEN payment_failures = 0 THEN '0 failures'
    WHEN payment_failures = 1 THEN '1 failure'
    ELSE '2+ failures'
  END AS payment_failure_band,

  CASE
    WHEN support_tickets = 0 THEN '0 tickets'
    WHEN support_tickets = 1 THEN '1 ticket'
    WHEN support_tickets = 2 THEN '2 tickets'
    ELSE '3+ tickets'
  END AS support_ticket_band,

  CASE
    WHEN total_video_watch_minutes = 0 THEN '0 hours'
    WHEN total_video_watch_minutes / 60 <= 5 THEN '0-5 hours'
    WHEN total_video_watch_minutes / 60 <= 15 THEN '6-15 hours'
    WHEN total_video_watch_minutes / 60 <= 30 THEN '16-30 hours'
    ELSE 'More than 30 hours'
  END AS watch_hour_band,

  CASE
    WHEN total_orders = 0 THEN '0 orders'
    WHEN total_orders <= 3 THEN '1-3 orders'
    WHEN total_orders <= 7 THEN '4-7 orders'
    WHEN total_orders <= 12 THEN '8-12 orders'
    ELSE '13+ orders'
  END AS order_frequency_band,

  CASE
    WHEN days_since_last_activity IS NULL THEN 'No activity'
    WHEN days_since_last_activity <= 7 THEN '0-7 days'
    WHEN days_since_last_activity <= 30 THEN '8-30 days'
    WHEN days_since_last_activity <= 60 THEN '31-60 days'
    WHEN days_since_last_activity <= 90 THEN '61-90 days'
    ELSE 'More than 90 days'
  END AS inactivity_band,

  CASE
    WHEN average_satisfaction_score IS NULL THEN 'No rating'
    WHEN average_satisfaction_score <= 2 THEN 'Low: 1-2'
    WHEN average_satisfaction_score <= 3 THEN 'Medium: 2-3'
    WHEN average_satisfaction_score <= 4 THEN 'High: 3-4'
    ELSE 'Very high: 4-5'
  END AS satisfaction_band,

  CASE
    WHEN auto_renew_enabled = TRUE THEN 'Enabled'
    WHEN auto_renew_enabled = FALSE THEN 'Disabled'
    ELSE 'Unknown'
  END AS auto_renewal_status,

  CASE
    WHEN tenure_months <= 3 THEN '0-3 months'
    WHEN tenure_months <= 6 THEN '4-6 months'
    WHEN tenure_months <= 12 THEN '7-12 months'
    WHEN tenure_months <= 24 THEN '13-24 months'
    ELSE 'More than 24 months'
  END AS tenure_band,

  CASE
    WHEN total_orders = 0 THEN 'No orders'
    WHEN late_delivery_rate = 0 THEN '0%'
    WHEN late_delivery_rate <= 0.05 THEN 'More than 0%-5%'
    WHEN late_delivery_rate <= 0.10 THEN 'More than 5%-10%'
    ELSE 'More than 10%'
  END AS late_delivery_band,

  CASE
    WHEN total_orders = 0 THEN 'No orders'
    WHEN return_rate = 0 THEN '0%'
    WHEN return_rate <= 0.05 THEN 'More than 0%-5%'
    WHEN return_rate <= 0.10 THEN 'More than 5%-10%'
    ELSE 'More than 10%'
  END AS return_rate_band

FROM
  prepared;


-- Compare retained and churned customers

SELECT
  customer_group,
  COUNT(*) AS customers,
  ROUND(AVG(total_orders), 2) AS average_orders,

  ROUND(
    SAFE_DIVIDE(
      SUM(total_order_value),
      SUM(total_orders)
    ),
    2
  ) AS average_order_value,

  ROUND(AVG(video_watch_hours), 2) AS average_watch_hours,
  ROUND(AVG(video_sessions), 2) AS average_video_sessions,
  ROUND(AVG(days_since_last_activity), 2)
    AS average_days_since_last_activity,
  ROUND(AVG(payment_failures), 2) AS average_payment_failures,
  ROUND(AVG(support_tickets), 2) AS average_support_tickets,
  ROUND(AVG(average_satisfaction_score), 2)
    AS average_satisfaction_score,
  ROUND(100 * AVG(late_delivery_rate), 2)
    AS average_late_delivery_rate,
  ROUND(100 * AVG(return_rate), 2)
    AS average_return_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(auto_renew_enabled = TRUE),
      COUNT(*)
    ),
    2
  ) AS auto_renewal_rate,

  ROUND(AVG(benefits_used_count), 2)
    AS average_benefits_used,
  ROUND(AVG(tenure_months), 2)
    AS average_tenure_months

FROM
  churn_base

GROUP BY
  customer_group

ORDER BY
  customer_group;


-- Prepare churn-driver bands

CREATE TEMP TABLE churn_driver_bands AS

SELECT
  'Payment Failures' AS driver_name,
  payment_failure_band AS driver_value,
  churn_flag
FROM churn_base

UNION ALL

SELECT
  'Support Tickets',
  support_ticket_band,
  churn_flag
FROM churn_base

UNION ALL

SELECT
  'Watch Hours',
  watch_hour_band,
  churn_flag
FROM churn_base

UNION ALL

SELECT
  'Order Frequency',
  order_frequency_band,
  churn_flag
FROM churn_base

UNION ALL

SELECT
  'Inactivity',
  inactivity_band,
  churn_flag
FROM churn_base

UNION ALL

SELECT
  'Customer Satisfaction',
  satisfaction_band,
  churn_flag
FROM churn_base

UNION ALL

SELECT
  'Auto Renewal',
  auto_renewal_status,
  churn_flag
FROM churn_base

UNION ALL

SELECT
  'Benefits Used',
  CAST(benefits_used_count AS STRING),
  churn_flag
FROM churn_base

UNION ALL

SELECT
  'Membership Tenure',
  tenure_band,
  churn_flag
FROM churn_base

UNION ALL

SELECT
  'Late Delivery Rate',
  late_delivery_band,
  churn_flag
FROM churn_base

UNION ALL

SELECT
  'Return Rate',
  return_rate_band,
  churn_flag
FROM churn_base;


-- Churn rate by each driver

SELECT
  driver_name,
  driver_value,
  COUNT(*) AS customers,
  COUNTIF(churn_flag = 1) AS churned_customers,
  COUNTIF(churn_flag = 0) AS retained_customers,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(churn_flag = 1),
      COUNT(*)
    ),
    2
  ) AS churn_rate

FROM
  churn_driver_bands

GROUP BY
  driver_name,
  driver_value

ORDER BY
  driver_name,
  churn_rate DESC;
