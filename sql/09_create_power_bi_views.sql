-- Power BI reporting views
-- Project: naren-customer-churn-analytics
-- Reporting date: 2026-06-30

-- 1. Executive KPI view

CREATE OR REPLACE VIEW
  `naren-customer-churn-analytics.amazon_prime_reporting.vw_executive_kpis`
AS

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

renewal_summary AS (
  SELECT
    COUNTIF(
      membership_end_date IS NOT NULL
      AND membership_end_date <= DATE '2026-06-23'
    ) AS renewal_opportunities,

    COUNTIF(
      membership_end_date IS NOT NULL
      AND membership_end_date <= DATE '2026-06-23'
      AND next_membership_start_date BETWEEN membership_end_date
      AND DATE_ADD(membership_end_date, INTERVAL 7 DAY)
    ) AS successful_renewals
  FROM
    membership_history
),

payment_summary AS (
  SELECT
    COUNTIF(payment_status != 'Pending')
      AS eligible_payment_attempts,
    COUNTIF(payment_status = 'Failed')
      AS failed_payment_attempts
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_payments`
),

support_summary AS (
  SELECT
    COUNTIF(satisfaction_score IS NOT NULL)
      AS rated_support_interactions,
    SUM(satisfaction_score) AS satisfaction_score_total
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_support_interactions`
)

SELECT
  COUNT(*) AS total_customers,
  COUNTIF(c.membership_status = 'Active') AS active_members,
  COUNTIF(c.churn_flag = 1) AS churned_members,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(c.churn_flag = 1),
      COUNTIF(c.churn_flag IS NOT NULL)
    ),
    2
  ) AS churn_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(c.churn_flag = 0),
      COUNTIF(c.churn_flag IS NOT NULL)
    ),
    2
  ) AS retention_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      MAX(r.successful_renewals),
      MAX(r.renewal_opportunities)
    ),
    2
  ) AS renewal_rate,

  ROUND(AVG(c.tenure_months), 2)
    AS average_tenure_months,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(
        c.membership_status = 'Active'
        AND c.auto_renew_enabled = TRUE
      ),
      COUNTIF(c.membership_status = 'Active')
    ),
    2
  ) AS auto_renewal_rate,

  ROUND(
    SAFE_DIVIDE(
      SUM(c.total_order_value),
      SUM(c.total_orders)
    ),
    2
  ) AS average_order_value,

  ROUND(
    AVG(c.total_video_watch_minutes) / 60,
    2
  ) AS average_video_watch_hours,

  ROUND(
    100 * SAFE_DIVIDE(
      MAX(p.failed_payment_attempts),
      MAX(p.eligible_payment_attempts)
    ),
    2
  ) AS payment_failure_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(c.support_tickets > 0),
      COUNT(*)
    ),
    2
  ) AS support_contact_rate,

  ROUND(
    SAFE_DIVIDE(
      MAX(s.satisfaction_score_total),
      MAX(s.rated_support_interactions)
    ),
    2
  ) AS average_satisfaction_score

FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_360` c
CROSS JOIN renewal_summary r
CROSS JOIN payment_summary p
CROSS JOIN support_summary s;


-- 2. Monthly churn and retention trends

CREATE OR REPLACE VIEW
  `naren-customer-churn-analytics.amazon_prime_reporting.vw_churn_retention_trends`
AS

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
),

customer_status AS (
  SELECT
    c.customer_id,
    c.churn_flag,
    f.first_membership_start_date,

    CASE
      WHEN c.churn_flag = 1 THEN COALESCE(
        l.cancellation_date,
        l.membership_end_date,
        DATE '2026-06-30'
      )
      ELSE DATE '2026-06-30'
    END AS active_until_date

  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.customer_360` c
  LEFT JOIN first_membership f
    ON c.customer_id = f.customer_id
  LEFT JOIN latest_membership l
    ON c.customer_id = l.customer_id
),

months AS (
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
  m.month_start,

  COUNTIF(
    c.first_membership_start_date <= m.month_start
    AND c.active_until_date >= m.month_start
  ) AS members_at_start,

  COUNTIF(
    c.first_membership_start_date BETWEEN
      m.month_start AND m.month_end
  ) AS new_members,

  COUNTIF(
    c.churn_flag = 1
    AND c.active_until_date BETWEEN
      m.month_start AND m.month_end
  ) AS churned_members,

  COUNTIF(
    c.first_membership_start_date <= m.month_start
    AND c.active_until_date >= m.month_end
  ) AS retained_members,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(
        c.churn_flag = 1
        AND c.active_until_date BETWEEN
          m.month_start AND m.month_end
      ),
      COUNTIF(
        c.first_membership_start_date <= m.month_start
        AND c.active_until_date >= m.month_start
      )
    ),
    2
  ) AS churn_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(
        c.first_membership_start_date <= m.month_start
        AND c.active_until_date >= m.month_end
      ),
      COUNTIF(
        c.first_membership_start_date <= m.month_start
        AND c.active_until_date >= m.month_start
      )
    ),
    2
  ) AS retention_rate

