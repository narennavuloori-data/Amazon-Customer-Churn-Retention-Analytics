-- Retention and cohort analysis
-- Project: naren-customer-churn-analytics
-- Reporting date: 2026-06-30

-- Prepare one membership row per customer

CREATE TEMP TABLE retention_base AS

WITH first_membership AS (
  SELECT
    customer_id,
    MIN(membership_start_date) AS first_membership_start_date
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_memberships`
  GROUP BY
    customer_id
),

latest_membership AS (
  SELECT
    customer_id,
    membership_start_date,
    membership_end_date,
    cancellation_date
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_memberships`
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY
      membership_start_date DESC,
      renewal_date DESC,
      membership_id DESC
  ) = 1
)

SELECT
  c.*,
  f.first_membership_start_date,
  DATE_TRUNC(f.first_membership_start_date, MONTH)
    AS membership_start_month,

  CASE
    WHEN c.churn_flag = 1 THEN COALESCE(
      l.cancellation_date,
      l.membership_end_date,
      DATE '2026-06-30'
    )
    ELSE DATE '2026-06-30'
  END AS active_until_date,

  CASE
    WHEN c.payment_failures > 0 THEN 'Payment-Risk Members'
    WHEN c.support_tickets >= 2
      OR c.average_satisfaction_score < 3
      THEN 'Service-Risk Members'
    WHEN c.tenure_months <= 3 THEN 'New Members'
    WHEN c.benefits_used_count >= 3
      THEN 'Multi-Benefit Power Users'
    WHEN c.total_orders >= 5
      AND c.total_video_watch_minutes < 300
      THEN 'Shopping-First Members'
    WHEN c.total_video_watch_minutes >= 600
      AND c.total_orders < 5
      THEN 'Video-First Members'
    WHEN c.total_orders <= 2
      AND c.total_video_watch_minutes < 300
      THEN 'Low-Engagement Members'
    ELSE 'Regular Members'
  END AS customer_segment

FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_360` c
LEFT JOIN first_membership f
  ON c.customer_id = f.customer_id
LEFT JOIN latest_membership l
  ON c.customer_id = l.customer_id;


-- Monthly retention rate

WITH months AS (
  SELECT
    month_start,
    LAST_DAY(month_start) AS month_end
  FROM UNNEST(
    GENERATE_DATE_ARRAY(
      DATE '2024-07-01',
      DATE '2026-06-01',
      INTERVAL 1 MONTH
    )
  ) AS month_start
)

SELECT
  month_start,
  COUNTIF(
    first_membership_start_date <= month_start
    AND active_until_date >= month_start
  ) AS members_at_start,

  COUNTIF(
    first_membership_start_date <= month_start
    AND active_until_date >= month_end
  ) AS retained_members,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(
        first_membership_start_date <= month_start
        AND active_until_date >= month_end
      ),
      COUNTIF(
        first_membership_start_date <= month_start
        AND active_until_date >= month_start
      )
    ),
    2
  ) AS monthly_retention_rate

FROM
  months
CROSS JOIN
  retention_base

GROUP BY
  month_start

ORDER BY
  month_start;


-- Renewal retention

WITH membership_history AS (
  SELECT
    customer_id,
    membership_id,
    membership_end_date,
    LEAD(membership_start_date) OVER (
      PARTITION BY customer_id
      ORDER BY membership_start_date, membership_id
    ) AS next_membership_start_date
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_memberships`
),

renewals AS (
  SELECT
    DATE_TRUNC(membership_end_date, MONTH) AS renewal_month,
    membership_end_date,
    next_membership_start_date
  FROM
    membership_history
  WHERE
    membership_end_date IS NOT NULL
    AND membership_end_date <= DATE '2026-06-23'
)

