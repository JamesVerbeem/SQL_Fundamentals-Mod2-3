-- Start of Module 2 (Module II)
-- Create and Use Stored Procedures
USE Northwind

SELECT *
	FROM Suppliers

-- Can be shortened to CREATE PROC
CREATE PROCEDURE sp_SuppCity
	AS
	BEGIN
		SELECT
			CompanyName,
			City,
			Country
		FROM
			Suppliers
		ORDER BY
			Country desc
	END;

EXECUTE sp_SuppCity

SELECT *
	FROM [Order Details]

SELECT
		OrderID,
		ProductID,
		UnitPrice*Quantity*(1-Discount) AS TotalSale
	FROM [Order Details]
	WHERE (UnitPrice*Quantity*(1-Discount) > 100)

CREATE PROC sp_MinSale
	AS
	BEGIN
		SELECT
			OrderID,
			ProductID,
			UnitPrice*Quantity*(1-Discount) AS TotalSale
		FROM [Order Details]
		ORDER BY TotalSale desc
	END;

EXEC sp_MinSale

ALTER PROC sp_MinSale(@min_sale AS decimal)
	AS
	BEGIN
		SELECT
			OrderID,
			ProductID,
			UnitPrice*Quantity*(1-Discount) AS TotalSale
		FROM [Order Details]
		WHERE UnitPrice*Quantity*(1-Discount) >= @min_sale
		ORDER BY TotalSale desc
	END;

-- Must now specify the parameter for the TotalSale column!!!
EXEC sp_MinSale 5000

-- Add multiple parameters and make them optional
ALTER PROC sp_MinSale
	(@min_sale AS decimal = 0,
	@max_qty AS decimal = NULL,
	@prod_id AS int = NULL)
	AS
	BEGIN
		SELECT
			OrderID,
			ProductID,
			UnitPrice*Quantity*(1-Discount) AS TotalSale
		FROM [Order Details]
		WHERE UnitPrice*Quantity*(1-Discount) >= @min_sale
			AND (@max_qty IS NULL
				OR Quantity <= @max_qty)
			AND (ProductID = @prod_id
				OR @prod_id IS NULL)
		ORDER BY TotalSale desc
	END;

EXEC sp_MinSale

-- DOES NOT WORK
-- CREATE PROC sp_SalesPrice
-- 	AS
-- 	BEGIN
-- 		SELECT 
-- 			OrderID,
-- 			ProductID,
-- 			TotalSale
-- 		FROM
-- 			(SELECT
-- 				OrderID,
-- 				ProductID,
-- 				CASE
-- 				WHEN UnitPrice*Quantity*(1-Discount)
-- 				END AS TotalSale
-- 			FROM [Order Details]
-- 			)
-- 		WHERE
-- 			CASE WHEN TotalSale > 100
--		
-- ABOVE DOES NOT WORK

EXEC sp_MinSale
	@prod_id = 38

-- User Defined Function
CREATE FUNCTION udf_TotalSale
		(@qty int,
		@unit_price decimal,
		@discount decimal)
	RETURNS decimal
		AS
		BEGIN
			RETURN @qty * @unit_price * (1 - @discount);
		END

ALTER FUNCTION udf_TotalSale
		(@qty int,
		@unit_price dec(10,2),
		@discount dec(10,2))
	RETURNS money
		AS
		BEGIN
			RETURN @qty * @unit_price * (1 - @discount);
		END

-- Test dbo.udf_TotalSale for select parameters
SELECT
	dbo.udf_TotalSale(54.85, 89, .13) TotalSale;

SELECT *
	FROM [Order Details];

-- Test dbo.udf_TotalSale using a table
SELECT
		ProductID,
		SUM(dbo.udf_TotalSale(Quantity, UnitPrice, Discount)) TotalSale
	FROM [Order Details]
	GROUP BY ProductID
	ORDER BY TotalSale desc;

-- Build Stored Procedure using the user defined function and display as currency
CREATE PROC sp_TotalSalebyProd
	AS
	BEGIN
		SELECT
			ProductID,
			SUM(dbo.udf_TotalSale(Quantity, UnitPrice, Discount)) TotalSale
		FROM [Order Details]
		GROUP BY ProductID
		ORDER BY TotalSale desc
	END

EXEC sp_TotalSalebyProd

ALTER PROC sp_TotalSalebyProd
	AS
	BEGIN
		SELECT
			ProductID,
			'$' + CONVERT(varchar(12),SUM(dbo.udf_TotalSale(Quantity, UnitPrice, Discount))) TotalSale
		FROM [Order Details]
		GROUP BY ProductID
		ORDER BY TotalSale desc
	END

EXEC sp_TotalSalebyProd

-- No longer sorts properly

ALTER PROC sp_TotalSalebyProd
	AS
	BEGIN
		SELECT
			ProductID,
			'$' + CONVERT(varchar(12),SUM(dbo.udf_TotalSale(Quantity, UnitPrice, Discount))) TotalSale
		FROM [Order Details]
		GROUP BY ProductID
		ORDER BY SUM(dbo.udf_TotalSale(Quantity, UnitPrice, Discount)) desc
	END

EXEC sp_TotalSalebyProd

-- Declare table variables
SELECT *
	FROM Products

SELECT *
	FROM Products
	WHERE CategoryID = 1

DECLARE @product_table 
	TABLE
		(product_name VARCHAR(MAX) NOT NULL,
		supp_id INT NOT NULL,
		unit_price DEC(11,2) NOT NULL);
	INSERT INTO @product_table
		SELECT
			ProductName, 
			SupplierID, 
			UnitPrice
		FROM Products
		WHERE CategoryID = 1
	SELECT *
		FROM @product_table
GO

-- Start of Module 3 (Module III)
-- SELECT Query practice
SELECT *
	FROM Employees

