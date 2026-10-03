--1)Database Exploration

--Explore all objects in the database
Select * from INFORMATION_SCHEMA.TABLES

--Explore all columns in the database
Select * from INFORMATION_SCHEMA.COLUMNS

--Explore all columns for specific table
Select * from INFORMATION_SCHEMA.COLUMNS
WHere TABLE_NAME = 'dim_customers'
