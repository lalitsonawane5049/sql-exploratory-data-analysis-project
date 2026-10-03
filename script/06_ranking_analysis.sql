--Which 5 products generate the highest revenue.
select top 5
dp.product_name,
sum(fs.sales_amount) as total_revenue
from gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON dp.product_key = fs.product_key
group by dp.product_name
order by total_revenue DESC
--What are the 5 worst performing products in terms of sales?
select top 5
dp.product_name,
sum(fs.sales_amount) as total_revenue
from gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON dp.product_key = fs.product_key
group by dp.product_name
order by total_revenue 
--using window function
select * from (
select 
dp.product_name,
sum(fs.sales_amount) as total_revenue,
Row_number() Over(order by sum(fs.sales_amount) ) as ranking
from gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON dp.product_key = fs.product_key
Group by dp.product_name
) t 
where ranking <= 5
--
--find top 3 customers with fewer orders
select top 3
dc.customer_key,
dc.first_name,
dc.last_name,
count(fs.order_number) as total_orders
from gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
group by dc.customer_key,
dc.first_name,
dc.last_name
Order by total_orders;
