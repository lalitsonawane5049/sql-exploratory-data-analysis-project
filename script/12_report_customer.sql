/*
================================================================================
--6) Customer Report
================================================================================
Purpose:
	This report consolidates key customer metrics and behaviours

Highlights:
	1.Gathers essential fields such as names, ages, and transcation details.
	2.Segments customers into categories(VIP , Regular,new) and age groups:
	3.Aggregate cutsomer-level metrics:
		-total orders
		-total sales
		-total quantity purchased
		-total products
		-lifespan(in months)
	4.Calculates valuable KPIs:
		-recency(months since last order)
		-average order value
		-average monthly spend
================================================================================
*/
--1) Base query : Retrives core columns from tables
CREATE VIEW gold.report_customers  as 
with base_query as (
select
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	concat(first_name,' ',c.last_name) as customer_name,
	DATEDIFF(year,c.birthdate,GETDATE()) age
from gold.fact_sales f
LEFT JOIN gold.dim_customers c
on c.customer_key = f.customer_key
where order_date is not null
),


--2)Aggregate cutsomer-level metrics:
customer_aggregation as(
select 
customer_key,
customer_number,
customer_name,
age,
Count(DISTINCT order_number) as total_orders,
SUM(sales_amount)  as total_sales,
SUM(quantity) as total_quantity,
Count(DISTINCT product_key) as total_products,
MAX(order_date) as last_order_date,
DATEDIFF(month,MIN(order_date),MAX(order_date)) as lifespan
from base_query
group by customer_key,
customer_number,
customer_name,
age) 

select 
customer_key,
customer_number,
customer_name,
age,
CASE 
	when age < 20 THEN 'under 20'
	WHEN age BETWEEN 20 and 29 THEN '20-29'
	WHEN age BETWEEN 30 and 39 THEN '30-39'
	WHEN age BETWEEN 40 and 49 THEN '40-49'
	ELSE '50 and above'
END as age_group,
CASE 
	WHEN lifespan > = 12 and total_sales > 5000 THEN 'VIP '
	WHEN lifespan >= 12 and total_sales <=5000 Then 'Regular'
	ELSe 'New'
END as customer_segment,
last_order_date,
DATEDIFF(month,last_order_date,GETDATE()) as recency,
total_sales,
total_quantity,
total_products,
lifespan,
--Compute average order value(AVO)
CASE 
	WHEN total_sales = 0 THEN 0
	Else total_sales/total_orders
END AS avg_order_value,
--Compute average monthly spend
CASE When lifespan = 0 THEN total_sales
	ELSE total_sales/lifespan
END as avg_monthly_spend
from customer_aggregation

select * from gold.report_customers

select 
age_group,
Count(customer_number) as total_customers,
sum(total_sales) total_sales
from gold.report_customers
group by age_group
