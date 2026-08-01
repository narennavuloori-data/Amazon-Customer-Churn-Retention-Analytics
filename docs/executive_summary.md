# Executive Summary

## Project Overview

This project analyses customer churn and retention for a synthetic Amazon Prime-style membership business.

The main goal was to identify customers who are likely to churn, understand the behaviours linked with churn, and recommend practical retention actions.

The project combines customer and membership analysis, shopping and Prime Video behaviour, payment and support activity, customer segmentation, churn prediction, customer-level retention recommendations, and Power BI reporting.

> This is an independent educational portfolio project. It is not affiliated with Amazon and does not use real, proprietary, or confidential Amazon customer data.

---

## Main Business Problem

Customer churn can reduce recurring membership revenue and long-term customer value.

Not every customer leaves for the same reason. Some customers may stop using Prime benefits, some may experience payment failures, some may face delivery or support problems, and others may not understand the full value of their membership.

A single retention campaign is therefore unlikely to work for every customer.

The business needs to:

1. Identify customers with high churn risk.
2. Understand the main reason behind the risk.
3. Prioritise customers with higher revenue at risk.
4. Send a suitable retention action instead of using the same offer for everyone.

---

## Key Findings and Recommendations

### 1. Auto-renewal status is the strongest model signal

**Finding**

Auto-renewal status was the most important feature in the churn model. Customers with auto-renewal disabled showed a much higher churn tendency than customers with auto-renewal enabled.

**Business impact**

Customers who disable auto-renewal may leave without any further interaction with the business. This reduces the opportunity to remind them about the benefits they are using.

**Recommended action**

Send a renewal reminder before the membership end date. The message should explain the customer's recent Prime usage, current benefits, and renewal options.

---

### 2. Inactive customers show higher churn risk

**Finding**

Days since last activity was one of the most important model features. Customers with no recent shopping or Prime Video activity were more likely to churn than regularly active customers.

**Business impact**

Low activity may indicate that customers are no longer receiving enough value from the membership.

**Recommended action**

Create a benefit-education campaign for inactive customers. The campaign should highlight unused shopping, delivery, and Prime Video benefits based on each customer's behaviour.

---

### 3. Customers with payment problems need early intervention

**Finding**

Customers with failed payments and repeated payment retries showed higher churn risk.

**Business impact**

Some membership losses may be involuntary. The customer may not be actively choosing to cancel, but the membership may end because of an expired card, insufficient balance, or another payment issue.

**Recommended action**

Send payment-update reminders as soon as a failure occurs. Allow a short retry period before ending membership access and provide a simple payment-update link.

---

### 4. Low shopping and video engagement are warning signals

**Finding**

Churned customers generally placed fewer orders, spent less, and used Prime Video less than retained customers. Recent activity, order frequency, and video usage were also useful model signals.

**Business impact**

Customers using only one benefit may not see enough value in the complete membership.

**Recommended action**

Promote the most relevant unused benefit:

- Recommend shopping and delivery benefits to Video-first customers.
- Recommend Prime Video content to Shopping-first customers.
- Send onboarding and benefit-discovery messages to new customers with low usage.

---

### 5. Support experience is linked with churn risk

**Finding**

Customers with more support tickets and lower satisfaction scores showed higher churn risk. Repeated delivery complaints were also treated as a service-risk signal.

**Business impact**

Poor support or delivery experiences can reduce trust in the membership and increase the chance of cancellation.

**Recommended action**

Create a service-recovery process for customers with repeated complaints. High-risk customers with low satisfaction should be routed to customer care instead of receiving a general marketing message.

---

### 6. New members need better onboarding

**Finding**

New customers with low engagement were identified as a separate risk group.

**Business impact**

A customer who does not understand or use membership benefits during the first few months may decide that the membership is not useful.

**Recommended action**

Create a 30-day and 60-day onboarding journey covering delivery benefits, Prime Video recommendations, membership savings, auto-renewal settings, and support options.

---

### 7. Customer segments require different campaigns

The analysis created the following customer segments:

- Multi-Benefit Power Users
- Shopping-First Members
- Video-First Members
- New Members
- Low-Engagement Members
- Service-Risk Members
- Payment-Risk Members
- Churned Members

**Business impact**

Customers use Prime in different ways. A message that is relevant to a Video-first customer may not be useful to a Shopping-first customer.

**Recommended action**

| Customer Segment | Recommended Campaign |
|---|---|
| Multi-Benefit Power Users | Loyalty and recognition campaign |
| Shopping-First Members | Promote Prime Video and unused digital benefits |
| Video-First Members | Promote shopping and delivery savings |
| New Members | Structured onboarding campaign |
| Low-Engagement Members | Benefit-education and reactivation campaign |
| Service-Risk Members | Customer-care and service-recovery follow-up |
| Payment-Risk Members | Payment-update and retry reminder |
| Churned Members | Win-back campaign after a suitable waiting period |

---

### 8. High-risk customers should be prioritised by revenue at risk

The final prediction table assigns every eligible customer a churn probability, risk level, main risk driver, recommended action, and estimated membership revenue at risk.

Risk groups:

