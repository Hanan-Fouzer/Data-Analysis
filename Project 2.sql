-- Creating a new database
CREATE DATABASE Project4;
USE Project4;

-- Creating table to match the data
CREATE TABLE Sales(Transaction_ID VARCHAR(50), Item CHAR(50), Quantity VARCHAR(50), 
Price_Per_Unit VARCHAR(50),Total_Spent VARCHAR(50),Payment_Method VARCHAR(100), 
Location VARCHAR(100), Transaction_Date VARCHAR(50));

-- Loading the data set
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dirty_cafe_sales.csv"
INTO TABLE Sales 
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Cleaning

-- 01. Replacing ERROR with blank in transcation_date column

-- Creating New column
ALTER TABLE Sales ADD COLUMN T_Date DATE;
-- Replacing
SET SQL_SAFE_UPDATES=0;
UPDATE Sales SET T_Date = STR_TO_DATE(Transaction_Date,'%m/%d/%Y')
WHERE LOWER(Transaction_Date) NOT REGEXP 'error|" "|unknown' ;
-- Doesnt work
-- Checking Unique Values
SELECT DISTINCT Transaction_Date FROM Sales;
-- ERROR
-- UNKNOWN
-- JUST BLANK

-- Checking the data again
SELECT COUNT(Transaction_Date) FROM Sales WHERE LOWER(Transaction_Date) LIKE '%error%';
SELECT COUNT(Transaction_Date) FROM Sales WHERE LOWER(Transaction_Date) LIKE '%unknown%';
SELECT COUNT(Transaction_Date) FROM Sales WHERE TRIM(Transaction_Date)='';
SELECT COUNT(Transaction_Date) FROM Sales WHERE TRIM(Transaction_Date) IS NULL;
SELECT COUNT(Transaction_Date) FROM Sales;

-- Checking for hidden entries
SELECT Transaction_Date, HEX(Transaction_Date) FROM Sales 
WHERE Transaction_Date IS NOT NULL;

-- Since OD came, CHAR(13) is used
SELECT Transaction_Date, REPLACE(Transaction_Date,CHAR(13),'') FROM Sales WHERE Transaction_Date LIKE '%\r%';

-- Updating hidden value to blank
UPDATE Sales SET Transaction_Date= REPLACE(Transaction_Date,CHAR(13),'') 
WHERE Transaction_Date LIKE '%\r%';

SELECT COUNT(Transaction_Date) FROM Sales WHERE Transaction_Date='';

-- Updating in T_date
-- Replacing
ALTER TABLE Sales ADD COLUMN T_Date DATE;
UPDATE Sales SET T_Date= CASE
WHEN Transaction_Date NOT LIKE '%ERROR%' 
AND Transaction_Date NOT LIKE '%UNKNOWN%'
AND Transaction_Date !=''
THEN STR_TO_DATE(Transaction_Date,'%m/%d/%Y')
END;

ALTER TABLE Sales DROP COLUMN Transaction_Date;


-- Updating the Item column
SELECT DISTINCT Item FROM Sales;
-- UNKNOWN
-- ERROR
-- BLANK 

SELECT COUNT(Item) FROM Sales WHERE Item LIKE '%ERROR%';
SELECT COUNT(Item) FROM Sales WHERE Item LIKE '%UNKNOWN%';
SELECT Item,HEX(Item) From Sales;
SELECT COUNT(Item) FROM Sales WHERE Item='';

-- For item column without creating new column
UPDATE Sales SET Item= REPLACE(Item,"ERROR","");
UPDATE Sales SET Item= REPLACE(Item,"UNKNOWN","");

-- Updating the Quantity Colum
UPDATE Sales SET Quantity= REPLACE(Quantity,"ERROR","");
UPDATE Sales SET Quantity= REPLACE(Quantity,"UNKNOWN","");

SELECT DISTINCT Price_Per_Unit FROM Sales;

-- Updating the Price_Per_Unit column
UPDATE Sales SET Price_Per_Unit=REPLACE(Price_Per_Unit,"ERROR","");
UPDATE Sales SET Price_Per_Unit=REPLACE(Price_Per_Unit,"UNKNOWN","");

SELECT * FROM Sales;

-- Updating the Total_Spent column
UPDATE Sales SET Total_Spent=REPLACE(Total_Spent,"ERROR","");
UPDATE Sales SET Total_Spent=REPLACE(Total_Spent,"UNKNOWN","");	

-- Updating the Payment_Method column
UPDATE Sales SET Payment_Method=REPLACE(Payment_Method,"ERROR","");
UPDATE Sales SET Payment_Method=REPLACE(Payment_Method,"UNKNOWN","");

-- Updating the location column
UPDATE Sales SET Location=REPLACE(Location,"ERROR","");
UPDATE Sales SET Location=REPLACE(Location,"UNKNOWN","");

-- Changing data types with new columns:
ALTER TABLE Sales ADD Qty INT;
UPDATE Sales SET Qty=CASE
WHEN Quantity!=''
THEN CAST(Quantity AS FLOAT)
END;
ALTER TABLE Sales DROP COLUMN Quantity;

-- Changing the next
ALTER TABLE Sales ADD COLUMN Spent_Total INT;
UPDATE Sales SET Spent_Total= CASE
WHEN Total_Spent!=''
THEN CAST(Total_Spent AS FLOAT)
END;
ALTER TABLE Sales DROP COLUMN Total_Spent;

