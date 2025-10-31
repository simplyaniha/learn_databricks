CREATE OR REFRESH MATERIALIZED VIEW silver.cleaned_sales_data
(
  -- Define data quality constraints
  CONSTRAINT sales_quantity_check EXPECT (quantity IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT sales_channel_check EXPECT (channel IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT sales_promo_code_check EXPECT (promo_code IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT customer_email_check EXPECT (email IS NOT NULL) ON VIOLATION DROP ROW
)
COMMENT "Cleaned sales data"
AS SELECT
  -- Fact sales columns
  FS.sale_id,
  FS.order_date,
  FS.customer_id,
  FS.product_id,
  FS.quantity,
  FS.discount,
  FS.region_id,
  FS.channel,
  FS.promo_code,
  
  -- Customer columns (exclude primary key)
  C.first_name,
  C.last_name,
  C.email,
  C.join_date,
  C.VIP,
  
  -- Product columns (exclude primary key)
  P.product_name,
  P.category,
  P.price,
  P.in_stock,
  
  -- Region columns (exclude primary key)
  R.region_name,
  R.country,
  
  -- Calculated column
  FS.quantity * P.price AS revenue
  
FROM lakeflow_dlt.silver.fact_sales FS

LEFT JOIN lakeflow_dlt.silver.customers C
  ON FS.customer_id = C.customer_id

LEFT JOIN lakeflow_dlt.silver.products P
  ON FS.product_id = P.product_id

LEFT JOIN lakeflow_dlt.silver.regions R
  ON FS.region_id = R.region_id;