- Low Risk: below 0.30
- Medium Risk: 0.30 to below 0.70
- High Risk: 0.70 or higher

**Business impact**

The retention team may not have enough capacity to contact every customer. Treating all customers equally would waste time and campaign budget.

**Recommended action**

Prioritise customers in this order:

1. High-risk customers with high revenue at risk
2. High-risk customers with recent payment or service problems
3. Medium-risk customers with declining engagement
4. Low-risk customers through normal engagement campaigns

---

### 9. Acquisition channels should be monitored after signup

**Finding**

Retention and churn vary across acquisition channels.

**Business impact**

A channel may bring a large number of customers but still produce low-quality or short-term memberships.

**Recommended action**

Track each acquisition channel using customer volume, 30-day retention, 90-day retention, churn rate, engagement, and revenue at risk. Marketing investment should consider retention quality, not only signup volume.

---

### 10. Discounts should be targeted rather than offered to everyone

**Finding**

Not every high-risk customer needs a discount. Some customers are at risk because of payment issues, inactivity, or poor service rather than price.

**Business impact**

Giving the same discount to every at-risk customer may reduce revenue without solving the actual problem.

**Recommended action**

Use discounts mainly for customers showing price sensitivity or renewal hesitation. Use non-discount actions for other risk drivers:

- Payment reminder for payment risk
- Service recovery for low satisfaction
- Content recommendation for low video usage
- Benefit education for low engagement
- Renewal reminder for auto-renew disabled customers

---

## Churn Model Summary

Three simple machine-learning models were compared:

- Logistic Regression
- Random Forest
- Gradient Boosting

Gradient Boosting was selected because it provided the best balance for the retention use case.

| Metric | Result |
|---|---:|
| Accuracy | 83.17% |
| Precision | 12.75% |
| Recall | 85.79% |
| F1 Score | 22.19% |
| ROC-AUC | 91.35% |

Recall was given higher importance because the business wants to identify as many likely churners as possible.

The model correctly identified 169 of 197 churners in the test data and missed 28.

The low precision means the model also creates false alerts. Predicted probability should therefore be used to rank customers rather than contacting every predicted churner.

---

## Recommended Retention Strategy

### Immediate priorities

1. Contact high-risk customers with payment failures.
2. Send renewal reminders to customers with auto-renewal disabled.
3. Route high-risk, low-satisfaction customers to customer care.
4. Contact high-value, high-risk customers before renewal.
5. Send onboarding campaigns to new customers with low usage.

### Medium-term improvements

1. Build separate campaigns for Shopping-first and Video-first members.
2. Promote unused benefits to low-engagement customers.
3. Create a service-recovery workflow for repeated delivery issues.
4. Track churn and retention by acquisition channel.
5. Test different actions instead of offering the same discount to everyone.

### Long-term measurement

The business should measure whether retention actions actually work.

Recommended campaign metrics:

- Customers contacted
- Campaign response rate
- Renewal rate
- 30-day retention after contact
- 90-day retention after contact
- Revenue saved
- Discount cost
- Net retention value
- Customer satisfaction after intervention

A controlled test should compare customers who receive an action with similar customers who do not receive it.

---

## Suggested Action Framework

| Main Risk Driver | Recommended Action |
|---|---|
| Low engagement | Send personalised benefit-education campaign |
| No recent orders | Offer shopping or delivery-benefit reminder |
| Low Prime Video activity | Recommend relevant content |
| Payment failure | Send payment-update reminder |
| Auto-renew disabled | Send renewal reminder |
| Delivery complaints | Provide service-recovery communication |
| Low satisfaction | Route to customer-care follow-up |
| High price sensitivity | Offer a suitable renewal incentive |
| New customer with low usage | Send onboarding campaign |
| No major risk signal | Continue regular engagement communication |

---

## Expected Business Value

The proposed approach helps the business move from broad retention campaigns to targeted customer actions.

Expected benefits include:

- Earlier identification of likely churners
- Lower involuntary churn from payment failures
- Better onboarding for new members
- More relevant customer communication
- Improved use of shopping and video benefits
- Better prioritisation of retention resources
- Stronger measurement of membership revenue at risk
- Reduced unnecessary discounting

---

## Limitations

This project uses fully synthetic data.

The model results, feature importance, and business findings are educational examples and should not be interpreted as actual Amazon customer behaviour.

Before using a similar approach in a real business environment, the team should validate business definitions, review data quality and consent requirements, test the model on real unseen data, check fairness across customer groups, monitor model performance, run controlled retention experiments, and review customer communication policies.

---

## Final Conclusion

The analysis shows that churn risk is not driven by one single behaviour.

Important synthetic signals include auto-renewal status, inactivity, membership tenure, payment problems, support experience, and customer engagement.

The strongest retention approach is therefore not one universal campaign. The business should identify the customer's main risk driver, estimate the value at risk, and assign a suitable action.

```text
Customer activity
        ↓
Churn probability
        ↓
Risk level
        ↓
Main risk driver
        ↓
Recommended retention action
        ↓
Campaign measurement
```

The final Power BI dashboard supports this process by showing executive KPIs, churn trends, customer segments, churn drivers, predicted risk, and recommended actions.
