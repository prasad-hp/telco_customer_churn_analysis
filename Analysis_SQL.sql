-- Create main table
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

-- Verify the Creation of table with columns
SELECT * FROM customer_churn;

-- Insert data into the table
-- Data impoted from CSV file.

-- BASIC DATA EXPLORATION

-- Check and Verify the data 
SELECT * FROM customer_churn
LIMIT 10;

SELECT COUNT(*) as total_customers FROM customer_churn;
-- 7043

-- Check data types and null values
SELECT 
    COUNT(*) as total_rows,
    COUNT(customerID) as non_null_ids,
    COUNT(CASE WHEN TotalCharges = '' THEN 1 END) as empty_total_charges
FROM customer_churn;

-- total rows 7043
-- non null ids 7043
-- empty charges 0

-- DATA CLEANING AND PREPARATION
-- add new column tenure_group
ALTER TABLE customer_churn ALTER COLUMN tenure_group TYPE VARCHAR(50);

-- REplaced empty string or space with NULL values
UPDATE customer_churn
SET totalcharges = NULL
WHERE totalcharges = '' OR totalcharges = ' ';

--Verify the changes
SELECT * FROM customer_churn
WHERE totalcharges IS NULL

SELECT COUNT(*) AS Count_of_null_from_total_charges FROM customer_churn
WHERE totalcharges IS NULL
--11

--Add new Column 
ALTER TABLE customer_churn
ADD COLUMN Total_Charges_Numeric DECIMAL(10,2);

-- Importing non null values
UPDATE customer_churn
SET Total_Charges_Numeric = CAST(totalcharges AS DECIMAL(10, 2))
WHERE totalcharges IS NOT NULL;

ALTER TABLE customer_churn
ADD COLUMN churn_binary INT;

UPDATE customer_churn
SET churn_binary = (
	CASE 
		WHEN churn = 'Yes'
		THEN 1
		ELSE 0
	END
);

-- add data to new table based on the condition
UPDATE customer_churn
SET tenure_group = (
	CASE
		WHEN tenure <= 12 THEN 'New (0-12 Months)'
		WHEN tenure <= 24 THEN 'Medium (13-24 Months)'
		WHEN tenure <= 48 THEN 'Long (25-48 Months)'
		ELSE 'Loyal 48+ Months'
	END
);

-- Count of different types of customers
SELECT tenure_group, COUNT(tenure_group) AS customer_count FROM customer_churn
GROUP BY tenure_group;

-- Create derived columns based on Monthly charges
SELECT AVG(monthlycharges) FROM customer_churn;

SELECT monthlycharges FROM customer_churn
ORDER BY monthlycharges
OFFSET (SELECT COUNT(*) FROM customer_churn)/2
LIMIT 1;
-- 70.35

SELECT MIN(monthlycharges) FROM customer_churn;
-- 18.25

SELECT MAX(monthlycharges) FROM customer_churn;
-- 118.75

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

SELECT monthly_charges_category, COUNT(monthly_charges_category) AS category_count FROM customer_churn
GROUP BY monthly_charges_category;

-- High 2160
-- Medium 1409
-- Very High 1739
-- Low 1735

SELECT * FROM customer_churn;

SELECT seniorcitizen, COUNT(seniorcitizen), churn FROM customer_churn
GROUP BY seniorcitizen, churn;

-- Calculate Churn Rate
-- Total Churn Rate
SELECT 
ROUND((SUM(churn_binary)*1.0/COUNT(*))*100, 2) AS churn_percentage FROM customer_churn

--Genderwise churn rate
SELECT 
gender, ROUND((SUM(churn_binary)*1.0/COUNT(*))*100, 2) AS churn_percentage FROM customer_churn
GROUP BY gender

-- Age category
SELECT 
(CASE
	WHEN seniorcitizen = 1
	THEN 'Senior Citizen'
	ELSE 'Normal Citizen'
END) AS Customer_Type, ROUND((SUM(churn_binary)*1.0/COUNT(*))*100, 2) AS churn_percentage FROM customer_churn
GROUP BY seniorcitizen

-- churn by family status
SELECT 
partner, dependents, ROUND((SUM(churn_binary)*1.0/COUNT(*))*100, 2) AS churn_percentage FROM customer_churn
GROUP BY partner, dependents
ORDER BY churn_percentage DESC

-- churn by internet service type
SELECT 
internetservice, ROUND((SUM(churn_binary)*1.0/COUNT(*))*100, 2) AS churn_percentage FROM customer_churn
GROUP BY internetservice
ORDER BY churn_percentage DESC

-- Churn by contract type
SELECT 
contract, ROUND((SUM(churn_binary)*1.0/COUNT(*))*100, 2) AS churn_percentage FROM customer_churn
GROUP BY contract
ORDER BY churn_percentage DESC

-- Tenure Analysis
SELECT tenure_group, 
ROUND((SUM(churn_binary)*1.0/COUNT(*))*100, 2) AS churn_percentage
FROM customer_churn
GROUP BY tenure_group
ORDER BY churn_percentage DESC

-- Monthly Churn distribution
SELECT tenure, 
ROUND((SUM(churn_binary)*1.0/COUNT(*))*100, 2) AS churn_percentage
FROM customer_churn
WHERE tenure <=24
GROUP BY tenure	
ORDER BY tenure

-- Revenue Impact analysis
SELECT churn, 
ROUND(AVG(monthlycharges),2) AS avg_monthly_charges,
ROUND(AVG(total_charges_numeric), 2) AS avg_total_charges,
ROUND(SUM(total_charges_numeric), 2) AS sum_of_total_charges
FROM customer_churn
WHERE total_charges_numeric IS NOT NULL
GROUP BY churn

-- churn based on monthly charges category
SELECT monthly_charges_category, 
ROUND((SUM(churn_binary)*1.0/COUNT(*))*100, 2) AS churn_percentage
FROM customer_churn
GROUP BY monthly_charges_category	
ORDER BY churn_percentage


