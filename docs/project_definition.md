# End-to-End Amazon Prime Customer Churn & Retention Analytics

## Project Definition

### Project Type

Independent educational portfolio project using fully synthetic data.

---

## 1. Project Overview

**End-to-End Amazon Prime Customer Churn & Retention Analytics** is a customer analytics portfolio project that simulates how a subscription-retention team could study Amazon Prime membership behaviour.

The project combines customer profile, membership, shopping, Prime Video, payment and customer-support data to understand why customers cancel their memberships, measure retention performance, identify high-risk customers and recommend suitable retention actions.

The project follows a complete analytics workflow:

> Synthetic data generation → Data validation → Data cleaning → Exploratory data analysis → BigQuery data modelling → SQL analysis → Customer segmentation → Retention and cohort analysis → Churn prediction → Model explanation → Power BI dashboard → Business recommendations

---

## 2. Assumed Role

**Customer Analytics Data Analyst — Amazon Prime Retention Team**

In this fictional role, the analyst is responsible for:

- Monitoring membership churn and retention.
- Studying customer shopping and Prime Video engagement.
- Identifying customer groups with high churn rates.
- Investigating payment, delivery and support-related problems.
- Building customer segments for targeted analysis.
- Creating a model that predicts future churn risk.
- Converting analytical findings into practical retention recommendations.
- Presenting results through an executive Power BI dashboard.

---

## 3. Product Being Analysed

The product being analysed is **Amazon Prime**, a subscription membership ecosystem that may provide customers with benefits such as:

- Shopping and delivery benefits.
- Prime Video entertainment.
- Membership discounts and promotions.
- Convenience across multiple Amazon services.

The project focuses on the relationship between customer behaviour, benefit usage, service experience, payment activity and membership retention.

This project does not attempt to reproduce Amazon's internal systems, confidential processes or proprietary performance metrics.

---

## 4. Business Problem

Amazon Prime operates as a subscription ecosystem where customers may receive value from shopping, delivery and digital entertainment benefits.

In this fictional business scenario, some customers continue renewing their memberships while others cancel or allow their memberships to expire. The retention team needs a clear understanding of the behaviours and experiences associated with customer churn.

The fictional retention team wants to:

- Understand why some members cancel.
- Measure churn and retention over time.
- Identify customer groups with higher churn rates.
- Detect customers who may be at risk before they leave.
- Understand whether low usage, payment failures, delivery problems or support issues are connected with churn.
- Design targeted retention strategies instead of sending the same offer to every customer.

Without this analysis, the business may react only after customers have already cancelled. A data-driven churn and retention system can help the team prioritise customers, understand their likely risk drivers and choose more relevant retention actions.

---

## 5. Project Objective

The main objective is to build an end-to-end customer churn and retention analytics solution using realistic synthetic Amazon Prime-style data.

The project will:

1. Generate six realistic and related CSV datasets.
2. Validate and clean the raw data using Python and pandas.
3. Explore customer, membership, shopping, video, payment and support behaviour.
4. Store cleaned data in Google BigQuery.
5. Build simple analytics tables and a customer-level `customer_360` table.
6. Calculate important churn, retention and engagement KPIs using SQL.
7. Perform customer retention and cohort analysis.
8. Create understandable customer segments.
9. Engineer behavioural features for machine learning.
10. Train and compare churn-prediction models.
11. Estimate each customer's probability of future churn.
12. Explain the most important churn drivers.
13. Assign customer risk levels and recommended retention actions.
14. Build an interactive Power BI dashboard.
15. Communicate findings through business recommendations and GitHub documentation.

---

## 6. Main Analytical Questions

The project will answer questions such as:

### Membership

- How many customers are active, retained, renewed or churned?
- How does churn change over time?
- Which membership plans and tenure groups have the highest churn rates?
- Does auto-renewal status affect retention?

### Shopping and Delivery

- Do frequent shoppers retain longer?
- Does recent shopping inactivity increase churn risk?
- Are late deliveries and returns associated with higher churn?