SELECT
  renewal_month,
  COUNT(*) AS renewal_opportunities,

  COUNTIF(
    next_membership_start_date BETWEEN membership_end_date
    AND DATE_ADD(membership_end_date, INTERVAL 7 DAY)
  ) AS successful_renewals,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(
        next_membership_start_date BETWEEN membership_end_date
        AND DATE_ADD(membership_end_date, INTERVAL 7 DAY)
      ),
      COUNT(*)
    ),
    2
  ) AS renewal_retention_rate

FROM
  renewals

GROUP BY
  renewal_month

ORDER BY
  renewal_month;


-- 30-day and 90-day active-member retention

SELECT
  COUNTIF(
    first_membership_start_date <= DATE '2026-05-31'
  ) AS eligible_30_day_members,

  COUNTIF(
    first_membership_start_date <= DATE '2026-05-31'
    AND active_until_date >= DATE_ADD(
      first_membership_start_date,
      INTERVAL 30 DAY
    )
  ) AS retained_30_day_members,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(
        first_membership_start_date <= DATE '2026-05-31'
        AND active_until_date >= DATE_ADD(
          first_membership_start_date,
          INTERVAL 30 DAY
        )
      ),
      COUNTIF(
        first_membership_start_date <= DATE '2026-05-31'
      )
    ),
    2
  ) AS retention_30_day_rate,

  COUNTIF(
    first_membership_start_date <= DATE '2026-04-01'
  ) AS eligible_90_day_members,

  COUNTIF(
    first_membership_start_date <= DATE '2026-04-01'
    AND active_until_date >= DATE_ADD(
      first_membership_start_date,
      INTERVAL 90 DAY
    )
  ) AS retained_90_day_members,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(
        first_membership_start_date <= DATE '2026-04-01'
        AND active_until_date >= DATE_ADD(
          first_membership_start_date,
          INTERVAL 90 DAY
        )
      ),
      COUNTIF(
        first_membership_start_date <= DATE '2026-04-01'
      )
    ),
    2
  ) AS retention_90_day_rate

FROM
  retention_base;


-- Returning-customer rate by month

WITH activity AS (
  SELECT
    customer_id,
    DATE_TRUNC(order_date, MONTH) AS activity_month
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_orders`
  WHERE
    order_status != 'Cancelled'

  UNION DISTINCT

  SELECT
    customer_id,
    DATE_TRUNC(activity_date, MONTH)
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_video_activity`
  WHERE
    watch_minutes > 0
),

first_activity AS (
  SELECT
    customer_id,
    MIN(activity_month) AS first_activity_month
  FROM
    activity
  GROUP BY
    customer_id
)

SELECT
  a.activity_month,
  COUNT(DISTINCT a.customer_id) AS active_customers,

  COUNT(DISTINCT IF(
    a.activity_month > f.first_activity_month,
    a.customer_id,
    NULL
  )) AS returning_customers,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNT(DISTINCT IF(
        a.activity_month > f.first_activity_month,
        a.customer_id,
        NULL
      )),
      COUNT(DISTINCT a.customer_id)
    ),
    2
  ) AS returning_customer_rate

FROM
  activity a
JOIN first_activity f
  ON a.customer_id = f.customer_id

GROUP BY
  a.activity_month

ORDER BY
  a.activity_month;


-- Cohort retention matrix

