-- ============================================================
-- Project   : Diwali Sales Analysis
-- Author    : Ashuraj Chouhan
-- Tool      : MySQL
-- Dataset   : Diwali Sales Data (11,151 rows)
-- Objective : Analyze festive season sales to understand
--             customer behaviour, regional performance
--             and product trends across India
-- ============================================================

USE diwali;


-- ============================================================
-- STEP 1 : SETTING UP TABLES
-- ============================================================

-- Splitting table into customers and orders
-- for better structure and to practice JOIN queries

CREATE TABLE diwali_customers AS
SELECT DISTINCT
  User_ID,
  Cust_name,
  Gender,
  `Age Group`,
  Age,
  Marital_Status,
  State,
  Zone,
  Occupation
FROM diwali_sales;

CREATE TABLE diwali_orders AS
SELECT
  `S.No`,
  User_ID,
  Product_ID,
  Product_Category,
  Orders,
  Amount
FROM diwali_sales;


-- ============================================================
-- STEP 2 : BUSINESS QUESTIONS & ANALYSIS
-- ============================================================


-- ------------------------------------------------------------
-- Q1. What is the overall sales performance?
-- ------------------------------------------------------------

SELECT
  COUNT(*)                      AS total_records,
  COUNT(DISTINCT o.User_ID)     AS total_customers,
  SUM(o.Orders)                 AS total_orders,
  ROUND(SUM(o.Amount), 2)       AS total_revenue,
  ROUND(AVG(o.Amount), 2)       AS avg_order_value
FROM diwali_orders o;

-- Finding : Total revenue of ₹10.4 Cr from 11,151 orders


-- ------------------------------------------------------------
-- Q2. Which states are generating the most revenue?
-- ------------------------------------------------------------
-- Helps business decide where to focus
-- marketing efforts and inventory planning

SELECT
  c.State,
  c.Zone,
  COUNT(DISTINCT o.User_ID)     AS total_customers,
  SUM(o.Orders)                 AS total_orders,
  ROUND(SUM(o.Amount), 2)       AS revenue
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY c.State, c.Zone
ORDER BY revenue DESC
LIMIT 5;

-- Finding : Uttar Pradesh, Maharashtra and Karnataka
--           are top 3 revenue generating states


-- ------------------------------------------------------------
-- Q3. How is each zone performing?
-- ------------------------------------------------------------
-- Zone level view helps with regional strategy

SELECT
  c.Zone,
  COUNT(DISTINCT o.User_ID)     AS total_customers,
  SUM(o.Orders)                 AS total_orders,
  ROUND(SUM(o.Amount), 2)       AS revenue,
  ROUND(AVG(o.Amount), 2)       AS avg_spend
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY c.Zone
ORDER BY revenue DESC;

-- Finding : Central zone contributes nearly
--           40% of total revenue


-- ------------------------------------------------------------
-- Q4. Do men or women spend more during Diwali?
-- ------------------------------------------------------------
-- Gender based insight helps in targeting
-- the right audience for promotions

SELECT
  CASE WHEN c.Gender = 'F' THEN 'Female'
       ELSE 'Male' END          AS gender,
  COUNT(DISTINCT o.User_ID)     AS total_customers,
  SUM(o.Orders)                 AS total_orders,
  ROUND(SUM(o.Amount), 2)       AS revenue,
  ROUND(AVG(o.Amount), 2)       AS avg_spend
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY c.Gender
ORDER BY revenue DESC;

-- Finding : Females spend 2.3x more than males
--           during the Diwali season


-- ------------------------------------------------------------
-- Q5. Which age group shops the most?
-- ------------------------------------------------------------
-- Useful for deciding which age group
-- to target in ad campaigns

SELECT
  c.`Age Group`,
  COUNT(DISTINCT o.User_ID)     AS total_customers,
  SUM(o.Orders)                 AS total_orders,
  ROUND(SUM(o.Amount), 2)       AS revenue,
  ROUND(AVG(o.Amount), 2)       AS avg_spend
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY c.`Age Group`
ORDER BY revenue DESC;