### Prime Video

- Are customers with regular Prime Video activity more likely to remain subscribed?
- Does declining watch activity appear before churn?
- Do customers who use multiple Prime benefits retain longer?

### Payments and Support

- Are failed payments associated with membership cancellation?
- Do repeated support interactions increase churn?
- Does customer satisfaction affect retention?

### Prediction and Action

- Which active customers are most likely to churn?
- What factors contribute most to their risk?
- Which customers should be prioritised by the retention team?
- What retention action is appropriate for each major risk driver?

---

## 7. Project Scope

### Included in Scope

- Synthetic customer and membership data generation.
- Data-quality validation and cleaning.
- Exploratory data analysis.
- BigQuery staging, analytics and reporting layers.
- Customer KPI analysis.
- Churn-driver analysis.
- Retention and cohort analysis.
- Rule-based customer segmentation.
- Machine-learning feature engineering.
- Churn prediction and model evaluation.
- Feature-importance analysis.
- Customer risk classification.
- Retention-action recommendations.
- Power BI dashboard development.
- GitHub documentation and project presentation.

### Excluded from Scope

- Actual Amazon customer data.
- Confidential or proprietary Amazon metrics.
- Production deployment of the machine-learning model.
- Real-time data streaming.
- Automated marketing-campaign execution.
- Access to Amazon's internal systems.
- Claims about Amazon's actual churn rate, revenue or customer behaviour.

Keeping these items outside the scope makes the project clear, achievable and suitable for a data-analyst portfolio.

---

## 8. Technology Stack

| Project Area | Technology | Purpose |
|---|---|---|
| Dataset generation | ChatGPT or Claude | Generate realistic synthetic CSV data |
| Data analysis | Python | Run validation, cleaning and analysis |
| Data manipulation | pandas and NumPy | Transform and aggregate customer data |
| Visual exploration | Matplotlib | Create simple exploratory charts |
| Machine learning | scikit-learn | Train and evaluate churn models |
| Model storage | joblib | Save the selected churn model |
| Cloud data warehouse | Google BigQuery | Store and analyse cleaned data |
| SQL | BigQuery SQL | Build KPIs, cohorts, segments and reporting views |
| Business intelligence | Power BI | Create interactive dashboards |
| Development environment | Visual Studio Code and Jupyter Notebook | Write and run project code |
| Version control | Git and GitHub | Store, document and present the project |

---

## 9. Dataset Approach

The project will use a fully synthetic dataset generated with ChatGPT or Claude.

The data will be designed to resemble realistic subscription-customer behaviour while remaining fictional and safe for educational use.

### Recommended Data Period

**July 1, 2024 to June 30, 2026**

This two-year period supports:

- Monthly trend analysis.
- Customer cohort analysis.
- Renewal and cancellation analysis.
- Seasonal shopping and video activity.
- Churn prediction using historical behaviour.

### Planned Data Files

| File | Main Purpose |
|---|---|
| `customers.csv` | Customer profile and acquisition information |
| `memberships.csv` | Membership plans, renewals, cancellations and status |
| `orders.csv` | Shopping, delivery and return behaviour |
| `prime_video_activity.csv` | Prime Video engagement behaviour |
| `payments.csv` | Membership payment success, failure and retry activity |
| `support_interactions.csv` | Customer-service issues, resolution and satisfaction |

### Dataset Design Principles

The synthetic dataset will include:

- Unique primary keys.
- Valid relationships between files.
- Realistic customer and activity dates.
- Seasonal behaviour.
- Different customer-engagement levels.
- A realistic churn imbalance.
- Meaningful relationships between behaviour and churn.
- Controlled missing values.
- Controlled duplicates.
- Text-format inconsistencies.
- A small number of invalid records for cleaning practice.
- Random variation so that churn is not perfectly predictable.

The generated data will not be described as official, leaked, internal or real Amazon data.

---

## 10. Churn Concept

A customer will generally be considered churned when the membership is cancelled or expires without a later renewal during the analysis period.