SELECT
  membership_start_month AS cohort_month,
  COUNT(*) AS cohort_size,

  100.00 AS m0,

  IF(
    DATE_ADD(membership_start_month, INTERVAL 1 MONTH)
      <= DATE '2026-06-30',
    ROUND(
      100 * SAFE_DIVIDE(
        COUNTIF(
          active_until_date >= DATE_ADD(
            first_membership_start_date,
            INTERVAL 1 MONTH
          )
        ),
        COUNT(*)
      ),
      2
    ),
    NULL
  ) AS m1,

  IF(
    DATE_ADD(membership_start_month, INTERVAL 2 MONTH)
      <= DATE '2026-06-30',
    ROUND(
      100 * SAFE_DIVIDE(
        COUNTIF(
          active_until_date >= DATE_ADD(
            first_membership_start_date,
            INTERVAL 2 MONTH
          )
        ),
        COUNT(*)
      ),
      2
    ),
    NULL
  ) AS m2,

  IF(
    DATE_ADD(membership_start_month, INTERVAL 3 MONTH)
      <= DATE '2026-06-30',
    ROUND(
      100 * SAFE_DIVIDE(
        COUNTIF(
          active_until_date >= DATE_ADD(
            first_membership_start_date,
            INTERVAL 3 MONTH
          )
        ),
        COUNT(*)
      ),
      2
    ),
    NULL
  ) AS m3,

  IF(
    DATE_ADD(membership_start_month, INTERVAL 6 MONTH)
      <= DATE '2026-06-30',
    ROUND(
      100 * SAFE_DIVIDE(
        COUNTIF(
          active_until_date >= DATE_ADD(
            first_membership_start_date,
            INTERVAL 6 MONTH
          )
        ),
        COUNT(*)
      ),
      2
    ),
    NULL
  ) AS m6,

  IF(
    DATE_ADD(membership_start_month, INTERVAL 9 MONTH)
      <= DATE '2026-06-30',
    ROUND(
      100 * SAFE_DIVIDE(
        COUNTIF(
          active_until_date >= DATE_ADD(
            first_membership_start_date,
            INTERVAL 9 MONTH
          )
        ),
        COUNT(*)
      ),
      2
    ),
    NULL
  ) AS m9,

  IF(
    DATE_ADD(membership_start_month, INTERVAL 12 MONTH)
      <= DATE '2026-06-30',
    ROUND(
      100 * SAFE_DIVIDE(
        COUNTIF(
          active_until_date >= DATE_ADD(
            first_membership_start_date,
            INTERVAL 12 MONTH
          )
        ),
        COUNT(*)
      ),
      2
    ),
    NULL
  ) AS m12

FROM
  retention_base

GROUP BY
  membership_start_month

ORDER BY
  membership_start_month;


-- Prepare retention breakdowns

CREATE TEMP TABLE retention_breakdowns AS

SELECT
  r.*,
  'Acquisition Channel' AS breakdown_type,
  acquisition_channel AS breakdown_value
FROM retention_base r

UNION ALL

SELECT
  r.*,
  'Membership Plan',
  plan_type
FROM retention_base r

UNION ALL

SELECT
  r.*,
  'Country',
  country
FROM retention_base r

UNION ALL

SELECT
  r.*,
  'Auto Renewal',
  CASE
    WHEN auto_renew_enabled = TRUE THEN 'Enabled'
    WHEN auto_renew_enabled = FALSE THEN 'Disabled'
    ELSE 'Unknown'
  END
FROM retention_base r

UNION ALL

SELECT
  r.*,
  'Benefits Used',
  CAST(benefits_used_count AS STRING)
FROM retention_base r

UNION ALL

SELECT
  r.*,
  'Customer Segment',
  customer_segment
FROM retention_base r;


-- Retention comparison by customer group

SELECT
  breakdown_type,
  breakdown_value,
  COUNT(*) AS total_customers,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(churn_flag = 0),
      COUNTIF(churn_flag IS NOT NULL)
    ),
    2
  ) AS current_retention_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(
        first_membership_start_date <= DATE '2026-05-31'
        AND active_until_date >= DATE_ADD(
          first_membership_start_date,
          INTERVAL 30 DAY
        )
      ),
      COUNTIF(
        first_membership_start_date <= DATE '2026-05-31'
      )
    ),
    2
  ) AS retention_30_day_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(
        first_membership_start_date <= DATE '2026-04-01'
        AND active_until_date >= DATE_ADD(
          first_membership_start_date,
          INTERVAL 90 DAY
        )
      ),
      COUNTIF(
        first_membership_start_date <= DATE '2026-04-01'
      )
    ),
    2
  ) AS retention_90_day_rate

FROM
  retention_breakdowns

GROUP BY
  breakdown_type,
  breakdown_value

ORDER BY
  breakdown_type,
  current_retention_rate DESC;