-- Finding : Age group 26-35 is the biggest spender
--           contributing around 40% of total revenue


-- ------------------------------------------------------------
-- Q6. Which product categories are selling the most?
-- ------------------------------------------------------------
-- Helps in stock planning and
-- identifying best performing products

SELECT
  o.Product_Category,
  COUNT(DISTINCT o.User_ID)     AS unique_buyers,
  SUM(o.Orders)                 AS total_orders,
  ROUND(SUM(o.Amount), 2)       AS revenue,
  ROUND(AVG(o.Amount), 2)       AS avg_order_value
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY o.Product_Category
ORDER BY revenue DESC;

-- Finding : Food is the top selling category
--           followed by Clothing and Electronics


-- ------------------------------------------------------------
-- Q7. Which categories are underperforming?
-- ------------------------------------------------------------
-- Identifies categories that need
-- attention or possible removal

SELECT
  o.Product_Category,
  SUM(o.Orders)                 AS total_orders,
  ROUND(SUM(o.Amount), 2)       AS revenue
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY o.Product_Category
ORDER BY revenue ASC
LIMIT 5;

-- Finding : These categories may need
--           better promotions or discounts


-- ------------------------------------------------------------
-- Q8. Which occupation spends the most?
-- ------------------------------------------------------------
-- Helps target high spending customer groups
-- through occupation based marketing

SELECT
  c.Occupation,
  COUNT(DISTINCT o.User_ID)     AS total_customers,
  SUM(o.Orders)                 AS total_orders,
  ROUND(SUM(o.Amount), 2)       AS revenue,
  ROUND(AVG(o.Amount), 2)       AS avg_spend
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY c.Occupation
ORDER BY revenue DESC;

-- Finding : IT Sector professionals are
--           the highest spending group


-- ------------------------------------------------------------
-- Q9. Married vs Unmarried — who shops more?
-- ------------------------------------------------------------
-- Marital status combined with gender
-- gives a sharper customer profile

SELECT
  CASE WHEN c.Marital_Status = 1 THEN 'Married'
       ELSE 'Unmarried' END     AS marital_status,
  CASE WHEN c.Gender = 'F' THEN 'Female'
       ELSE 'Male' END          AS gender,
  COUNT(DISTINCT o.User_ID)     AS total_customers,
  ROUND(SUM(o.Amount), 2)       AS revenue,
  ROUND(AVG(o.Amount), 2)       AS avg_spend
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY c.Marital_Status, c.Gender
ORDER BY revenue DESC;

-- Finding : Married females are the
--           highest spending customer group


-- ------------------------------------------------------------
-- Q10. Who are our top 10 highest spending customers?
-- ------------------------------------------------------------
-- Identifying VIP customers for
-- loyalty programs and special offers

SELECT
  c.Cust_name,
  c.State,
  c.Occupation,
  CASE WHEN c.Gender = 'F' THEN 'Female'
       ELSE 'Male' END          AS gender,
  SUM(o.Orders)                 AS orders_placed,
  ROUND(SUM(o.Amount), 2)       AS total_spent
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY c.Cust_name, c.State, c.Occupation, c.Gender
ORDER BY total_spent DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q11. Which states have above average order value?
-- ------------------------------------------------------------
-- Finds premium markets where customers
-- are willing to spend more per order

SELECT
  c.State,
  c.Zone,
  ROUND(AVG(o.Amount), 2)       AS avg_order_value,
  ROUND(SUM(o.Amount), 2)       AS total_revenue
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY c.State, c.Zone
HAVING AVG(o.Amount) > (SELECT AVG(Amount) FROM diwali_orders)
ORDER BY avg_order_value DESC;

-- Finding : These states are premium markets
--           and should get exclusive product launches


-- ------------------------------------------------------------
-- Q12. What does each occupation prefer to buy?
-- ------------------------------------------------------------
-- Occupation + category combination helps
-- in personalised product recommendations

