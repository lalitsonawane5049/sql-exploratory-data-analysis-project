--Analyze the yearly performance of the products by comparing their sales
--to both the average sales performance of the product and the previous years sales
WITH yearly_product_sales AS(
Select 
Year(f.order_date) order_year,
p.product_name,
SUM(f.sales_amount) as current_sales
from gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
Where f.order_date IS NOT NULL
Group by 
Year(f.order_date),
p.product_name
)
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) avg_sales,
current_sales-AVG(current_sales) OVER(PARTITION BY product_name) avg_sales,
CASE 
	WHEN current_sales-AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'ABOVE AVG'
	WHEN current_sales-AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below AVG'
	ELSE 'AVG'
END avg_change,
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) prv_year_sales,
CASE 
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	ELSE 'No Change'
END py_change
from yearly_product_sales
ORDER BY product_name,order_year
