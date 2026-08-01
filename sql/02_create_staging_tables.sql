-- Create the staging tables
-- Project: naren-customer-churn-analytics

-- Customer master data
CREATE TABLE IF NOT EXISTS
  `naren-customer-churn-analytics.amazon_prime_staging.customers`
(
  customer_id STRING,
  signup_date DATE,
  country STRING,
  state STRING,
  city_tier STRING,
  age_group STRING,
  preferred_language STRING,
  acquisition_channel STRING,
  primary_device STRING,
  email_marketing_opt_in BOOL,
  account_status STRING
);

-- Membership data
CREATE TABLE IF NOT EXISTS
  `naren-customer-churn-analytics.amazon_prime_staging.memberships`
(
  membership_id STRING,
  customer_id STRING,
  membership_start_date DATE,
  plan_type STRING,
  billing_cycle STRING,
  membership_fee NUMERIC,
  auto_renew_enabled BOOL,
  renewal_date DATE,
  membership_end_date DATE,
  membership_status STRING,
  cancellation_date DATE,
  cancellation_reason STRING,
  discount_applied STRING
);

-- Shopping activity
CREATE TABLE IF NOT EXISTS
  `naren-customer-churn-analytics.amazon_prime_staging.orders`
(
  order_id STRING,
  customer_id STRING,
  order_date DATE,
  order_value NUMERIC,
  product_category STRING,
  items_count INT64,
  delivery_speed STRING,
  delivered_late_flag BOOL,
  returned_flag BOOL,
  shipping_fee_saved NUMERIC,
  order_status STRING
)
PARTITION BY order_date
CLUSTER BY customer_id;

-- Prime Video activity
CREATE TABLE IF NOT EXISTS
  `naren-customer-churn-analytics.amazon_prime_staging.prime_video_activity`
(
  activity_id STRING,
  customer_id STRING,
  activity_date DATE,
  content_type STRING,
  genre STRING,
  watch_minutes NUMERIC,
  sessions_count INT64,
  titles_watched INT64,
  completion_rate FLOAT64,
  device_type STRING
)
PARTITION BY activity_date
CLUSTER BY customer_id;

-- Membership payments
CREATE TABLE IF NOT EXISTS
  `naren-customer-churn-analytics.amazon_prime_staging.payments`
(
  payment_id STRING,
  membership_id STRING,
  customer_id STRING,
  payment_date DATE,
  payment_amount NUMERIC,
  payment_method STRING,
  payment_status STRING,
  failure_reason STRING,
  retry_count INT64,
  refund_flag BOOL
)
PARTITION BY payment_date
CLUSTER BY customer_id;

-- Customer support activity
CREATE TABLE IF NOT EXISTS
  `naren-customer-churn-analytics.amazon_prime_staging.support_interactions`
(
  ticket_id STRING,
  customer_id STRING,
  ticket_date DATE,
  issue_category STRING,
  support_channel STRING,
  priority STRING,
  resolution_hours NUMERIC,
  resolved_flag BOOL,
  satisfaction_score FLOAT64,
  repeat_contact_flag BOOL
)
PARTITION BY ticket_date
CLUSTER BY customer_id;
