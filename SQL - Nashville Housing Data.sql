CREATE DATABASE NashvilleHousing

USE NashvilleHousing

--THE TABLE WAS MANULLAY UPLOADED TO A TABLE TITLE "Nashville"--
SELECT * 
FROM Nashville


/*

DATA CLEANING ON NASHVILLE HOUSING DATA

*/

--NORMALIZING THE DATE FORMAT (OPTIONAL)--

SELECT SaleDate
FROM Nashville  --MY SALE DATE IS IN ITS PROPER FORMAT--

--USE BELOW IF YOURS ISN'T--

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Nashville 

UPDATE Nashville
SET SaleDate = CONVERT(Date, SaleDate)


--REMOVING NULL IN PropertyAddress, AND COMPLETING THE EMPTY ROWS

SELECT PropertyAddress
FROM Nashville
WHERE PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM Nashville AS A
JOIN Nashville AS B
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


UPDATE A
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville AS A
JOIN Nashville AS B
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


--SEPARATING PROPERTY ADDRESS INTO (Address, City) COLUMNS

SELECT PropertyAddress
FROM Nashville

--USING SUBSTRING AND CHAR INDEX

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address, CHARINDEX(',', PropertyAddress)
FROM Nashville

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
FROM Nashville

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Street, 
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM Nashville

ALTER TABLE Nashville
Add Address Nvarchar(255)

UPDATE Nashville
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE Nashville
Add City Nvarchar(255)

UPDATE Nashville
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM Nashville

--SEPARATING OWNER ADDRESS INTO (Address, City, State) COLUMNS

SELECT OwnerAddress
FROM Nashville

--PARSENAME AND REPLACE(IF NEEDED)

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Owner_Address,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS Owner_City,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS Owner_State
FROM Nashville

ALTER TABLE Nashville
ADD Owner_Address Nvarchar(255)

UPDATE Nashville
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville
ADD Owner_City Nvarchar(255)

UPDATE Nashville
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville
ADD Owner_State Nvarchar(255)

UPDATE Nashville
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM Nashville

--MY SoldAsVacant is (0) and (1) instead of (No) and (Yes)

SELECT DISTINCT(SoldAsVacant)
FROM Nashville

SELECT SoldAsVacant
FROM Nashville
WHERE SoldAsVacant LIKE '0'

SELECT SoldAsVacant
FROM Nashville
WHERE SoldAsVacant LIKE '1'

--FIRST CHANGE DATATYPE OF SoldAsVacant to NVARCHAR

ALTER TABLE Nashville
ALTER COLUMN SoldAsVacant NVARCHAR(100);

--NOW UPDATE SoldAsVacant 

UPDATE Nashville
SET SoldAsVacant = 'No'
WHERE SoldAsVacant LIKE '0'

UPDATE Nashville
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant LIKE '1'

SELECT *
FROM Nashville


--REMOVE DUPLICATES--

WITH Row_NumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY    ParcelId,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) AS Row_Num

FROM Nashville)

SELECT *
FROM Row_NumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress

--NOW DELETE

WITH Row_NumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY    ParcelId,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) AS Row_Num

FROM Nashville)

DELETE
FROM Row_NumCTE
WHERE Row_Num > 1

SELECT *
FROM Nashville



--DELETING UNUSED COLUMNS

SELECT *
FROM Nashville 

ALTER TABLE Nashville
DROP COLUMN PropertyAddress, OwnerAddress

--------------------------------------------------------
