/*
================================================================================
Product Report
================================================================================

Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last sale)
        - average order revenue (AOR)
        - average monthly revenue
================================================================================
*/
Create view gold.report_products as
WITH base_query as (
--1) Base query : Retrieves core columns from fact_sales and dim_products
select 
    f.order_number,
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.sub_category,
    p.cost
from gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
Where order_date IS NOT NULL --only consider valid sales dates
),
 product_aggregations as (
 --Product Aggregations : Summarizez key metrics at the product level
 select
    product_key,
    product_name,
    category,
    sub_category,
    cost,
    DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) as lifespan,
    MAX(order_date) as last_sale_date,
    COUNT(DISTINCT order_number) as total_orders,
    COUNT(DISTINCT customer_key) as total_customers,
    SUM(sales_amount) as total_sales,
    SUM(quantity) as total_quantity,
    ROUND(AVG(CAST(sales_amount as float)/ NULLIF(quantity,0)),1) as avg_selling_price
From base_query
group by 
product_key,
product_name,
category,
sub_category,
cost
)
/*
3) Final query : Combines all product results into one output
*/
select
    product_key,
    product_name,
    category,
    sub_category,
    cost,
    last_sale_date,
    DateDIFF(MONTH,last_sale_date,GETDATE()) as recency_in_months,
    CASE 
        WHEN total_sales > 50000 THEN 'HIGH-PERFORMER'
        WHEN total_sales > = 10000 THEN 'Mid-range'
        ELSE 'LOW-PERFORMER'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    --Average order revenue
    CASE    
        WHEN total_orders = 0 THEN 0
        ELSE total_sales/total_orders
    END As avg_order_revenue,
    --Average Monthly Revenue
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END as avg_monthly_revenue
FROM product_aggregations

select *  from gold.report_products