-- Next:
ALTER TABLE Sales ADD COLUMN Unit_Cost INT;
UPDATE Sales SET Unit_Cost= CASE
WHEN Price_Per_Unit!=''
THEN  CAST(Price_Per_Unit AS FLOAT)
END;
ALTER TABLE Sales DROP COLUMN Price_Per_Unit;


-- Next
ALTER TABLE Sales ADD COLUMN Pay_Method CHAR(50);
UPDATE Sales SET Pay_Method= CASE
WHEN Payment_Method!=''
THEN CAST(Payment_Method AS CHAR)
END;
ALTER TABLE Sales DROP COLUMN Payment_Method;

-- Next
ALTER TABLE Sales ADD COLUMN Loc CHAR(100);
UPDATE Sales SET Loc=CASE
WHEN Location!=''
THEN CAST(Location AS CHAR)
END;
ALTER TABLE Sales DROP COLUMN Location;

-- Next
ALTER TABLE Sales ADD COLUMN Items CHAR(50);
UPDATE Sales SET Items= CASE
WHEN Item!=''
THEN CAST(Item AS CHAR)
END;
ALTER TABLE Sales DROP COLUMN Item;


-- Finalized
SELECT * FROM Sales;

-- Questions

-- 01. Find all transactions that occurred on a specific date.
SELECT * FROM Sales WHERE T_Date='2023-07-20';

-- 02. Count the number of transactions made at each location.
SELECT Loc,COUNT(Loc) AS COUNT FROM Sales GROUP BY Loc 
HAVING COUNT(Loc);

-- 03. Calculate the total revenue generated (sum of Total_Spent).
SELECT SUM(Spent_Total) FROM Sales;

-- 04. List all unique items sold.
SELECT DISTINCT Items FROM Sales;

-- 05. Find the most frequently purchased item.
SELECT Items,COUNT(T_Date) FROM Sales GROUP BY Items
HAVING COUNT(T_Date) ORDER BY COUNT(T_DATE) DESC;

-- 06. Calculate the average Price_per_unit for all items.
SELECT Items, AVG(Unit_Cost) FROM Sales GROUP BY Items
HAVING AVG(Unit_Cost);

-- 07. List all transactions where more than 5 units of an item were sold.
SELECT * FROM Sales WHERE Qty>5;

-- 08. Retrieve all records where the Total_Spent is greater than $20
SELECT * FROM Sales WHERE Spent_Total>20;

-- 09. Find the total quantity of items sold for each Payment_Method.
SELECT Pay_Method, SUM(Qty) From Sales GROUP BY Pay_Method 
HAVING SUM(Qty);

-- 10. Identify the location with the highest total sales.
WITH Tot AS (
SELECT Loc, SUM(Spent_Total) AS Total_Spent FROM Sales GROUP BY Loc 
)
SELECT Loc, Total_Spent FROM Tot ORDER BY Total_Spent DESC;

-- 11. Find the item with the highest revenue (consider Total_Spent).
SELECT Items, SUM(Spent_Total) FROM Sales GROUP BY Items
HAVING SUM(Spent_Total) ORDER BY SUM(Spent_Total) DESC LIMIT 1;

-- 12. List all transactions that occurred in July
SELECT * FROM Sales WHERE T_Date BETWEEN '2023-07-01' AND '2023-07-31';

-- 13. Calculate the total revenue generated per day.
SELECT T_Date, SUM(Spent_Total) FROM Sales GROUP BY T_Date 
HAVING SUM(Spent_Total) ORDER BY T_Date ASC;

-- 14. Rank locations by their total revenue in descending order.
WITH Ran AS(
SELECT Loc, SUM(Spent_Total) AS Total FROM Sales GROUP BY Loc
)
SELECT Loc, Total , RANK() 
OVER(ORDER BY Total DESC) AS RANKS FROM Ran;

-- Breaking tables to practice joins
SELECT * FROM Sales;
CREATE TABLE Transactions AS SELECT Transaction_ID, T_Date FROM Sales;

-- Dropping those columns in existing table
ALTER TABLE Sales DROP COLUMN T_Date;

SELECT * FROM Sales;
SELECT * FROM Transactions;

-- Joins
-- 15. Combine the two tables to retrieve the complete transaction details.
SELECT * FROM Sales INNER JOIN Transactions ON 
Sales.Transaction_ID=Transactions.Transaction_ID;

-- 16. Find transactions where the Payment_Method is missing in one of the tables
SELECT * FROM Sales RIGHT JOIN Transactions 
ON Sales.Transaction_ID=Transactions.Transaction_ID
WHERE Sales.Pay_Method IS NULL;

-- 17. List items sold at specific locations by combining data from both tables
SELECT * FROM Sales INNER JOIN Transactions 
ON Sales.Transaction_ID=Transactions.Transaction_ID
WHERE Sales.Loc='Takeaway';

-- 18. Identify items that have no corresponding sales in the second table
SELECT Sales.Items, Transactions.Transaction_ID FROM Sales 
INNER JOIN Transactions 
ON Sales.Transaction_ID=Transactions.Transaction_ID
WHERE Sales.Spent_Total IS NULL;

-- 19. Calculate the total revenue for each location by joining the two tables
SELECT Sales.Loc, SUM(Sales.Spent_Total) FROM Sales 
INNER JOIN Transactions 
ON Sales.Transaction_ID=Transactions.Transaction_ID
GROUP BY Sales.Loc;

