-- =====================================================
-- CUSTOMER CHURN ANALYSIS - COMPREHENSIVE SQL SCRIPT
-- =====================================================

-- =====================================================
-- 1. TABLE CREATION AND SETUP
-- =====================================================

-- Create main customer churn table
CREATE TABLE customer_churn (
    customerID VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(10),
    SeniorCitizen INT,
    Partner VARCHAR(5),
    Dependents VARCHAR(5),
    tenure INT,
    PhoneService VARCHAR(5),
    MultipleLines VARCHAR(25),
    InternetService VARCHAR(25),
    OnlineSecurity VARCHAR(25),
    OnlineBackup VARCHAR(25),
    DeviceProtection VARCHAR(25),
    TechSupport VARCHAR(25),
    StreamingTV VARCHAR(25),
    StreamingMovies VARCHAR(25),
    Contract VARCHAR(25),
    PaperlessBilling VARCHAR(5),
    PaymentMethod VARCHAR(35),
    MonthlyCharges DECIMAL(8,2),
    TotalCharges VARCHAR(20),
    Churn VARCHAR(5)
);

-- Verify table creation
SELECT * FROM customer_churn;

-- Insert data from CSV file (data import step)
-- Note: Data imported from external CSV file

-- =====================================================
-- 2. INITIAL DATA EXPLORATION
-- =====================================================

-- Preview first 10 records
SELECT * FROM customer_churn
LIMIT 10;

-- Get total customer count
SELECT COUNT(*) as total_customers FROM customer_churn;
-- Result: 7043 customers

-- Check data completeness and identify issues
SELECT 
    COUNT(*) as total_rows,
    COUNT(customerID) as non_null_customer_ids,
    COUNT(CASE WHEN TotalCharges = '' OR TotalCharges = ' ' THEN 1 END) as empty_total_charges
FROM customer_churn;
-- Results: 7043 total rows, 7043 non-null IDs, some empty charge fields

-- =====================================================
-- 3. DATA CLEANING AND PREPARATION
-- =====================================================

-- Clean TotalCharges: Replace empty strings with NULL
UPDATE customer_churn
SET totalcharges = NULL
WHERE totalcharges = '' OR totalcharges = ' ';

-- Verify null values in TotalCharges
SELECT COUNT(*) AS null_total_charges_count 
FROM customer_churn
WHERE totalcharges IS NULL;
-- Result: 11 null values

-- Add numeric version of TotalCharges for calculations
ALTER TABLE customer_churn
ADD COLUMN Total_Charges_Numeric DECIMAL(10,2);

-- Convert valid TotalCharges to numeric format
UPDATE customer_churn
SET Total_Charges_Numeric = CAST(totalcharges AS DECIMAL(10, 2))
WHERE totalcharges IS NOT NULL;

-- Create binary churn indicator (1 = churned, 0 = retained)
ALTER TABLE customer_churn
ADD COLUMN churn_binary INT;

UPDATE customer_churn
SET churn_binary = (
    CASE 
        WHEN churn = 'Yes' THEN 1
        ELSE 0
    END
);

-- =====================================================
-- 4. FEATURE ENGINEERING - DERIVED COLUMNS
-- =====================================================

-- Create tenure groups for customer lifecycle analysis
ALTER TABLE customer_churn
ADD COLUMN tenure_group VARCHAR(50);

UPDATE customer_churn
SET tenure_group = (
    CASE
        WHEN tenure <= 12 THEN 'New (0-12 Months)'
        WHEN tenure <= 24 THEN 'Medium (13-24 Months)'
        WHEN tenure <= 48 THEN 'Long (25-48 Months)'
        ELSE 'Loyal (48+ Months)'
    END
);

-- Verify tenure group distribution
SELECT tenure_group, COUNT(*) AS customer_count 
FROM customer_churn
GROUP BY tenure_group
ORDER BY customer_count DESC;

-- Analyze monthly charges distribution for categorization
SELECT 
    MIN(monthlycharges) as min_charges,
    MAX(monthlycharges) as max_charges,
    AVG(monthlycharges) as avg_charges,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY monthlycharges) as median_charges
FROM customer_churn;
-- Results: Min: 18.25, Max: 118.75, Median: ~70.35

-- Create monthly charges categories
ALTER TABLE customer_churn
ADD COLUMN monthly_charges_category VARCHAR(50);

UPDATE customer_churn
SET monthly_charges_category = (
    CASE
        WHEN monthlycharges <= 35 THEN 'Low'
        WHEN monthlycharges <= 65 THEN 'Medium'
        WHEN monthlycharges <= 90 THEN 'High'
        ELSE 'Very High'
    END
);

-- Verify monthly charges category distribution
SELECT monthly_charges_category, COUNT(*) AS category_count 
FROM customer_churn
GROUP BY monthly_charges_category
ORDER BY category_count DESC;

-- =====================================================
-- 5. CHURN RATE ANALYSIS
-- =====================================================

-- Overall churn rate
SELECT 
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS overall_churn_rate_percent
FROM customer_churn;

-- Gender-based churn analysis
SELECT 
    gender, 
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY gender
ORDER BY churn_rate_percent DESC;

