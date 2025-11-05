-- Aggregate 1: Category Sales Summary
CREATE OR REFRESH MATERIALIZED VIEW gold.category_sales_summary
AS SELECT
  category,
  YEAR(order_date) AS year,
  SUM(revenue) AS total_revenue
FROM lakeflow_dlt.silver.cleaned_sales_data
GROUP BY category, YEAR(order_date)
ORDER BY category, year;


-- Aggregate 2: Revenue by Customer in Each Region (Ranked)
CREATE OR REFRESH MATERIALIZED VIEW gold.revenue_by_customers_in_each_region_by_ranking
AS SELECT
  region_name,
  customer_id,
  first_name,
  last_name,
  SUM(revenue) AS total_revenue,
  RANK() OVER (PARTITION BY region_name ORDER BY SUM(revenue) DESC) AS revenue_rank
FROM lakeflow_dlt.silver.cleaned_sales_data
GROUP BY region_name, customer_id, first_name, last_name
ORDER BY region_name, revenue_rank;


-- Customer Lifetime Value Estimation

CREATE OR REFRESH MATERIALIZED VIEW gold.customer_lifetime_value_estimation
AS SELECT
  customer_id,
  first_name,
  last_name,
  email,
  VIP,
  COUNT(DISTINCT sale_id) AS total_orders,
  SUM(quantity) AS total_items_purchased,
  SUM(revenue) AS lifetime_value,
  AVG(revenue) AS average_order_value,
  MIN(order_date) AS first_purchase_date,
  MAX(order_date) AS last_purchase_date,
  DATEDIFF(MAX(order_date), MIN(order_date)) AS customer_tenure_days
FROM lakeflow_dlt.silver.cleaned_sales_data
GROUP BY customer_id, first_name, last_name, email, VIP
ORDER BY lifetime_value DESC;





