CREATE DATABASE DA_Assignment_3

USE DA_Assignment_3

-- Top 5 Jobs with the Highest Average Balance
SELECT TOP 5 job, AVG(balance) AS avg_balance
FROM bank
GROUP BY job
ORDER BY avg_balance DESC;

-- Campaign Success Rate by Education
SELECT education, 
       COUNT(*) AS total_contacts,
       SUM(CASE WHEN y = 1 THEN 1 ELSE 0 END) AS successful_contacts,
       CAST(SUM(CASE WHEN y = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS success_rate
FROM bank
GROUP BY education
ORDER BY success_rate DESC;

--Creating a View: Client Summary
CREATE VIEW Client_Summary AS
SELECT 
    age,
    job,
    marital,
    education,
    AVG(balance) AS avg_balance,
    SUM(CASE WHEN LOWER(housing) = 'yes' THEN 1 ELSE 0 END) AS housing_loans,
    SUM(CASE WHEN LOWER(loan) = 'yes' THEN 1 ELSE 0 END) AS personal_loans
FROM bank
GROUP BY age, job, marital, education;



--Execute View
SELECT * FROM Client_Summary

--
--DROP VIEW Client_Summary

--Creating a View: Campaign Performance by Month
CREATE VIEW Campaign_Performance AS
SELECT 
    month AS campaign_month,
    COUNT(*) AS total_contacts,
    SUM(CASE WHEN LOWER(y) = 'yes' THEN 1 ELSE 0 END) AS successful_contacts,
    CAST(SUM(CASE WHEN LOWER(y) = 'yes' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS success_rate
FROM bank
GROUP BY month;

--Execute View
SELECT * FROM Campaign_Performance

--DROP VIEW Campaign_Performance


--Creating an Index for Faster Queries
CREATE INDEX idx_client_search
ON bank (age, job, marital, education);

--Stored Procedure: Update Client Balance
CREATE PROCEDURE Update_Client_Balance
    @age INT,
    @new_balance DECIMAL(10,2)
AS
BEGIN
    UPDATE bank
    SET balance = @new_balance
    WHERE age = @age;
END;

--Retrieving Clients Contacted More Than 3 Times
SELECT age, job, marital, education, campaign
FROM bank
WHERE campaign > 3
ORDER BY campaign DESC;

--Finding the Most Common Contact Month
SELECT TOP 1 month AS most_common_month,
       COUNT(*) AS contact_count
FROM bank
GROUP BY month
ORDER BY contact_count DESC;

--Correlation Between Call Duration and Success
SELECT 
    CASE 
        WHEN duration < 100 THEN 'Short Call'
        WHEN duration BETWEEN 100 AND 500 THEN 'Medium Call'
        ELSE 'Long Call'
    END AS call_duration_category,
    COUNT(*) AS total_calls,
    SUM(CASE WHEN LOWER(CAST(y AS VARCHAR)) = 'yes' THEN 1 ELSE 0 END) AS successful_calls,
    CAST(SUM(CASE WHEN LOWER(CAST(y AS VARCHAR)) = 'yes' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS success_rate
FROM bank
GROUP BY CASE 
            WHEN duration < 100 THEN 'Short Call'
            WHEN duration BETWEEN 100 AND 500 THEN 'Medium Call'
            ELSE 'Long Call'
         END
ORDER BY success_rate DESC;

--Customers Who Subscribed and Have a High Balance
SELECT age, job, balance, education, marital
FROM bank
WHERE y = 1 
AND balance > (SELECT AVG(balance) FROM bank)
ORDER BY balance DESC;