FROM
  months m
CROSS JOIN customer_status c

GROUP BY
  m.month_start;


-- 3. Customer segment view

CREATE OR REPLACE VIEW
  `naren-customer-churn-analytics.amazon_prime_reporting.vw_customer_segments`
AS

SELECT
  s.customer_id,
  s.customer_segment,

  CASE s.customer_segment
    WHEN 'Multi-Benefit Power Users' THEN 1
    WHEN 'Shopping-First Members' THEN 2
    WHEN 'Video-First Members' THEN 3
    WHEN 'New Members' THEN 4
    WHEN 'Low-Engagement Members' THEN 5
    WHEN 'Service-Risk Members' THEN 6
    WHEN 'Payment-Risk Members' THEN 7
    WHEN 'Churned Members' THEN 8
    ELSE 9
  END AS segment_sort_order,

  c.country,
  c.age_group,
  c.acquisition_channel,
  c.primary_device,
  c.plan_type,
  c.membership_status,
  c.tenure_months,
  c.auto_renew_enabled,
  s.total_orders,
  c.total_order_value,
  s.video_watch_hours,
  s.benefits_used_count,
  s.payment_failures,
  s.support_tickets,
  s.satisfaction_score,
  s.days_since_last_activity,
  s.churn_flag

FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_segments` s
LEFT JOIN
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_360` c
  ON s.customer_id = c.customer_id;


-- 4. Churn-driver view

CREATE OR REPLACE VIEW
  `naren-customer-churn-analytics.amazon_prime_reporting.vw_churn_drivers`
AS

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
),

