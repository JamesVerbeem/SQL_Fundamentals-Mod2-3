-- Module 3 Class Project

USE Northwind

-- 1) Break a dataset into two tables using: CREATE, SELECT, INSERT, and UPDATE
-- 2) Join the two tables by using: INNER JOIN, LEFT OUTER JOIN, RIGHT OUTER JOIN, FULL OUTER JOIN
-- 3) Demonstrate how UNION, INTERSECT, and EXCEPT differ from the JOIN operation
;
-- Breaking up dbo.Customers into two or more tables
-- Find a table with a decent amount of data that can be manipulated with JOIN statements once broken
SELECT *
	FROM Customers;

SELECT COUNT(Distinct Country)
	FROM Customers -- 21 records
	UNION
	SELECT COUNT(*)
		FROM Customers -- 91 records;

SELECT DISTINCT Country
	FROM Customers;

CREATE TABLE M3_Region(
	RegionID int,
	RegionLong varchar(25),
	RegionShort varchar(2)
	PRIMARY KEY(RegionID)
);
	-- This table had to be dropped, see note below

ALTER TABLE M3_Region
	ALTER COLUMN RegionID int IDENTITY(1,1) PRIMARY KEY;
	-- Not possible to add the IDENTITY property after the fact, table must be created with it 

DROP TABLE M3_Region;
	-- Now table can be recreated with the IDENTITY property

CREATE TABLE M3_Region(
	RegionID int IDENTITY(1,1) PRIMARY KEY,
	RegionLong varchar(25) NOT NULL,
	RegionShort varchar(2) NOT NULL
);
	-- Table created with auto increment on primary key RegionID (via IDENTITY property)

SELECT *
	FROM M3_Region

INSERT INTO M3_Region
	VALUES(
		'North America', 'NA'),(
		'South America', 'SA'),(
		'European Union', 'EU'
);
	-- Did not need to populate the attribute RegionID as it auto poplated due to the IDENTITY parameter when creating the table

CREATE TABLE M3_CustAll(
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[CustAddress] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [nvarchar](15) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL,
	PRIMARY KEY (CustomerID)
);

SELECT *
	FROM M3_CustAll;

-- Copy data over from original table so data can be altered and create additional tables
INSERT INTO M3_CustAll
	SELECT *
		FROM Customers;

SELECT *
	FROM M3_Region;

SELECT DISTINCT Country
	FROM M3_CustAll

CREATE TABLE M3_Country(
	Country varchar (15) NOT NULL,
	RegionLong varchar(25) NOT NULL,
	RegionShort varchar(2) NOT NULL,
	PRIMARY KEY(Country)
);

ALTER TABLE M3_Country
	ALTER COLUMN RegionLong varchar(25) NULL;
		

ALTER TABLE M3_Country
	ALTER COLUMN RegionShort varchar(2) NULL;

SELECT *
	FROM M3_Country;

INSERT INTO M3_Country (Country)
	SELECT DISTINCT Country
		FROM M3_CustAll

UPDATE M3_Country
	SET RegionLong = 'South America', RegionShort = 'SA'
	WHERE Country = 'Argentina' OR
	Country = 'Brazil' OR
	Country = 'Venezuela'

UPDATE M3_Country
	SET RegionLong = 'North America', RegionShort = 'NA'
	WHERE Country = 'Canada' OR
	Country = 'Mexico' OR
	Country = 'USA'

UPDATE M3_Country
	SET RegionLong = 'Europe', RegionShort = 'EU'
	WHERE Country = 'Austria' OR
	Country = 'Belgium' OR
	Country = 'Denmark' OR
	Country = 'Finland' OR
	Country = 'France' OR
	Country = 'Germany' OR
	Country = 'Ireland' OR
	Country = 'Italy' OR
	Country = 'Norway' OR
	Country = 'Poland' OR
	Country = 'Portugal' OR
	Country = 'Spain' OR
	Country = 'Sweden' OR
	Country = 'Switzerland' OR
	Country = 'UK';

