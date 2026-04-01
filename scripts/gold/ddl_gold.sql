IF OBJECT_ID('gold.dim_customers' , 'v' )IS NOT NULL 
	DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS 
SELECT 
ROW_NUMBER () OVER (ORDER BY ci.cst_id) AS customer_key , 
ci.cst_id AS customer_id ,
ci.cst_key AS customer_number ,
ci.cst_firstname AS first_name ,
ci.cst_lastname AS last_name ,
la.cntry AS contry,
ci.cst_marital_status AS marital_status ,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	ELSE COALESCE (cg.gen , 'n/a')
END AS gender,
cg.bdate AS birthdate ,
ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_loc_a1012 AS la
	ON ci.cst_key = la.cid
LEFT JOIN silver.erp_cust_az12 AS cg
	ON ci.cst_key = cg.cid ; 
GO
IF OBJECT_ID('gold.dim_products' , 'v' )IS NOT NULL 
	DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS 
SELECT
ROW_NUMBER () OVER (ORDER BY pe.prd_start_dt , pe.prd_key) AS product_key,
pe.prd_id AS product_id,
pe.prd_key AS product_number,
pe.prd_nm AS product_name,
pe.cut_id AS category_id,
pc.cat AS category,
pc.subcut AS subcategory,
pc.maintenance,
pe.prd_cost AS cost,
pe.prd_line AS product_line,
pe.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pe
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
	ON pe.cut_id = pc.id
WHERE pe.prd_end_dt IS NULL ;
GO
IF OBJECT_ID('gold.fact_sales' , 'v' )IS NOT NULL 
	DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
SELECT  
se.sls_ord_num AS order_number , 
pr.product_key,
ce.customer_key,
se.sls_order_dt AS order_date,
se.sls_ship_dt AS shipping_date,
se.sls_due_dt AS due_date,
se.sls_sales AS sales_amount,
se.sls_quantity AS quantity,
se.sls_price AS price
 FROM silver.crm_sales_details AS se
 LEFT JOIN gold.dim_products AS pr
	ON se.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS ce
	ON se.sls_cust_id = ce.customer_id;