driver_bands AS (
  SELECT
    1 AS driver_sort_order,
    'Payment Failures' AS driver_name,
    CASE
      WHEN payment_failures = 0 THEN '0 failures'
      WHEN payment_failures = 1 THEN '1 failure'
      ELSE '2+ failures'
    END AS driver_value,
    CASE
      WHEN payment_failures = 0 THEN 1
      WHEN payment_failures = 1 THEN 2
      ELSE 3
    END AS band_sort_order,
    churn_flag
  FROM prepared

  UNION ALL

  SELECT
    2,
    'Support Tickets',
    CASE
      WHEN support_tickets = 0 THEN '0 tickets'
      WHEN support_tickets = 1 THEN '1 ticket'
      WHEN support_tickets = 2 THEN '2 tickets'
      ELSE '3+ tickets'
    END,
    CASE
      WHEN support_tickets = 0 THEN 1
      WHEN support_tickets = 1 THEN 2
      WHEN support_tickets = 2 THEN 3
      ELSE 4
    END,
    churn_flag
  FROM prepared

  UNION ALL

  SELECT
    3,
    'Watch Hours',
    CASE
      WHEN total_video_watch_minutes = 0 THEN '0 hours'
      WHEN total_video_watch_minutes / 60 <= 5
        THEN '0-5 hours'
      WHEN total_video_watch_minutes / 60 <= 15
        THEN '6-15 hours'
      WHEN total_video_watch_minutes / 60 <= 30
        THEN '16-30 hours'
      ELSE 'More than 30 hours'
    END,
    CASE
      WHEN total_video_watch_minutes = 0 THEN 1
      WHEN total_video_watch_minutes / 60 <= 5 THEN 2
      WHEN total_video_watch_minutes / 60 <= 15 THEN 3
      WHEN total_video_watch_minutes / 60 <= 30 THEN 4
      ELSE 5
    END,
    churn_flag
  FROM prepared

  UNION ALL

  SELECT
    4,
    'Order Frequency',
    CASE
      WHEN total_orders = 0 THEN '0 orders'
      WHEN total_orders <= 3 THEN '1-3 orders'
      WHEN total_orders <= 7 THEN '4-7 orders'
      WHEN total_orders <= 12 THEN '8-12 orders'
      ELSE '13+ orders'
    END,
    CASE
      WHEN total_orders = 0 THEN 1
      WHEN total_orders <= 3 THEN 2
      WHEN total_orders <= 7 THEN 3
      WHEN total_orders <= 12 THEN 4
      ELSE 5
    END,
    churn_flag
  FROM prepared

  UNION ALL

  SELECT
    5,
    'Inactivity',
    CASE
      WHEN days_since_last_activity IS NULL
        THEN 'No activity'
      WHEN days_since_last_activity <= 7
        THEN '0-7 days'
      WHEN days_since_last_activity <= 30
        THEN '8-30 days'
      WHEN days_since_last_activity <= 60
        THEN '31-60 days'
      WHEN days_since_last_activity <= 90
        THEN '61-90 days'
      ELSE 'More than 90 days'
    END,
    CASE
      WHEN days_since_last_activity <= 7 THEN 1
      WHEN days_since_last_activity <= 30 THEN 2
      WHEN days_since_last_activity <= 60 THEN 3
      WHEN days_since_last_activity <= 90 THEN 4
      WHEN days_since_last_activity > 90 THEN 5
      ELSE 6
    END,
    churn_flag
  FROM prepared

  UNION ALL

  SELECT
    6,
    'Customer Satisfaction',
    CASE
      WHEN average_satisfaction_score IS NULL
        THEN 'No rating'
      WHEN average_satisfaction_score <= 2
        THEN 'Low: 1-2'
      WHEN average_satisfaction_score <= 3
        THEN 'Medium: 2-3'
      WHEN average_satisfaction_score <= 4
        THEN 'High: 3-4'
      ELSE 'Very high: 4-5'
    END,
    CASE
      WHEN average_satisfaction_score <= 2 THEN 1
      WHEN average_satisfaction_score <= 3 THEN 2
      WHEN average_satisfaction_score <= 4 THEN 3
      WHEN average_satisfaction_score > 4 THEN 4
      ELSE 5
    END,
    churn_flag
  FROM prepared

  UNION ALL

  SELECT
    7,
    'Auto Renewal',
    CASE
      WHEN auto_renew_enabled = TRUE THEN 'Enabled'
      WHEN auto_renew_enabled = FALSE THEN 'Disabled'
      ELSE 'Unknown'
    END,
    CASE
      WHEN auto_renew_enabled = TRUE THEN 1
      WHEN auto_renew_enabled = FALSE THEN 2
      ELSE 3
    END,
    churn_flag
  FROM prepared

  UNION ALL

  SELECT
    8,
    'Benefits Used',
    CAST(benefits_used_count AS STRING),
    benefits_used_count + 1,
    churn_flag
  FROM prepared

  UNION ALL

  SELECT
    9,
    'Membership Tenure',
    CASE
      WHEN tenure_months <= 3 THEN '0-3 months'
      WHEN tenure_months <= 6 THEN '4-6 months'
      WHEN tenure_months <= 12 THEN '7-12 months'
      WHEN tenure_months <= 24 THEN '13-24 months'
      ELSE 'More than 24 months'
    END,
    CASE
      WHEN tenure_months <= 3 THEN 1
      WHEN tenure_months <= 6 THEN 2
      WHEN tenure_months <= 12 THEN 3
      WHEN tenure_months <= 24 THEN 4
      ELSE 5
    END,
    churn_flag
  FROM prepared

  UNION ALL

  SELECT
    10,
    'Late Delivery Rate',
    CASE
      WHEN total_orders = 0 THEN 'No orders'
      WHEN late_delivery_rate = 0 THEN '0%'
      WHEN late_delivery_rate <= 0.05
        THEN 'More than 0%-5%'
      WHEN late_delivery_rate <= 0.10
        THEN 'More than 5%-10%'
      ELSE 'More than 10%'
    END,
    CASE
      WHEN total_orders = 0 THEN 1
      WHEN late_delivery_rate = 0 THEN 2
      WHEN late_delivery_rate <= 0.05 THEN 3
      WHEN late_delivery_rate <= 0.10 THEN 4
      ELSE 5
    END,
    churn_flag
  FROM prepared

  UNION ALL

  SELECT
    11,
    'Return Rate',
    CASE
      WHEN total_orders = 0 THEN 'No orders'
      WHEN return_rate = 0 THEN '0%'
      WHEN return_rate <= 0.05
        THEN 'More than 0%-5%'
      WHEN return_rate <= 0.10
        THEN 'More than 5%-10%'
      ELSE 'More than 10%'
    END,
    CASE
      WHEN total_orders = 0 THEN 1
      WHEN return_rate = 0 THEN 2
      WHEN return_rate <= 0.05 THEN 3
      WHEN return_rate <= 0.10 THEN 4
      ELSE 5
    END,
    churn_flag
  FROM prepared
)

