
CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN


    ------------------------------------------------------------------
    -- TOTAL EXECUTION TIMER
    ------------------------------------------------------------------
    DECLARE @t_start DATETIME = GETDATE();
    DECLARE @step_start DATETIME;
    DECLARE @duration VARCHAR(50);

    PRINT '================================================';
    PRINT 'START LOADING SILVER LAYER';
    PRINT 'Start Time: ' + CONVERT(varchar, @t_start, 120);
    PRINT '================================================';


    BEGIN TRY
    ------------------------------------------------------------------
    -- STEP 1: CRM CUSTOMER INFO
    ------------------------------------------------------------------
    SET @step_start = GETDATE();  
    PRINT 'Step 1: Loading silver.crm_cust_info (Start: ' 
          + CONVERT(varchar, @step_start, 120) + ')';

    PRINT '  Truncating silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;

    PRINT '  Inserting into silver.crm_cust_info';
    INSERT INTO silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT 
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END,
        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END,
        cst_create_date
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
    ) t
    WHERE flag_last = 1;

    SET @duration = CAST(DATEDIFF(SECOND, @step_start, GETDATE()) AS VARCHAR) + ' sec';
    PRINT '  Completed Step 1 in ' + @duration;
    PRINT '------------------------------------------------';


    ------------------------------------------------------------------
    -- STEP 2: CRM PRODUCT INFO
    ------------------------------------------------------------------
    SET @step_start = GETDATE();
    PRINT 'Step 2: Loading silver.crm_prd_info (Start: ' 
          + CONVERT(varchar, @step_start, 120) + ')';

    PRINT '  Truncating silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;

    PRINT ' Inserting into silver.crm_prd_info';
    INSERT INTO silver.crm_prd_info (
        prd_id,
        cut_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT 
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
        SUBSTRING(prd_key, 7, LEN(prd_key)),
        prd_nm,
        ISNULL(prd_cost, 0),
        CASE 
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'road'
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'mountain'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'touring'
            WHEN UPPER(TRIM(prd_line)) = 'O' THEN 'other sales'
            ELSE 'n/a'
        END,
        CAST(prd_start_dt AS DATE),
        CAST(LEAD(prd_end_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE)
    FROM bronze.crm_prd_info;

    SET @duration = CAST(DATEDIFF(SECOND, @step_start, GETDATE()) AS VARCHAR) + ' sec';
    PRINT '  Completed Step 2 in ' + @duration;
    PRINT '------------------------------------------------';


    ------------------------------------------------------------------
    -- STEP 3: CRM SALES DETAILS
    ------------------------------------------------------------------
    SET @step_start = GETDATE();
    PRINT 'Step 3: Loading silver.crm_sales_details (Start: ' 
          + CONVERT(varchar, @step_start, 120) + ')';

    PRINT '  Truncating silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;

    PRINT '  Inserting into silver.crm_sales_details';
    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
             ELSE TRY_CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
        END,
        CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
             ELSE TRY_CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE)
        END,
        CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
             ELSE TRY_CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE)
        END,
        CASE 
            WHEN sls_sales IS NULL OR sls_sales <= 0 
                 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price) 
            ELSE sls_sales
        END,
        sls_quantity,
        CASE 
            WHEN sls_price IS NULL OR sls_price >= 0 
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END
    FROM bronze.crm_sales_details;

    SET @duration = CAST(DATEDIFF(SECOND, @step_start, GETDATE()) AS VARCHAR) + ' sec';
    PRINT '  Completed Step 3 in ' + @duration;
    PRINT '------------------------------------------------';


    ------------------------------------------------------------------
    -- STEP 4: ERP CUSTOMER AZ12
    ------------------------------------------------------------------
    SET @step_start = GETDATE();
    PRINT 'Step 4: Loading silver.erp_cust_az12 (Start: ' 
          + CONVERT(varchar, @step_start, 120) + ')';

    PRINT '  Truncating silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;

    PRINT '  Inserting into silver.erp_cust_az12';
    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
             ELSE cid
        END,
        CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END,
        CASE 
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END
    FROM bronze.erp_cust_az12;

    SET @duration = CAST(DATEDIFF(SECOND, @step_start, GETDATE()) AS VARCHAR) + ' sec';
    PRINT '  Completed Step 4 in ' + @duration;
    PRINT '------------------------------------------------';


    ------------------------------------------------------------------
    -- STEP 5: ERP LOCATION
    ------------------------------------------------------------------
    SET @step_start = GETDATE();
    PRINT 'Step 5: Loading silver.erp_loc_a1012 (Start: ' 
          + CONVERT(varchar, @step_start, 120) + ')';

    PRINT '  Truncating silver.erp_loc_a1012';
    TRUNCATE TABLE silver.erp_loc_a1012;

    PRINT '  Inserting into silver.erp_loc_a1012';
    INSERT INTO silver.erp_loc_a1012 (cid, cntry)
    SELECT 
        REPLACE(cid, '-', ''),
        CASE 
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
            ELSE TRIM(cntry)
        END
    FROM bronze.erp_loc_a1012;

    SET @duration = CAST(DATEDIFF(SECOND, @step_start, GETDATE()) AS VARCHAR) + ' sec';
    PRINT '  Completed Step 5 in ' + @duration;
    PRINT '------------------------------------------------';


    ------------------------------------------------------------------
    -- STEP 6: ERP PRODUCT CATEGORY
    ------------------------------------------------------------------
    SET @step_start = GETDATE();
    PRINT 'Step 6: Loading silver.erp_px_cat_g1v2 (Start: ' 
          + CONVERT(varchar, @step_start, 120) + ')';

    PRINT '  Truncating silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    PRINT ' Inserting into silver.erp_px_cat_g1v2';
    INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcut, maintenance)
    SELECT 
        id, cat, subcut, maintenance
    FROM bronze.erp_px_cat_g1v2;

    SET @duration = CAST(DATEDIFF(SECOND, @step_start, GETDATE()) AS VARCHAR) + ' sec';
    PRINT '  Completed Step 6 in ' + @duration;
    PRINT '------------------------------------------------';


    ------------------------------------------------------------------
    -- COMPLETION MESSAGE
    ------------------------------------------------------------------
    DECLARE @total_duration VARCHAR(50) = 
        CAST(DATEDIFF(SECOND, @t_start, GETDATE()) AS VARCHAR) + ' sec';

    PRINT '================================================';
    PRINT 'SILVER LAYER LOADED SUCCESSFULLY!';
    PRINT 'Total Duration: ' + @total_duration;
    PRINT 'Finish Time: ' + CONVERT(varchar, GETDATE(), 120);
    PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '************************************************';
        PRINT 'ERROR OCCURRED!';
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT '************************************************';
        THROW;
    END CATCH;

END
