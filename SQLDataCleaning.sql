/*

Cleaning data with SQL Queries

*/

SELECT *
from NashvilleHouses
-- this code is here for me to run multiple times to see if the changes I'm making are correct

-- Step 1 - Standardize date format ---------------------------------------------------------------------------

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHouses

ALTER TABLE NashvilleHouses
Add SaleDateConverted Date;

UPDATE NashvilleHouses
SET SaleDateConverted = CONVERT(Date, SaleDate)

/* 
Now we'll have 2 saledate columns (for now), one with the date+time format and the other with the date format
There's no reason to use a format with time embeded if we're not using the time aspect for the project
*/


-- Step 2 - Populate Property Address Data -------------------------------------------------------------------------

SELECT *
FROM NashvilleHouses
WHERE PropertyAddress is null

/* 
We can see in the data that we have 29 cases of a NULL Property Address, and that's no good for the table
We also know that the ParcelID and the Property Address are related, therefore we can infer the address in 
situations where we have a relatable ParcelID with a Address filled in. 
That's what we're doing
*/


-- Here we have a self join with the uniqueID of the sale separating those with and without the Address filled
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHouses a
JOIN NashvilleHouses b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHouses a
JOIN NashvilleHouses b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-- Step 3 - Braking out the address into columns - Address, City, State ------------------------------------------------------

/*
Now we have the PropertyAddres as "1808  FOX CHASE DR, GOODLETTSVILLE", with the address followed by the city
The ideia in this seccion is to sepparete them with a substring clause
*/

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2 , LEN(PropertyAddress)) as City
FROM NashvilleHouses

-- Adding the Address
ALTER TABLE NashvilleHouses
Add Address nvarchar(255);

UPDATE NashvilleHouses
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHouses
Add City nvarchar(255);

UPDATE NashvilleHouses
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2 , LEN(PropertyAddress))

-- We'll use Parsename for the state value, this time using the OwenerAddress, not the PropertyAddress.

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHouses

ALTER TABLE NashvilleHouses
Add State nvarchar(255);

UPDATE NashvilleHouses
SET State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Step 4 - Change Y and N to YES and NO in "sold as vacant" Field -----------------------------------------------------------------


SELECT Distinct(SoldAsVacant), Count(SoldAsvacant)
FROM NashvilleHouses
Group by SoldAsVacant
Order by SoldAsVacant

/* 
Here we can see there are these answers to the SoldAsVacant column
N	399
No	51403
Y	52
Yes	4623
We want to make them all one or another way.
*/

-- testing the case statement
SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHouses
WHERE SoldAsVacant = 'Y' or SoldAsVacant = 'N'
ORDER BY SoldAsVacant

-- applying the changes
Update NashvilleHouses
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

/* 
here's the new amount of answers:
No	51802
Yes	4675
*/

-- Step 5 - Remove Duplicates -----------------------------------------------------------------------

/* 
At first it is important to address the fact that's not common to use querys to remove data
Once you've used SQL to delete some lines, they're not restorable, therefore it is advised to do it in other fashions
But we'll do it anyway 'cause that's the point of the exercise.
*/

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
FROM NashvilleHouses
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- There are 104 duplicates, so we'll delete them

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
FROM NashvilleHouses
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Step 6 - Delete Unsudes Columns -------------------------------------------------------------

/*
Once again, it is unadvised to delete columns from the table, this is for studies only.
*/


SELECT *
FROM NashvilleHouses

ALTER TABLE NashvilleHouses
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE NashvilleHouses
DROP COLUMN SaleDate
