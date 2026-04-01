CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	BEGIN TRY
		DECLARE @start_time DATETIME , @end_time DATETIME , @start_bronze DATETIME , @end_bronze DATETIME
		SET @start_bronze = GETDATE()
		PRINT ('=====================================');
		PRINT ('loading bronze layer');
		PRINT ('=====================================');

		PRINT ('-------------------------------------');
		PRINT ('loading CRM tables');
		PRINT ('-------------------------------------');

		SET @start_time = GETDATE();
		PRINT ('>> truncating table : bronze.crm_cust_info ');
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT ('>> inserting data into : bronze.crm_cust_info ');
		BULK INSERT bronze.crm_cust_info 
		FROM 'C:\Users\h\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',' ,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT ('>>> loading duration :' + CAST (DATEDIFF (second , @start_time , @end_time) AS NVARCHAR )) + ('seconds');
		PRINT ('-----------------');

		SET @start_time = GETDATE();
		PRINT ('>> truncating table : bronze.crm_prd_info ');
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT ('>> inserting data into : bronze.crm_prd_info ');
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\h\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',' ,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT ('>>> loading duration :' + CAST (DATEDIFF (second , @start_time , @end_time) AS NVARCHAR )) + ('seconds');
		PRINT ('-----------------');


		SET @start_time = GETDATE();
		PRINT ('>> truncating table : bronze.crm_sales_details ');
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT ('>> inserting data into : bronze.crm_sales_details ');
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\h\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',' ,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT ('>>> loading duration :' + CAST (DATEDIFF (second , @start_time , @end_time) AS NVARCHAR )) + ('seconds');
		PRINT ('-----------------');

		PRINT ('-------------------------------------');
		PRINT ('loading ERP tables');
		PRINT ('-------------------------------------');

		SET @start_time = GETDATE();
		PRINT ('>> truncating table : bronze.erp_cust_az12 ');
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT ('>> inserting data into : bronze.erp_cust_az12 ');
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\h\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',' ,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT ('>>> loading duration :' + CAST (DATEDIFF (second , @start_time , @end_time) AS NVARCHAR )) + ('seconds');
		PRINT ('-----------------');

		SET @start_time = GETDATE();
		PRINT ('>> truncating table : bronze.erp_loc_a1012 ');
		TRUNCATE TABLE bronze.erp_loc_a1012;

		PRINT ('>> inserting data into : bronze.erp_loc_a1012 ');
		BULK INSERT bronze.erp_loc_a1012
		FROM 'C:\Users\h\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',' ,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT ('>>> loading duration :' + CAST (DATEDIFF (second , @start_time , @end_time) AS NVARCHAR )) + ('seconds');
		PRINT ('-----------------');


		SET @start_time = GETDATE();
		PRINT ('>> truncating table : bronze.erp_px_cat_g1v2 ');
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT ('>> inserting data into : bronze.erp_px_cat_g1v2 ');
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\h\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',' ,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT ('>>> loading duration :' + CAST (DATEDIFF (second , @start_time , @end_time) AS NVARCHAR )) + ('seconds');
		PRINT ('-----------------');
		SET @end_bronze = GETDATE();
		PRINT ('>>> loading bronzr layer duration :' + CAST (DATEDIFF (second , @start_bronze , @end_bronze) AS NVARCHAR )) + ('seconds');

	END TRY 
	BEGIN CATCH
		PRINT ('++++++++++++++++++++++++++++++++++++++++++++++++++++++++');	
		PRINT ('ERROR OCCURED DURING LOADING BRONZE LAYER');
		PRINT ('error message : ') +  ERROR_MESSAGE();
		PRINT ('error message : ') +  CAST(ERROR_NUMBER() AS NVARCHAR );
		PRINT ('error message : ') +  CAST(ERROR_STATE() AS NVARCHAR );
		PRINT ('++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
	END CATCH
END