SELECT LastName, FirstName, Title
	FROM Employees
	WHERE Title LIKE 'Sales%'

-- SELECT DISTINCT practice
SELECT *
	FROM Customers
	-- Returns 91 records

SELECT DISTINCT City
	FROM Customers
	-- Returns 69 records

SELECT DISTINCT City, Country 
	FROM Customers
	-- Still returns 69 records

SELECT DISTINCT Country, City 
	FROM Customers
	-- Still returns 69 records, but columns are reordered

SELECT COUNT
	(DISTINCT City)
	AS 'Number of Cities'
	FROM Customers
	-- Returns number of distinct city names, 69

-- ORDER BY clause practice
SELECT *
	FROM Customers
	WHERE Country = 'Brazil'
	ORDER BY City desc
	-- WHERE must come before ORDER BY
	-- The constraint Brazil must be wrapped in single quotes as it is a string, not required for number data types

-- AND, OR, NOT, BETWEEN operators practice
SELECT *
	FROM [Order Details]

SELECT *
	FROM [Order Details] -- As the column name has a space it must be wrapped in square brackets []
	WHERE UnitPrice >= 15.00 AND UnitPrice <= 25.00 -- This section can be done more efficiently with the BETWEEN operator
	ORDER BY ProductID desc

SELECT *
	FROM [Order Details]
	WHERE UnitPrice BETWEEN 15.00 AND 25.00 -- This is more efficient and less error prone than the example above
	ORDER BY ProductID desc
	-- Both of the above examples return the same records

SELECT *
	FROM Orders

SELECT *
	FROM Orders
	WHERE OrderDate BETWEEN 1996-07-05 AND 1996-07-23
	-- Returns 0 records because dates need to be treated as strings and wrapped in single quotes '1996-07-05'
	-- This is because of the extra characters that are used to display dates such as dashes "-"

SELECT *
	FROM Orders
	WHERE OrderDate BETWEEN '1996-07-05' AND '1996-07-23'
	-- Returns 15 records
	
SELECT *
	FROM Orders
	WHERE (OrderDate BETWEEN '1996-07-05' AND '1996-07-15')
	AND (OrderDate BETWEEN '1996-07-18' AND '1996-07-23')
	-- Returns 0 records because both conditions are unable to be satisfied. The AND operator should be OR.

SELECT *
	FROM Orders
	WHERE (OrderDate BETWEEN '1996-07-05' AND '1996-07-15')
	OR (OrderDate BETWEEN '1996-07-18' AND '1996-07-23')
	-- Returns 13 records

-- Order of the operators matter!!!
SELECT *
	FROM Orders
	WHERE (OrderDate BETWEEN '1996-07-05' AND '1996-07-15')
	OR (OrderDate BETWEEN '1996-07-18' AND '1996-07-23')
	AND NOT EmployeeID = 4
	-- Returns 10 records, the NOT operator only applies to the previous condition

SELECT *
	FROM Orders
	WHERE (OrderDate BETWEEN '1996-07-05' AND '1996-07-15')
	AND NOT EmployeeID = 4
	OR (OrderDate BETWEEN '1996-07-18' AND '1996-07-23')
	-- Returns 11 records, the NOT operator only applies to the previous condition

SELECT *
	FROM Orders
	WHERE NOT EmployeeID = 4
	AND (OrderDate BETWEEN '1996-07-05' AND '1996-07-15')
	OR (OrderDate BETWEEN '1996-07-18' AND '1996-07-23')
	-- Returns 11 records, the OR operator only applies to the previous condition. Same records as above.

SELECT *
	FROM Orders
	WHERE ((OrderDate BETWEEN '1996-07-05' AND '1996-07-15')
	OR (OrderDate BETWEEN '1996-07-18' AND '1996-07-23'))
	AND NOT EmployeeID = 4
	-- Returns 8 records, the NOT operator only applies to the previous condition which now includes both the previous conditions due to the parenthesis wrapping ()

SELECT *
	FROM Orders
	WHERE ((OrderDate BETWEEN '1996-07-05' AND '1996-07-15')
	OR (OrderDate BETWEEN '1996-07-18' AND '1996-07-23'))
	AND NOT (EmployeeID = 4 OR EmployeeID = 3)
	-- Returns 5 records

-- UNION Clause practice
SELECT *
	FROM Orders

SELECT ShipCity, ShipCountry
	FROM Orders
	WHERE ShippedDate BETWEEN '1996-08-01' AND '1996-08-15' -- The query up to here returns 10 records
	UNION
	SELECT ShipCity, ShipCountry -- This *must* have the same number of columns as listed in the first SELECT statement listed above
		FROM Orders
		WHERE EmployeeID = 9
	ORDER BY ShipCountry
	-- The complete query returns 34 records

SELECT FirstName
	AS ' List of Name and Territories'
	FROM Employees
	UNION
	SELECT TerritoryID
		FROM EmployeeTerritories
	-- Note that it combines different types of data

-- INTERSECT clause practice
SELECT FirstName
	FROM Employees
	INTERSECT
	SELECT TerritoryID
		FROM EmployeeTerritories
	-- Returns 0 records as the data from the two columns do not intersect

SELECT EmployeeID
	FROM EmployeeTerritories
	INTERSECT
	SELECT EmployeeID
		FROM Employees
	-- Returns 9 records in the order found in the first SELECT Statement 

SELECT CustomerID
	FROM Orders
	INTERSECT
	SELECT CustomerID
	FROM Customers

-- Module IV
USE Northwind

SELECT *
	FROM C
SELECT *
	FROM Products

SELECT *
	FROM M3_Country
	INNER JOIN M3_CustAll
	ON M3_CustAll.Country = M3_Country.Country


