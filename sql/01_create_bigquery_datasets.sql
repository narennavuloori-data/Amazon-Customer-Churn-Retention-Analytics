-- Creating the BigQuery datasets
-- Project: naren-customer-churn-analytics
-- Region: asia-south1

-- Stores cleaned CSV data
CREATE SCHEMA IF NOT EXISTS
  `naren-customer-churn-analytics`.`amazon_prime_staging`
OPTIONS (
  location = 'asia-south1',
  description = 'Stores cleaned CSV data with minimal transformation'
);

-- Stores dimensions, facts, customer features, cohorts and segments
CREATE SCHEMA IF NOT EXISTS
  `naren-customer-churn-analytics`.`amazon_prime_analytics`
OPTIONS (
  location = 'asia-south1',
  description = 'Stores analytics tables, customer features, cohorts and segments'
);

-- Stores final views used by Power BI
CREATE SCHEMA IF NOT EXISTS
  `naren-customer-churn-analytics`.`amazon_prime_reporting`
OPTIONS (
  location = 'asia-south1',
  description = 'Stores final reporting views used by Power BI'
);
