/*
creat data base and schemas
--------------------
this code will creat new data base named DataWarehouse and make tree schemas named bronze , silver ,gold .

WARNING ..
if there is database named DateWherehouse this code will drop it and creat new one 


*/



USE master;
GO

IF EXISTS (SELECT 1 FROM sys.Databases WHERE name = 'DateWarehouse')
BEGIN 
	ALTER DATABASE DateWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE ;
	DROP DATABASE DateWarehouse;
END ;
GO

CREATE DATABASE DateWarehouse;
GO

USE DateWarehouse;
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