INSERT INTO M3_Region
	VALUES (
		'Asia', 'AS'),(
		'Oceania', 'OC'
);
	-- Inserting more regions to generate NULL values for JOIN clauses

-- Should have created a Stored Procedure to make updating the Region column easier
UPDATE M3_CustAll
	SET Region = 'NA'
	WHERE Country = 'USA';
	-- Adding some correct Region column data

UPDATE M3_CustAll
	SET Region = 'EU'
	WHERE Country LIKE '%ance';
	-- Adding some correct Region column data using LIKE operator

UPDATE M3_CustAll
	SET Region = 'SA'
	WHERE Country LIKE 'Venez%';
	-- Adding some correct Region column data using LIKE operator
;
-- Demonstrate JOIN clauses
-- SELECT Statements
USE Northwind

SELECT *
	FROM M3_Country;

SELECT *
	FROM M3_Region;

SELECT *
	FROM M3_CustAll;
	-- This table has an incomplete Region column and some incorrect entries
	
SELECT M3_CustAll.CustomerID, M3_CustAll.City, M3_Country.Country, M3_Country.RegionShort
	FROM M3_CustAll
	INNER JOIN M3_Country
	ON M3_CustAll.Country = M3_Country.Country;
	-- Returns all 91 records and the correct short region code for each

SELECT M3_CustAll.CustomerID, M3_CustAll.City, M3_Country.RegionShort, M3_Region.RegionID
	FROM M3_CustAll
	INNER JOIN M3_Country
		ON M3_CustAll.Country = M3_Country.Country
	INNER JOIN M3_Region
		ON M3_Country.RegionShort = M3_Region.RegionShort;
	-- Returns all 91 records from M3_CustAll and one other column from each of M3_Country and M3_Region
	-- Joins three tables and correctly displays RegionShort and RegionID columns, instead of the incomplete/flawed information

SELECT M3_CustAll.CustomerID, M3_CustAll.Region, M3_Region.RegionLong
	FROM M3_CustAll
	LEFT JOIN M3_Region
		ON M3_CustAll.Region = M3_Region.RegionShort;
	-- Returns all 91 records from the "left", or first, table (M3_CustAll)
	-- Region column returns existing values from M3_CustAll.Region, including NULL values and flawed data
	-- RegionLong column returns values when a match is found between the two tables and NULL values when there is no match 

SELECT M3_CustAll.CustomerID, M3_CustAll.Region, M3_Region.RegionID
	FROM M3_CustAll
	RIGHT JOIN M3_Region
		ON M3_CustAll.Region = M3_Region.RegionShort;
	-- Returns all 28 records that have the M3_CustAll.Region filled out correctly
	-- Returns 2 NULL records for the records of M3_Region.RegionShort that have no matches in M3_CustAll

SELECT M3_CustAll.CustomerID, M3_CustAll.Region, M3_Region.RegionID
	FROM M3_CustAll
	FULL JOIN M3_Region
		ON M3_CustAll.Region = M3_Region.RegionShort
	ORDER BY M3_Region.RegionID DESC;
	-- Returns a total of 93 records, 2 more than the INNER JOIN of three tables
	-- 91 records from M3_CustAll (91) and 2 records from M3_Region that do match up with any records from M3_CustAll

-- Demonstrate UNION, INTERSECT, and EXCEPT operators
SELECT Region
	FROM M3_CustAll
	UNION
	SELECT RegionShort
		FROM M3_Region;
	-- Returns the *distinct values from both* M3_CustAll.Region and M3_Region.RegionShort, even if they appear only on one of the tables

SELECT Region
	FROM M3_CustAll
	INTERSECT
	SELECT RegionShort
		FROM M3_Region;
	-- Returns only the *distinct values that are common* between M3_CustAll.Region and M3_Region.RegionShort

SELECT Region
	FROM M3_CustAll
	EXCEPT
	SELECT RegionShort
		FROM M3_Region;
	-- Returns only the *distinct values that are unique* between M3_CustAll.Region and M3_Region.RegionShort, no common values displayed