--Calculate the total sales per month
--and the running total of sales over time.
select 
order_date,
total_sales,
SUM(total_sales) OVER (Partition by order_date ORDER BY order_date) as running_total_sales
From
	(
	select
	DATETRUNC(month,order_date) as order_date,
	sum(sales_amount) total_sales 
	from gold.fact_sales
	where order_date is not null
	Group by DATETRUNC(month,order_date) ) t
--Default window frame Between unbounded preceding and current row 
