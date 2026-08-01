-- Row count check

WITH row_counts AS (
  SELECT 'customers' AS table_name, COUNT(*) AS row_count, 50000 AS expected_row_count
  FROM `naren-customer-churn-analytics.amazon_prime_staging.customers`

  UNION ALL

  SELECT 'memberships', COUNT(*), 55000
  FROM `naren-customer-churn-analytics.amazon_prime_staging.memberships`

  UNION ALL

  SELECT 'orders', COUNT(*), 399976
  FROM `naren-customer-churn-analytics.amazon_prime_staging.orders`

  UNION ALL

  SELECT 'prime_video_activity', COUNT(*), 549970
  FROM `naren-customer-churn-analytics.amazon_prime_staging.prime_video_activity`

  UNION ALL

  SELECT 'payments', COUNT(*), 124984
  FROM `naren-customer-churn-analytics.amazon_prime_staging.payments`

  UNION ALL

  SELECT 'support_interactions', COUNT(*), 34990
  FROM `naren-customer-churn-analytics.amazon_prime_staging.support_interactions`
)

SELECT
  table_name,
  row_count,
  expected_row_count,
  IF(row_count = expected_row_count, 'Matched', 'Check') AS load_status
FROM row_counts
ORDER BY table_name;


-- Final data-quality summary