-- Age category churn analysis (Senior vs Non-Senior)
SELECT 
    CASE
        WHEN seniorcitizen = 1 THEN 'Senior Citizen'
        ELSE 'Non-Senior Citizen'
    END AS customer_age_category,
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY seniorcitizen
ORDER BY churn_rate_percent DESC;

-- =====================================================
-- 6. CUSTOMER DEMOGRAPHICS IMPACT ON CHURN
-- =====================================================

-- Family status impact on churn (Partner and Dependents)
SELECT 
    partner,
    dependents,
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY partner, dependents
ORDER BY churn_rate_percent DESC;

-- =====================================================
-- 7. SERVICE-RELATED CHURN ANALYSIS
-- =====================================================

-- Internet service type impact on churn
SELECT 
    internetservice,
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY internetservice
ORDER BY churn_rate_percent DESC;

-- Phone service impact on churn
SELECT 
    phoneservice,
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY phoneservice
ORDER BY churn_rate_percent DESC;

-- Multiple lines service impact
SELECT 
    multiplelines,
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY multiplelines
ORDER BY churn_rate_percent DESC;

-- Add-on services impact on churn
SELECT 
    'Online Security' as service_type, onlinesecurity as service_status,
    COUNT(*) as total_customers, SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY onlinesecurity
UNION ALL
SELECT 
    'Online Backup' as service_type, onlinebackup as service_status,
    COUNT(*) as total_customers, SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY onlinebackup
UNION ALL
SELECT 
    'Device Protection' as service_type, deviceprotection as service_status,
    COUNT(*) as total_customers, SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY deviceprotection
UNION ALL
SELECT 
    'Tech Support' as service_type, techsupport as service_status,
    COUNT(*) as total_customers, SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY techsupport
ORDER BY service_type, churn_rate_percent DESC;

-- Streaming services impact
SELECT 
    'Streaming TV' as service_type, streamingtv as service_status,
    COUNT(*) as total_customers, SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY streamingtv
UNION ALL
SELECT 
    'Streaming Movies' as service_type, streamingmovies as service_status,
    COUNT(*) as total_customers, SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY streamingmovies
ORDER BY service_type, churn_rate_percent DESC;

-- =====================================================
-- 8. CONTRACT AND BILLING ANALYSIS
-- =====================================================

-- Contract type impact on churn
SELECT 
    contract,
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY contract
ORDER BY churn_rate_percent DESC;

-- Paperless billing impact
SELECT 
    paperlessbilling,
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY paperlessbilling
ORDER BY churn_rate_percent DESC;

-- Payment method impact on churn
SELECT 
    paymentmethod,
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY paymentmethod
ORDER BY churn_rate_percent DESC;

-- =====================================================
-- 9. TENURE AND LOYALTY ANALYSIS
-- =====================================================

-- Churn rate by tenure groups
SELECT 
    tenure_group,
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
GROUP BY tenure_group
ORDER BY churn_rate_percent DESC;

-- Monthly churn trend for new customers (first 24 months)
SELECT 
    tenure,
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent
FROM customer_churn
WHERE tenure <= 24
GROUP BY tenure    
ORDER BY tenure;

-- =====================================================
-- 10. REVENUE AND FINANCIAL IMPACT ANALYSIS
-- =====================================================

-- Revenue comparison between churned and retained customers
SELECT 
    churn,
    COUNT(*) as customer_count,
    ROUND(AVG(monthlycharges), 2) AS avg_monthly_charges,
    ROUND(AVG(total_charges_numeric), 2) AS avg_total_charges,
    ROUND(SUM(total_charges_numeric), 2) AS total_revenue_generated
FROM customer_churn
WHERE total_charges_numeric IS NOT NULL
GROUP BY churn;

-- Churn rate by monthly charges category
SELECT 
    monthly_charges_category,
    COUNT(*) as total_customers,
    SUM(churn_binary) as churned_customers,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) AS churn_rate_percent,
    ROUND(AVG(monthlycharges), 2) as avg_monthly_charges
FROM customer_churn
GROUP BY monthly_charges_category    
ORDER BY churn_rate_percent DESC;

-- Revenue at risk calculation (monthly charges of churned customers)
SELECT 
    'Monthly Revenue at Risk' as metric,
    ROUND(SUM(CASE WHEN churn = 'Yes' THEN monthlycharges ELSE 0 END), 2) as amount
FROM customer_churn
UNION ALL
SELECT 
    'Monthly Revenue Retained' as metric,
    ROUND(SUM(CASE WHEN churn = 'No' THEN monthlycharges ELSE 0 END), 2) as amount
FROM customer_churn;

-- =====================================================
-- 11. COMPREHENSIVE CHURN SUMMARY STATISTICS
-- =====================================================

-- Overall business metrics summary
SELECT 
    COUNT(*) as total_customers,
    SUM(churn_binary) as total_churned,
    COUNT(*) - SUM(churn_binary) as total_retained,
    ROUND((SUM(churn_binary) * 1.0 / COUNT(*)) * 100, 2) as overall_churn_rate,
    ROUND(AVG(monthlycharges), 2) as avg_monthly_revenue_per_customer,
    ROUND(SUM(monthlycharges), 2) as total_monthly_revenue,
    ROUND(AVG(tenure), 1) as avg_customer_tenure_months
FROM customer_churn;
