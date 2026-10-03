--Analyze Sales performance over time.
select 
year(order_date) order_year,
month(order_date) order_month,
SUM(sales_amount) as total_sales,
Count(Distinct customer_key) as total_customers,
SUM(quantity) as total_quantity
from gold.fact_sales
where order_date is not NULL
group by year(order_date) , month(order_date)
Order by year(order_date) , month(order_date)
--using datetrunc : Rounds a date or timestamp to a specified date.
SELECT
DATETRUNC(month,order_date) as order_date,
SUM(sales_amount) as total_Sales,
count(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
from gold.fact_sales
Where order_date is not NULL
Group by DATETRUNC(month,order_date)
ORDER By DATETRUNC(month,order_date)