WITH checks AS (

  SELECT
    'Duplicate Customer IDs' AS check_name,
    COUNT(*) AS failed_record_count
  FROM (
    SELECT customer_id
    FROM `naren-customer-churn-analytics.amazon_prime_staging.customers`
    GROUP BY customer_id
    HAVING COUNT(*) > 1
  )

  UNION ALL

  SELECT
    'Duplicate Membership IDs',
    COUNT(*)
  FROM (
    SELECT membership_id
    FROM `naren-customer-churn-analytics.amazon_prime_staging.memberships`
    GROUP BY membership_id
    HAVING COUNT(*) > 1
  )

  UNION ALL

  SELECT
    'Duplicate Order IDs',
    COUNT(*)
  FROM (
    SELECT order_id
    FROM `naren-customer-churn-analytics.amazon_prime_staging.orders`
    GROUP BY order_id
    HAVING COUNT(*) > 1
  )

  UNION ALL

  SELECT
    'Duplicate Video Activity IDs',
    COUNT(*)
  FROM (
    SELECT activity_id
    FROM `naren-customer-churn-analytics.amazon_prime_staging.prime_video_activity`
    GROUP BY activity_id
    HAVING COUNT(*) > 1
  )

  UNION ALL

  SELECT
    'Duplicate Payment IDs',
    COUNT(*)
  FROM (
    SELECT payment_id
    FROM `naren-customer-churn-analytics.amazon_prime_staging.payments`
    GROUP BY payment_id
    HAVING COUNT(*) > 1
  )

  UNION ALL

  SELECT
    'Duplicate Support Ticket IDs',
    COUNT(*)
  FROM (
    SELECT ticket_id
    FROM `naren-customer-churn-analytics.amazon_prime_staging.support_interactions`
    GROUP BY ticket_id
    HAVING COUNT(*) > 1
  )

  UNION ALL

  SELECT
    'Null Customer IDs',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.customers`
  WHERE customer_id IS NULL OR TRIM(customer_id) = ''

  UNION ALL

  SELECT
    'Null Membership IDs',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.memberships`
  WHERE membership_id IS NULL OR TRIM(membership_id) = ''

  UNION ALL

  SELECT
    'Null Order IDs',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.orders`
  WHERE order_id IS NULL OR TRIM(order_id) = ''

  UNION ALL

  SELECT
    'Null Video Activity IDs',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.prime_video_activity`
  WHERE activity_id IS NULL OR TRIM(activity_id) = ''

  UNION ALL

  SELECT
    'Null Payment IDs',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.payments`
  WHERE payment_id IS NULL OR TRIM(payment_id) = ''

  UNION ALL

  SELECT
    'Null Support Ticket IDs',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.support_interactions`
  WHERE ticket_id IS NULL OR TRIM(ticket_id) = ''

  UNION ALL

  SELECT
    'Memberships Without Customer',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.memberships` m
  LEFT JOIN `naren-customer-churn-analytics.amazon_prime_staging.customers` c
    ON m.customer_id = c.customer_id
  WHERE m.customer_id IS NOT NULL
    AND c.customer_id IS NULL

  UNION ALL

  SELECT
    'Orders Without Customer',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.orders` o
  LEFT JOIN `naren-customer-churn-analytics.amazon_prime_staging.customers` c
    ON o.customer_id = c.customer_id
  WHERE o.customer_id IS NOT NULL
    AND c.customer_id IS NULL

  UNION ALL

  SELECT
    'Video Activity Without Customer',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.prime_video_activity` v
  LEFT JOIN `naren-customer-churn-analytics.amazon_prime_staging.customers` c
    ON v.customer_id = c.customer_id
  WHERE v.customer_id IS NOT NULL
    AND c.customer_id IS NULL

  UNION ALL

  SELECT
    'Payments Without Customer',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.payments` p
  LEFT JOIN `naren-customer-churn-analytics.amazon_prime_staging.customers` c
    ON p.customer_id = c.customer_id
  WHERE p.customer_id IS NOT NULL
    AND c.customer_id IS NULL

  UNION ALL

  SELECT
    'Payments Without Membership',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.payments` p
  LEFT JOIN `naren-customer-churn-analytics.amazon_prime_staging.memberships` m
    ON p.membership_id = m.membership_id
  WHERE p.membership_id IS NOT NULL
    AND m.membership_id IS NULL

  UNION ALL

  SELECT
    'Support Tickets Without Customer',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.support_interactions` s
  LEFT JOIN `naren-customer-churn-analytics.amazon_prime_staging.customers` c
    ON s.customer_id = c.customer_id
  WHERE s.customer_id IS NOT NULL
    AND c.customer_id IS NULL

  UNION ALL

  SELECT
    'Membership End Before Start',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.memberships`
  WHERE membership_end_date < membership_start_date

  UNION ALL

  SELECT
    'Cancellation Before Membership Start',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.memberships`
  WHERE cancellation_date < membership_start_date

  UNION ALL

  SELECT
    'Renewal Before Membership Start',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.memberships`
  WHERE renewal_date < membership_start_date

  UNION ALL

  SELECT
    'Orders Before Customer Signup',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.orders` o
  JOIN `naren-customer-churn-analytics.amazon_prime_staging.customers` c
    ON o.customer_id = c.customer_id
  WHERE o.order_date < c.signup_date

  UNION ALL

  SELECT
    'Negative Membership Fees',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.memberships`
  WHERE membership_fee < 0

  UNION ALL

  SELECT
    'Negative Order Values',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.orders`
  WHERE order_value < 0

  UNION ALL

  SELECT
    'Negative Shipping Savings',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.orders`
  WHERE shipping_fee_saved < 0

  UNION ALL

  SELECT
    'Negative Payment Amounts',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.payments`
  WHERE payment_amount < 0

  UNION ALL

  SELECT
    'Negative Watch Minutes',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.prime_video_activity`
  WHERE watch_minutes < 0

  UNION ALL

  SELECT
    'Invalid Membership Status',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.memberships`
  WHERE membership_status IS NULL
     OR membership_status NOT IN (
       'Active',
       'Cancelled',
       'Expired',
       'Paused',
       'Payment Pending'
     )

  UNION ALL

  SELECT
    'Invalid Payment Status',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.payments`
  WHERE payment_status IS NULL
     OR payment_status NOT IN (
       'Successful',
       'Failed',
       'Pending',
       'Refunded'
     )

  UNION ALL

  SELECT
    'Invalid Satisfaction Scores',
    COUNT(*)
  FROM `naren-customer-churn-analytics.amazon_prime_staging.support_interactions`
  WHERE satisfaction_score IS NOT NULL
    AND (satisfaction_score < 1 OR satisfaction_score > 5)
)

SELECT
  check_name,
  failed_record_count,
  IF(failed_record_count = 0, 'Passed', 'Failed') AS quality_status
FROM checks
ORDER BY
  failed_record_count = 0,
  check_name;
