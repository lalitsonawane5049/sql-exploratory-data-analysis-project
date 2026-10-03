--Which categories contribute the most to the overall sales?
WITH category_sales as(
select
category,
sum(sales_amount) total_sales_of_each_category
from gold.fact_sales f
LEFT JOIN gold.dim_products p
on f.product_key = p.product_key
group by category)

select
category,
total_sales_of_each_category,
sum(total_sales_of_each_category) OVER() as total_sales,
ROUND((CAST(total_sales_of_each_category as float )/sum(total_sales_of_each_category) OVER())* 100,2) percentage_of_total_contribution
from category_sales
Order by total_sales_of_each_category DESC

