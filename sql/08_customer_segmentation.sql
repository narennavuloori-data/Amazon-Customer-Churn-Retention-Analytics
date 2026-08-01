-- Customer segmentation
-- Project: naren-customer-churn-analytics
-- Reporting date: 2026-06-30

CREATE OR REPLACE TABLE
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_segments`
CLUSTER BY customer_id
AS

WITH latest_membership AS (
  SELECT
    customer_id,
    membership_start_date
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_memberships`
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY
      membership_start_date DESC,
      renewal_date DESC,
      membership_id DESC
  ) = 1
),

payment_summary AS (
  SELECT
    customer_id,
    SUM(retry_count) AS payment_retries
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_payments`
  GROUP BY
    customer_id
),

support_summary AS (
  SELECT
    customer_id,
    COUNTIF(issue_category = 'Delivery Problem')
      AS delivery_complaints
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_support_interactions`
  GROUP BY
    customer_id
),

prepared AS (
  SELECT
    c.*,
    ROUND(c.total_video_watch_minutes / 60, 2)
      AS video_watch_hours,
    COALESCE(p.payment_retries, 0) AS payment_retries,
    COALESCE(s.delivery_complaints, 0)
      AS delivery_complaints,

    CASE
      WHEN c.days_since_last_order IS NULL
        AND c.days_since_last_video_activity IS NULL
        THEN NULL
      WHEN c.days_since_last_order IS NULL
        THEN c.days_since_last_video_activity
      WHEN c.days_since_last_video_activity IS NULL
        THEN c.days_since_last_order
      ELSE LEAST(
        c.days_since_last_order,
        c.days_since_last_video_activity
      )
    END AS days_since_last_activity,

    DATE_DIFF(
      DATE '2026-06-30',
      m.membership_start_date,
      DAY
    ) AS membership_age_days

  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.customer_360` c
  LEFT JOIN latest_membership m
    ON c.customer_id = m.customer_id
  LEFT JOIN payment_summary p
    ON c.customer_id = p.customer_id
  LEFT JOIN support_summary s
    ON c.customer_id = s.customer_id
),

segmented AS (
  SELECT
    *,

    CASE
      WHEN churn_flag = 1
        THEN 'Churned Members'

      WHEN payment_failures > 0
        OR payment_retries >= 2
        OR (
          auto_renew_enabled = FALSE
          AND payment_retries > 0
        )
        THEN 'Payment-Risk Members'

      WHEN support_tickets >= 2
        OR average_satisfaction_score < 3
        OR delivery_complaints >= 2
        OR late_delivery_rate > 0.10
        THEN 'Service-Risk Members'

      WHEN membership_age_days < 90
        THEN 'New Members'

      WHEN total_orders >= 8
        AND video_watch_hours >= 20
        AND benefits_used_count >= 3
        THEN 'Multi-Benefit Power Users'

      WHEN total_orders >= 5
        AND video_watch_hours < 20
        THEN 'Shopping-First Members'

      WHEN video_watch_hours >= 10
        AND total_orders < 5
        THEN 'Video-First Members'

      WHEN total_orders <= 3
        AND video_watch_hours < 5
        AND (
          days_since_last_activity > 30
          OR days_since_last_activity IS NULL
        )
        THEN 'Low-Engagement Members'

      WHEN total_orders >= 5
        THEN 'Shopping-First Members'

      WHEN video_watch_hours >= 10
        THEN 'Video-First Members'

      ELSE 'Low-Engagement Members'
    END AS customer_segment

  FROM
    prepared
)

SELECT
  customer_id,
  customer_segment,
  total_orders,
  video_watch_hours,
  benefits_used_count,
  payment_failures,
  support_tickets,
  average_satisfaction_score AS satisfaction_score,
  days_since_last_activity,
  churn_flag

FROM
  segmented;


-- Segment summary

SELECT
  customer_segment,
  COUNT(*) AS customers,
  ROUND(AVG(total_orders), 2) AS average_orders,
  ROUND(AVG(video_watch_hours), 2) AS average_watch_hours,
  ROUND(AVG(benefits_used_count), 2) AS average_benefits_used,
  ROUND(AVG(payment_failures), 2) AS average_payment_failures,
  ROUND(AVG(support_tickets), 2) AS average_support_tickets,
  ROUND(AVG(satisfaction_score), 2) AS average_satisfaction_score,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(churn_flag = 1),
      COUNTIF(churn_flag IS NOT NULL)
    ),
    2
  ) AS churn_rate

FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_segments`

GROUP BY
  customer_segment

ORDER BY
  customers DESC;


-- Check one row per customer

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT customer_id) AS unique_customers
FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_segments`;
