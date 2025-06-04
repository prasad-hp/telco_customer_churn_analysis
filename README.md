# 📊 Customer Churn Analysis Project

A comprehensive SQL-based analysis of telecom customer churn patterns using PostgreSQL to drive data-driven retention strategies and assess revenue impact.

## 🎯 Project Overview

This project analyzes customer churn behavior across 7,043 telecom customers to identify key retention opportunities and quantify business impact. Through systematic SQL analysis, we uncover critical insights about customer segments, service preferences, and revenue at risk.

## 🛠️ Technology Stack

- **Database**: PostgreSQL
- **Language**: SQL
- **Data Source**: Telecom customer dataset (7,043 records)
- **Analysis Type**: Exploratory Data Analysis (EDA), Customer Segmentation, Revenue Impact Assessment

## 📋 Dataset Information

- **Total Customers**: 7,043
- **Features**: 21 customer attributes
- **Target Variable**: Churn (Yes/No)
- **Key Dimensions**: Demographics, Services, Contract Terms, Billing, Usage Patterns

### Dataset Schema
```sql
- customerID: Unique customer identifier
- Demographics: gender, SeniorCitizen, Partner, Dependents
- Account Info: tenure, Contract, PaperlessBilling, PaymentMethod
- Services: PhoneService, MultipleLines, InternetService, OnlineSecurity, etc.
- Financial: MonthlyCharges, TotalCharges
- Target: Churn (Yes/No)
```

## 🔍 Key Findings & Business Impact

### Executive KPIs
- **Overall Churn Rate**: 26.5%
- **Average Customer Tenure**: 32.4 months
- **Average Monthly Revenue per Customer**: $64.76
- **Monthly Revenue at Risk**: ~$265K (from churned customers)
- **Monthly Revenue Retained**: ~$3.4M

### Critical Insights
- 📈 **Highest Risk Segments**: Month-to-month contracts (42% churn rate)
- 🌐 **Service Impact**: Fiber optic internet users show 41% churn rate
- 👥 **Demographics**: Senior citizens have significantly higher churn rates
- 💰 **Revenue Impact**: Early tenure customers represent highest revenue risk

## 🚀 Analysis Methodology

### 1. Data Preparation & Cleaning
- Converted `TotalCharges` from string to numeric format
- Handled 11 missing/null values (0.16% of dataset)
- Validated data integrity across all 7,043 records

### 2. Feature Engineering
```sql
-- Created derived columns for analysis
- churn_binary: Binary encoding (1=churned, 0=retained)
- tenure_group: Customer lifecycle stages
- monthly_charges_category: Revenue tier segmentation
```

### 3. Comprehensive Analysis Framework
- **Demographics Analysis**: Gender, age, family status
- **Service Analysis**: Internet, phone, add-on services
- **Contract Analysis**: Terms, billing, payment methods
- **Tenure Analysis**: Customer lifecycle and loyalty patterns
- **Revenue Analysis**: Financial impact and risk assessment

## 📈 Key Analytical Queries

### Churn Rate by Contract Type
```sql
SELECT 
    contract,
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY contract
ORDER BY churn_rate_percent DESC;
```

### Revenue Impact Assessment
```sql
SELECT 
    churn,
    COUNT(*) as customer_count,
    ROUND(SUM(monthlycharges), 2) AS total_monthly_revenue
FROM customer_churn
GROUP BY churn;
```

## 📊 Visualization & Insights

### High-Risk Customer Segments
1. **Month-to-Month + Fiber Optic**: Highest churn combination
2. **Senior Citizens**: 2x higher churn rate than average
3. **New Customers (0-12 months)**: Critical retention period
4. **High-Value Customers**: Premium service users at risk

### Retention Opportunities
- **Contract Incentives**: Encourage longer-term commitments
- **Service Bundling**: Reduce churn through add-on services
- **Early Engagement**: Focus on first-year customer experience
- **Senior Customer Programs**: Targeted retention strategies

## 🎯 Business Recommendations

### Immediate Actions
1. **Retention Campaigns**: Target month-to-month contract customers
2. **Service Quality**: Address fiber optic service issues
3. **Senior Support**: Enhanced customer service for 65+ segment
4. **New Customer Onboarding**: Strengthen first 12-month experience

### Strategic Initiatives
- Implement predictive churn modeling
- Develop customer lifetime value optimization
- Create personalized retention offers
- Establish proactive customer success programs

## 🚀 Getting Started

### Prerequisites
- PostgreSQL 12+ installed
- Basic SQL knowledge
- Dataset access (customer_churn.csv)

### Setup Instructions
1. **Clone Repository**
   ```bash
   git clone https://github.com/prasad-hp/telco_customer_churn_analysis.git
   cd telco_customer_churn_analysis
   ```

2. **Database Setup**
   ```sql
   -- Create database
   CREATE DATABASE churn_analysis;
   
   -- Run setup scripts in order
   \i sql/01_table_creation.sql
   \i sql/02_data_cleaning.sql
   \i sql/03_feature_engineering.sql
   ```

3. **Execute Analysis**
   ```sql
   -- Run comprehensive analysis
   \i sql/04_exploratory_analysis.sql
   \i sql/05_business_insights.sql
   ```

## 📊 Sample Results

### Churn Rate by Tenure Group
| Tenure Group | Total Customers | Churned | Churn Rate |
|--------------|----------------|---------|------------|
| New (0-12 months) | 2,175 | 1,037 | 47.7% |
| Medium (13-24 months) | 1,108 | 324 | 29.2% |
| Long (25-48 months) | 1,473 | 226 | 15.3% |
| Loyal (48+ months) | 2,287 | 282 | 12.3% |

### Revenue Impact Summary
| Metric | Amount |
|--------|--------|
| Monthly Revenue at Risk | $265,031 |
| Monthly Revenue Retained | $3,391,205 |
| Average Monthly Charge (Churned) | $74.44 |
| Average Monthly Charge (Retained) | $61.27 |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines
- Follow SQL best practices and formatting standards
- Document new analysis queries with clear comments
- Include business context for new insights
- Test all queries before submission


## 👤 Author

**Your Name**
- LinkedIn: linkedin.com/in/prasadhp
- GitHub: https://github.com/prasad-hp
- Email: itsprasadhp@gmail.com

## 🙏 Acknowledgments

- Dataset provided by [Source Organization]
- Inspired by real-world telecom industry challenges
- Built for educational and analytical purposes

---

⭐ **If you found this analysis helpful, please consider giving it a star!** ⭐
