-- Ingest data from volume to bronze schema

CREATE STREAMING LIVE TABLE bronze.fact_sales
COMMENT "Raw fact sales from volume to bronze schema"
AS SELECT * FROM CLOUD_FILES(
  '/Volumes/lakeflow_dlt/landing_zone/fact_and_dimension_files/fact_sales',
  'csv',
  map('header', 'true')
);


-- Products Ingestions

CREATE STREAMING LIVE TABLE bronze.products
COMMENT "Raw products from volume to bronze schema"
AS SELECT * FROM CLOUD_FILES(
  '/Volumes/lakeflow_dlt/landing_zone/fact_and_dimension_files/dim_products',
  'csv',
  map('header', 'true')
);


-- customers ingestion
CREATE STREAMING LIVE TABLE bronze.customers
COMMENT "Raw customers from volume to bronze schema"
AS SELECT * FROM CLOUD_FILES(
  '/Volumes/lakeflow_dlt/landing_zone/fact_and_dimension_files/dim_customers',
  'csv',
  map('header', 'true')
);


-- Regions Ingestion

CREATE STREAMING LIVE TABLE bronze.regions
COMMENT "Raw regions from volume to bronze schema"
AS SELECT * FROM CLOUD_FILES(
  '/Volumes/lakeflow_dlt/landing_zone/fact_and_dimension_files/dim_regions',
  'csv',
  map('header', 'true')
);