For the machine-learning use case, historical customer behaviour will be used to predict whether an active customer is likely to churn during a future prediction window.

The final detailed business and technical rules will be documented separately in:

`docs/churn_definition.md`

Direct outcome fields such as cancellation date, cancellation reason and final membership status will not be used as model inputs because they would cause data leakage.

---

## 11. Expected Project Deliverables

The completed project will contain:

### Data Deliverables

- Six raw synthetic CSV files.
- Six cleaned CSV files.
- A complete data dictionary.
- A customer-level machine-learning dataset.

### Python Deliverables

- Data-validation and cleaning notebook.
- Exploratory data-analysis notebook.
- Feature-engineering notebook.
- Churn-modelling notebook.
- Model-explanation and retention-actions notebook.

### BigQuery and SQL Deliverables

- Staging tables.
- Analytics dimensions and fact tables.
- A customer-level `customer_360` table.
- Customer KPI queries.
- Churn-driver analysis.
- Retention and cohort analysis.
- Customer segmentation.
- Power BI reporting views.

### Machine-Learning Deliverables

- Trained churn model.
- Model-comparison metrics.
- Churn probability for each eligible customer.
- Customer risk levels.
- Feature-importance results.
- Recommended retention actions.

### Power BI Deliverables

A five-page dashboard containing:

1. Executive Overview.
2. Churn and Retention.
3. Customer Segmentation.
4. Churn Drivers.
5. Prediction and Retention Actions.

### Documentation Deliverables

- Project definition.
- Business requirements.
- KPI dictionary.
- Churn definition.
- Data model documentation.
- Executive summary.
- Architecture diagram.
- Star-schema diagram.
- Complete GitHub README.
- Dashboard screenshots.

---

## 12. Expected Business Value

The project will demonstrate how customer data can support decisions such as:

- Identifying customers who need immediate retention attention.
- Understanding which behaviours are associated with churn.
- Separating payment-related churn from engagement-related churn.
- Designing different actions for different customer segments.
- Prioritising high-risk and high-value customers.
- Improving onboarding for new and low-engagement members.
- Tracking churn and retention performance over time.
- Estimating membership revenue at risk.
- Communicating findings clearly to business stakeholders.

The recommendations produced by this project are simulated educational recommendations and are not recommendations made for Amazon.

---

## 13. Project Success Criteria

The project will be considered complete when:

- All six datasets are generated and correctly related.
- Raw data-quality issues are identified and cleaned.
- Processed data is successfully loaded into BigQuery.
- The analytics model and `customer_360` table are created.
- Churn, retention and engagement KPIs are calculated.
- Retention cohorts and customer segments are produced.
- At least three churn models are trained and compared.
- The selected model is evaluated using appropriate metrics.
- Customer-level risk scores and retention actions are generated.
- The five Power BI dashboard pages are completed.
- Key findings and recommendations are documented.
- The GitHub repository is organised and understandable.
- The educational disclaimer is visible in the README and dashboard.

---

## 14. Educational Disclaimer

This is an independent educational portfolio project created to demonstrate customer analytics, data cleaning, SQL, cloud data warehousing, machine learning, business intelligence and communication skills.

Amazon and Amazon Prime are trademarks of Amazon.com, Inc. This project is not affiliated with, endorsed by or sponsored by Amazon.

All data used in this project is fully synthetic and generated solely for educational purposes. It does not contain actual Amazon customer information, confidential business data, proprietary metrics or internal Amazon records.

The customer behaviours, business scenarios, churn relationships, analytical findings and recommendations are simulated. They must not be interpreted as statements about Amazon's actual customers, operations, performance or business strategy.

---

## 15. Final Project Statement

This project simulates an end-to-end customer-retention analytics solution for Amazon Prime using fully synthetic data.

Its purpose is to demonstrate how a modern data analyst can combine Python, SQL, BigQuery, machine learning and Power BI to understand customer behaviour, predict churn risk and translate data into clear business actions.