SELECT
  driver_sort_order,
  driver_name,
  band_sort_order,
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
  driver_bands

GROUP BY
  driver_sort_order,
  driver_name,
  band_sort_order,
  driver_value;


-- 5. Retention cohort matrix

CREATE OR REPLACE VIEW
  `naren-customer-churn-analytics.amazon_prime_reporting.vw_retention_cohorts`
AS

WITH first_membership AS (
  SELECT
    customer_id,
    MIN(membership_start_date)
      AS first_membership_start_date
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_memberships`
  GROUP BY
    customer_id
),

latest_membership AS (
  SELECT
    customer_id,
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
),

retention_base AS (
  SELECT
    c.customer_id,
    f.first_membership_start_date,
    DATE_TRUNC(
      f.first_membership_start_date,
      MONTH
    ) AS cohort_month,

    CASE
      WHEN c.churn_flag = 1 THEN COALESCE(
        l.cancellation_date,
        l.membership_end_date,
        DATE '2026-06-30'
      )
      ELSE DATE '2026-06-30'
    END AS active_until_date

  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.customer_360` c
  LEFT JOIN first_membership f
    ON c.customer_id = f.customer_id
  LEFT JOIN latest_membership l
    ON c.customer_id = l.customer_id
)

SELECT
  cohort_month,
  COUNT(*) AS cohort_size,
  100.00 AS m0,

  IF(
    DATE_ADD(cohort_month, INTERVAL 1 MONTH)
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
    DATE_ADD(cohort_month, INTERVAL 2 MONTH)
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
    DATE_ADD(cohort_month, INTERVAL 3 MONTH)
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
    DATE_ADD(cohort_month, INTERVAL 6 MONTH)
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
    DATE_ADD(cohort_month, INTERVAL 9 MONTH)
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
    DATE_ADD(cohort_month, INTERVAL 12 MONTH)
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
  cohort_month;


-- Required source for the last two views:
-- Upload data/processed/customer_risk_predictions.csv as
-- amazon_prime_analytics.customer_risk_predictions

-- 6. Customer-level risk prediction view

CREATE OR REPLACE VIEW
  `naren-customer-churn-analytics.amazon_prime_reporting.vw_customer_risk_predictions`
AS

SELECT
  p.customer_id,
  p.churn_probability,
  p.risk_level,

  CASE p.risk_level
    WHEN 'High Risk' THEN 1
    WHEN 'Medium Risk' THEN 2
    WHEN 'Low Risk' THEN 3
    ELSE 4
  END AS risk_sort_order,

  p.top_risk_driver,
  p.recommended_action,
  p.membership_revenue_at_risk,
  c.country,
  c.age_group,
  c.acquisition_channel,
  c.primary_device,
  c.plan_type,
  c.membership_status,
  c.tenure_months,
  c.auto_renew_enabled,
  s.customer_segment

FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_risk_predictions` p
LEFT JOIN
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_360` c
  ON p.customer_id = c.customer_id
LEFT JOIN
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_segments` s
  ON p.customer_id = s.customer_id;


-- 7. Retention action summary view

CREATE OR REPLACE VIEW
  `naren-customer-churn-analytics.amazon_prime_reporting.vw_retention_actions`
AS

SELECT
  risk_level,

  CASE risk_level
    WHEN 'High Risk' THEN 1
    WHEN 'Medium Risk' THEN 2
    WHEN 'Low Risk' THEN 3
    ELSE 4
  END AS risk_sort_order,

  top_risk_driver,
  recommended_action,
  COUNT(*) AS customers,
  ROUND(AVG(churn_probability), 4)
    AS average_churn_probability,
  ROUND(SUM(membership_revenue_at_risk), 2)
    AS membership_revenue_at_risk

FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_risk_predictions`

GROUP BY
  risk_level,
  top_risk_driver,
  recommended_action;


-- Check the reporting views

SELECT
  table_name
FROM
  `naren-customer-churn-analytics.amazon_prime_reporting.INFORMATION_SCHEMA.VIEWS`
WHERE
  table_name IN (
    'vw_executive_kpis',
    'vw_churn_retention_trends',
    'vw_customer_segments',
    'vw_churn_drivers',
    'vw_retention_cohorts',
    'vw_customer_risk_predictions',
    'vw_retention_actions'
  )
ORDER BY
  table_name;
