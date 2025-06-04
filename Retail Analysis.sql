CREATE DATABASE Company_sales;
USE Company_sales;
CREATE TABLE Retail_Sales_Analysis_utf( 
transactions_id INT PRIMARY KEY,	
sale_date DATE,
	sale_time TIME,
	customer_id INT,
    gender VARCHAR(15),
	age INT,
	category VARCHAR(30),
	quantity INT,
	price_per_unit INT,
	cogs INT,
	total_sale INT);
SELECT * FROM retail_sales_analysis_utf;

# Cleaning the table
1. Removing Null (Missing value)
DELETE FROM retail_sales_analysis_utf
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;

2. Cleaning table from tring to Date
    ALTER TABLE retail_sales_analysis_utf
ADD COLUMN temp_sale_date DATE;

UPDATE retail_sales_analysis_utf
SET temp_sale_date = STR_TO_DATE(sale_date, '%m/%d/%Y');

ALTER TABLE retail_sales_analysis_utf
DROP COLUMN sale_date;

ALTER TABLE retail_sales_analysis_utf
CHANGE COLUMN temp_sale_date sale_date DATE;
Checking our data Accuracy
SELECT COUNT(*) FROM retail_sales_analysis_utf;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales_analysis_utf;
SELECT DISTINCT category FROM retail_sales_analysis_utf;

    
  
  

--My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

Q1. Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT *
FROM retail_sales_analysis_utf
WHERE sale_date = '2022-11-05';

2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
SELECT *
FROM retail_sales_analysis_utf
WHERE category = 'Clothing'
  AND quantity > 3
  AND MONTH(sale_date) = 11
  AND YEAR(sale_date) = 2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT category, SUM(total_sale) AS total_sales
FROM retail_sales_analysis_utf
GROUP BY category;


Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT AVG(age) AS average_age
FROM retail_sales_analysis_utf
WHERE category = 'Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000

SELECT * FROM retail_sales_analysis_utf
WHERE total_sale>1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT gender, category, COUNT(transactions_id) AS total_transactions
FROM retail_sales_analysis_utf
GROUP BY gender, category;




-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

WITH monthly_sales AS (
  SELECT 
    YEAR(sale_date) AS sale_year,
    MONTH(sale_date) AS sale_month,
    SUM(total_sale) AS monthly_total
  FROM retail_sales_analysis_utf
  GROUP BY YEAR(sale_date), MONTH(sale_date)
),
ranked_sales AS (
  SELECT *,
         RANK() OVER (PARTITION BY sale_year ORDER BY monthly_total DESC) AS rank_in_year
  FROM monthly_sales
)
SELECT *
FROM ranked_sales
WHERE rank_in_year = 1;


SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales_analysis_utf
GROUP BY 1, 2
) as t1
WHERE rank = 1

SELECT 
    year,
    month,
    avg_sale
FROM 
(
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date) 
            ORDER BY AVG(total_sale) DESC
        ) AS sale_rank
    FROM retail_sales_analysis_utf
    GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
) AS t1
WHERE sale_rank = 1;



 Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
 
 SELECT 
  customer_id,
  SUM(total_sale) AS total_spent
FROM retail_sales_analysis_utf
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 5;


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT 
  category,
  COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales_analysis_utf
GROUP BY category;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

SELECT 
  CASE 
    WHEN HOUR(sale_time) < 12 THEN 'Morning'
    WHEN HOUR(sale_time) >= 12 AND HOUR(sale_time) < 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS shift,
  COUNT(*) AS number_of_orders
FROM retail_sales_analysis_utf
GROUP BY shift;
