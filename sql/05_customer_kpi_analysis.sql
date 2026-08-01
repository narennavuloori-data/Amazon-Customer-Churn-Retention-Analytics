-- Customer KPI analysis
-- Project: naren-customer-churn-analytics

-- Prepare customer-level KPI fields

CREATE TEMP TABLE kpi_base AS

WITH membership_history AS (
  SELECT
    customer_id,
    membership_id,
    membership_start_date,
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
    customer_id,
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
  GROUP BY
    customer_id
),

payment_summary AS (
  SELECT
    customer_id,
    COUNTIF(payment_status != 'Pending') AS eligible_payment_attempts,
    COUNTIF(payment_status = 'Failed') AS failed_payment_attempts
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_payments`
  GROUP BY
    customer_id
),

support_summary AS (
  SELECT
    customer_id,
    COUNTIF(satisfaction_score IS NOT NULL)
      AS rated_support_interactions,
    SUM(satisfaction_score) AS satisfaction_score_total
  FROM
    `naren-customer-churn-analytics.amazon_prime_analytics.fact_support_interactions`
  GROUP BY
    customer_id
)

SELECT
  c.*,
  DATE_TRUNC(c.signup_date, MONTH) AS signup_month,
  CASE
    WHEN c.tenure_months <= 3 THEN '0-3 months'
    WHEN c.tenure_months <= 6 THEN '4-6 months'
    WHEN c.tenure_months <= 12 THEN '7-12 months'
    WHEN c.tenure_months <= 24 THEN '13-24 months'
    ELSE 'More than 24 months'
  END AS tenure_band,
  COALESCE(r.renewal_opportunities, 0) AS renewal_opportunities,
  COALESCE(r.successful_renewals, 0) AS successful_renewals,
  COALESCE(p.eligible_payment_attempts, 0)
    AS eligible_payment_attempts,
  COALESCE(p.failed_payment_attempts, 0)
    AS failed_payment_attempts,
  COALESCE(s.rated_support_interactions, 0)
    AS rated_support_interactions,
  COALESCE(s.satisfaction_score_total, 0)
    AS satisfaction_score_total
FROM
  `naren-customer-churn-analytics.amazon_prime_analytics.customer_360` c
LEFT JOIN renewal_summary r
  ON c.customer_id = r.customer_id
LEFT JOIN payment_summary p
  ON c.customer_id = p.customer_id
LEFT JOIN support_summary s
  ON c.customer_id = s.customer_id;


-- Overall customer KPIs

SELECT
  COUNT(*) AS total_customers,
  COUNTIF(membership_status = 'Active') AS active_members,
  COUNTIF(churn_flag = 1) AS churned_members,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(churn_flag = 1),
      COUNTIF(churn_flag IS NOT NULL)
    ),
    2
  ) AS churn_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(churn_flag = 0),
      COUNTIF(churn_flag IS NOT NULL)
    ),
    2
  ) AS retention_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      SUM(successful_renewals),
      SUM(renewal_opportunities)
    ),
    2
  ) AS renewal_rate,

  ROUND(AVG(tenure_months), 2) AS average_tenure_months,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(
        membership_status = 'Active'
        AND auto_renew_enabled = TRUE
      ),
      COUNTIF(membership_status = 'Active')
    ),
    2
  ) AS auto_renewal_rate,

  ROUND(
    SAFE_DIVIDE(
      SUM(total_order_value),
      SUM(total_orders)
    ),
    2
  ) AS average_order_value,

  ROUND(
    AVG(total_video_watch_minutes) / 60,
    2
  ) AS average_video_watch_hours,

  ROUND(
    100 * SAFE_DIVIDE(
      SUM(failed_payment_attempts),
      SUM(eligible_payment_attempts)
    ),
    2
  ) AS payment_failure_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(support_tickets > 0),
      COUNT(*)
    ),
    2
  ) AS support_contact_rate,

  ROUND(
    SAFE_DIVIDE(
      SUM(satisfaction_score_total),
      SUM(rated_support_interactions)
    ),
    2
  ) AS average_satisfaction_score

FROM
  kpi_base;


-- Prepare all KPI breakdowns

CREATE TEMP TABLE kpi_breakdowns AS

SELECT
  k.*,
  'Signup Month' AS breakdown_type,
  CAST(signup_month AS STRING) AS breakdown_value
FROM kpi_base k

UNION ALL

SELECT
  k.*,
  'Country',
  country
FROM kpi_base k

UNION ALL

SELECT
  k.*,
  'Acquisition Channel',
  acquisition_channel
FROM kpi_base k

UNION ALL

SELECT
  k.*,
  'Membership Plan',
  plan_type
FROM kpi_base k

UNION ALL

SELECT
  k.*,
  'Age Group',
  age_group
FROM kpi_base k

UNION ALL

SELECT
  k.*,
  'Customer Tenure',
  tenure_band
FROM kpi_base k

UNION ALL

SELECT
  k.*,
  'Primary Device',
  primary_device
FROM kpi_base k;


-- KPI breakdown report

SELECT
  breakdown_type,
  breakdown_value,

  COUNT(*) AS total_customers,
  COUNTIF(membership_status = 'Active') AS active_members,
  COUNTIF(churn_flag = 1) AS churned_members,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(churn_flag = 1),
      COUNTIF(churn_flag IS NOT NULL)
    ),
    2
  ) AS churn_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(churn_flag = 0),
      COUNTIF(churn_flag IS NOT NULL)
    ),
    2
  ) AS retention_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      SUM(successful_renewals),
      SUM(renewal_opportunities)
    ),
    2
  ) AS renewal_rate,

  ROUND(AVG(tenure_months), 2) AS average_tenure_months,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(
        membership_status = 'Active'
        AND auto_renew_enabled = TRUE
      ),
      COUNTIF(membership_status = 'Active')
    ),
    2
  ) AS auto_renewal_rate,

  ROUND(
    SAFE_DIVIDE(
      SUM(total_order_value),
      SUM(total_orders)
    ),
    2
  ) AS average_order_value,

  ROUND(
    AVG(total_video_watch_minutes) / 60,
    2
  ) AS average_video_watch_hours,

  ROUND(
    100 * SAFE_DIVIDE(
      SUM(failed_payment_attempts),
      SUM(eligible_payment_attempts)
    ),
    2
  ) AS payment_failure_rate,

  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(support_tickets > 0),
      COUNT(*)
    ),
    2
  ) AS support_contact_rate,

  ROUND(
    SAFE_DIVIDE(
      SUM(satisfaction_score_total),
      SUM(rated_support_interactions)
    ),
    2
  ) AS average_satisfaction_score

FROM
  kpi_breakdowns

GROUP BY
  breakdown_type,
  breakdown_value

ORDER BY
  breakdown_type,
  breakdown_value;