SELECT
  c.Occupation,
  o.Product_Category,
  COUNT(DISTINCT c.User_ID)     AS customers,
  ROUND(SUM(o.Amount), 2)       AS revenue
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY c.Occupation, o.Product_Category
ORDER BY revenue DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q13. What does each gender prefer to buy?
-- ------------------------------------------------------------
-- Gender + category helps plan
-- gender specific promotions

SELECT
  CASE WHEN c.Gender = 'F' THEN 'Female'
       ELSE 'Male' END          AS gender,
  o.Product_Category,
  SUM(o.Orders)                 AS total_orders,
  ROUND(SUM(o.Amount), 2)       AS revenue
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY c.Gender, o.Product_Category
ORDER BY revenue DESC;


-- -------------------------------------------------------------
-- Q14. Revenue contribution of each zone (in %)
-- ------------------------------------------------------------
-- Shows how much % each zone contributes
-- to the overall business revenue

SELECT
  c.Zone,
  ROUND(SUM(o.Amount), 2)       AS zone_revenue,
  ROUND(
    SUM(o.Amount) * 100.0 /
    SUM(SUM(o.Amount)) OVER (), 2
  )                             AS revenue_share_pct
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY c.Zone
ORDER BY zone_revenue DESC;

-- Finding : Central zone alone covers 39.5%
--           of total national revenue


-- ------------------------------------------------------------
-- Q15. Rank all states by revenue
-- -------------------------------------------------------------
-- Clear ranking helps management compare
-- state performance

SELECT
  c.State,
  c.Zone,
  ROUND(SUM(o.Amount), 2)                           AS revenue,
  RANK() OVER (ORDER BY SUM(o.Amount) DESC)         AS revenue_rank
FROM diwali_orders o
JOIN diwali_customers c ON o.User_ID = c.User_ID
GROUP BY c.State, c.Zone
ORDER BY revenue DESC;


-- ------------------------------------------------------------
-- Q16. Top selling category in each zone
-- ---------------------------------------------------------------
-- Knowing the best product per zone helps
-- in zone specific stock allocation

WITH zone_category AS (
  SELECT
    c.Zone,
    o.Product_Category,
    ROUND(SUM(o.Amount), 2)     AS revenue,
    RANK() OVER (
      PARTITION BY c.Zone
      ORDER BY SUM(o.Amount) DESC
    )                           AS rnk
  FROM diwali_orders o
  JOIN diwali_customers c ON o.User_ID = c.User_ID
  GROUP BY c.Zone, o.Product_Category
)
SELECT
  Zone,
  Product_Category              AS top_category,
  revenue
FROM zone_category
WHERE rnk = 1
ORDER BY revenue DESC;

-- Finding : Food dominates as top category
--           across most zones in India


-- --------------------------------------------------------------
-- Q17. Top selling category in each state
-- ------------------------------------------------------------
-- State level product preference helps
-- in marketing decisions

WITH state_category AS (
  SELECT
    c.State,
    o.Product_Category,
    ROUND(SUM(o.Amount), 2)     AS revenue,
    RANK() OVER (
      PARTITION BY c.State
      ORDER BY SUM(o.Amount) DESC
    )                           AS rnk
  FROM diwali_orders o
  JOIN diwali_customers c ON o.User_ID = c.User_ID
  GROUP BY c.State, o.Product_Category
)
SELECT
  State,
  Product_Category              AS top_category,
  revenue
FROM state_category
WHERE rnk = 1
ORDER BY revenue DESC;


-- ============================================================
-- KEY BUSINESS INSIGHTS SUMMARY
-- ============================================================
-- 1. Total Revenue     : Rs 10.4 Crore
-- 2. Top State         : Uttar Pradesh
-- 3. Top Zone          : Central (39.5% of revenue)
-- 4. Gender            : Females spend 2.3x more than Males
-- 5. Top Age Group     : 26-35 years (40% of revenue)
-- 6. Top Category      : Food
-- 7. Top Occupation    : IT Sector
-- 8. Best Segment      : Married Females aged 26-35

-- ------------------------------------------------------------

