--Segment products into cost ranges and count how many products fact into each segment
WITH product_seg as (
select 
product_key,
product_name,
cost,
CASE
	WHEN cost < 100 then 'Below 100'
	WHEN cost BETWEEN 100 and 500 THEN '100-500'
	WHEN cost Between 500 and 1000 THEN '500-1000'
	ELSE 'ABOVE 1000'
END cost_range
From gold.dim_products
)
select
cost_range,
Count(product_key) as total_products
from product_seg
group by cost_range
Order by total_products DESC

/*
Group customers into three segments based on their spending behaviour:
	-VIP : Customers with at least 12 months of history and spending more than 5000.
	-Regular : Customers with at least 12 months of history but spending 5000 or less
	-New: Customers with a lifespan less than 12 months
And find the total number of customers by each group.
*/
WITH customer_spending as(
select
c.customer_key,
MIN(order_date) as first_order,
MAX(order_date) as last_order,
sUM(sales_amount) as total_spending,
DATEDIFF(month,MIN(order_date),MAX(order_date)) as lifespan
from gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
group by c.customer_key)

select 
CASE 
	WHEN lifespan > = 12 and total_spending > 5000 THEN 'VIP '
	WHEN lifespan >= 12 and total_spending <=5000 Then 'Regular'
	ELSe 'New'
END customer_type,
COUNT(customer_key) as total_customers
from customer_spending
group by CASE 
	WHEN lifespan > = 12 and total_spending > 5000 THEN 'VIP '
	WHEN lifespan >= 12 and total_spending <=5000 Then 'Regular'
	ELSe 'New'
END

