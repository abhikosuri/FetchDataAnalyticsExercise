--1. Finding Data Quality Issues
--User Table
SELECT * FROM USER_TAKEHOME Limit 10
--There are missing values in Birth_Date, State, Language and Gender columns

Select count(*) From USER_TAKEHOME Where Birth_date = ''
--3675 records where birthdate is missing
Select count(*) From USER_TAKEHOME Where State = ''
--4812 records where state is missing
Select count(*) From USER_TAKEHOME Where language = ''
--30508 records where language is missing
Select count(*) From USER_TAKEHOME Where Gender = ''
--5892 records where gender is missing

--Fields that need some more understanding: 
--Language - What does es-419 stand for?

------------------------------------------------------------------
--Transaction Table
SELECT * FROM Transaction_TAKEHOME Limit 10
--Barcode has some missing values
--When Final Quality has a value, why is there no Final Sale?
--When Final Quantity is zero, why does Final Sale have a value?

Select Count(*) From TRANSACTION_TAKEHOME Where barcode is Null
--5762 records with missing barcode

--Fields that need some more understanding: 
--Final Quantity - Is this the number of products purchased? Why is it often 1 or zero?
--Final Sale - Is this the final price of a purchase?

------------------------------------------------------------------
--Products Table
SELECT * FROM PRODUCTS_TAKEHOME Limit 10
--Manufacturer, Brand and some Barcodes are missing
--Category 4 seems to be empty for many records
--Category 2,3 and 4 seem to depend on one another must be a breakdown into subcategories
--Can't just assume the same brand and manufacturer could be for same category of products of missing info

--What is Placeholder Manufacturer? Is it a real manufacturer or just a fill in value?

---------------------------------------------------------------------------------------------------------------
--2. SQL Queries

--Q1: What are the top 5 brands by receipts scanned among users 21 and over?

--Get 21 and over users using birthdate
With userage as(
  Select * 
	From 
	(Select *, Cast(birth_date as Date) as year from USER_TAKEHOME)
	Where year < 2003
)
-- get top 5 brands     
Select p.BRAND
From userage u 
Join TRANSACTION_TAKEHOME t On u.ID = t.USER_ID
Join PRODUCTS_TAKEHOME p ON t.BARCODE = p.BARCODE
Where Brand != ''
Group by p.BRAND
order by count(t.RECEIPT_ID) Desc
Limit 5

--Nerds Candy, DOve, Trident, Sour Patch Kids and Meijer
--Are the top 5 brands by receipts scanned among users 21 and over

------------------------------------------------------------------------------------

--Q2: Which is the leading brand in the Dips & Salsa category?
--Identify which category column contains Dips & Salsa
Select * From PRODUCTS_TAKEHOME Where category_2 = 'Dips & Salsa'

--Query to find the leading brand in this category
--Assuming we are not considering null entry brands and the ones we are provided
Select Brand, count(*)
From PRODUCTS_TAKEHOME
Where Brand != '' and category_2 = 'Dips & Salsa'
Group By Brand
Order by Count(*) Desc
Limit 1

--Private Label is the leading brand in the Dips & Salsa category
--Followed by Sabra, Wholly & Tostitos

--------------------------------------------------------------------------------

--Q3: At what percent has Fetch grown year over year?
--Assuming we want to get the count of new users who joined Fetch
--Get the count of users who joined using created_date column per every year
With users As( 
  Select year, count(*) as newusers
	From(Select cast(created_date as Date) as year From USER_TAKEHOME)
	Group by year
	Order by year DESC
	)
--Now to calculate the percentage from previous year with following year
Select year, 100 * newusers / LAG(newusers) OVER (ORDER BY year) AS difference_previous_year
From users
ORder by year Desc

--Now we have the output as a percentage to show an increase and decrease in new users who joined Fetch
-------------------------------------------------------------------------------------------------------------
