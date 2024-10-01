CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;

CREATE TABLE ecommerce_sales (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id VARCHAR(255),
    loyalty_member_status VARCHAR(50),
    marketing_channel VARCHAR(50),
    order_value DECIMAL(10, 2),
    refund_status VARCHAR(3),
    product_category VARCHAR(50)
);

SELECT * FROM ecommerce_sales
LIMIT 5;

# REVENUE GROWTH RATE 
# Total Revenue per year
SELECT YEAR(order_date) AS year, 
       SUM(order_value) AS total_revenue
FROM ecommerce_sales
GROUP BY year
ORDER BY year;

# Revenue growth rate calculation 
SELECT
    year,
    total_revenue,
    LAG(total_revenue, 1) OVER (ORDER BY year) AS previous_year_revenue,
    ROUND(
        (
            (total_revenue - LAG(total_revenue, 1) OVER (ORDER BY year)) / 
            LAG(total_revenue, 1) OVER (ORDER BY year)
        ) * 100, 
        2
    ) AS growth_rate_percentage
FROM
    (
        SELECT
            YEAR(order_date) AS year,
            SUM(order_value) AS total_revenue
        FROM
            ecommerce_sales
        GROUP BY
            YEAR(order_date)
    ) AS yearly_revenue;


# AVERAGE ORDER VALUE 
# Overall AOV
SELECT ROUND(AVG(order_value), 2) AS overall_aov
FROM ecommerce_sales;

# AOV by Customer Segment (Loyalty vs. Non-Loyalty)
SELECT loyalty_member_status, 
       ROUND(AVG(order_value), 2) AS aov
FROM ecommerce_sales
GROUP BY loyalty_member_status;

# AOV by Marketing Channel
SELECT marketing_channel, 
       ROUND(AVG(order_value), 2) AS aov
FROM ecommerce_sales
GROUP BY marketing_channel;


# REFUND RATE
# Overall Refund Rate
SELECT
    ROUND(
        (COUNT(CASE WHEN refund_status = 'yes' THEN 1 END) / COUNT(*) * 100),
        2
    ) AS refund_rate_percentage
FROM
    ecommerce_sales;
    
# Refund Rate by Product Category
SELECT
    product_category,
    ROUND(
        (COUNT(CASE WHEN refund_status = 'yes' THEN 1 END) / COUNT(*) * 100),
        2
    ) AS refund_rate_percentage
FROM
    ecommerce_sales
GROUP BY
    product_category
ORDER BY
    refund_rate_percentage DESC;
    

# MARKETING CHANNEL PERFORMANCE 
# Revenue by Marketing Channel
SELECT
    marketing_channel,
    ROUND(SUM(order_value), 2) AS total_revenue,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM
    ecommerce_sales
GROUP BY
    marketing_channel
ORDER BY
    total_revenue DESC;
    
# Number of Loyalty Members Acquired by Channel
SELECT
    marketing_channel,
    COUNT(DISTINCT CASE WHEN loyalty_member_status = 'yes' THEN customer_id END) AS loyalty_customers,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(
        (COUNT(DISTINCT CASE WHEN loyalty_member_status = 'yes' THEN customer_id END) / COUNT(DISTINCT customer_id)) * 100,
        2
    ) AS loyalty_conversion_rate
FROM
    ecommerce_sales
GROUP BY
    marketing_channel
ORDER BY
    loyalty_conversion_rate DESC;
    
    
# Monthly Revenue Trend
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(order_value) AS total_revenue
FROM
    ecommerce_sales
GROUP BY
    month
ORDER BY
    month;
    
    
# Average Order Value Over Time
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM
    ecommerce_sales
GROUP BY month
ORDER BY month;


# Create derived tables for Power BI 
# Refund Rate by Product Category
SELECT
    product_category,
    COUNT(order_id) AS total_orders,
    SUM(CASE WHEN refund_status = 'yes' THEN 1 END) AS total_refunds,
    ROUND(((SUM(CASE WHEN refund_status = 'yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(order_id)), 2) AS refund_rate
FROM
    ecommerce_sales
GROUP BY
    product_category;




