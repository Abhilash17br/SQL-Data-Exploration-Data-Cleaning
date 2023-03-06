# SQL DATA CLEANING ON NASHVILLE HOUSING DATA
-- ------------------------------------------------------------------------------------------------------------------------------
USE PORTFOLIOPROJECTS;

SELECT * 
FROM nashville_housing_data;

DESCRIBE nashville_housing_data;
-- ------------------------------------------------------------------------------------------------------------------------------
-- STANDARDIZE DATE FORMAT

SELECT * 
FROM nashville_housing_data;

-- To Convert the Existing Salesdate to Date format.
SELECT STR_TO_DATE(SaleDate,'%M %d,%Y') from nashville_housing_data;

SET SQL_SAFE_UPDATES = 0;

UPDATE nashville_housing_data
SET SaleDate = STR_TO_DATE(SaleDate,'%M %d,%Y');

ALTER TABLE nashville_housing_data
MODIFY COLUMN SaleDate DATE;

-- ------------------------------------------------------------------------------------------------------------------------------
-- POPULATE PROPERTY ADRESS DATA

SELECT * FROM nashville_housing_data;

-- GETTING DATA WHERE PROPERTY AADRESS IS BLANK - ""
SELECT ParcelID,PropertyAddress
FROM nashville_housing_data
WHERE PropertyAddress =  "";

-- UPDATING "" TO  NULL
UPDATE nashville_housing_data
SET PropertyAddress = NULL 
WHERE PropertyAddress =  "";

-- CHECKING IF UPDATE IS DONE
SELECT ParcelID,PropertyAddress
FROM nashville_housing_data
WHERE PropertyAddress IS NULL;

-- WE SEE WHEN ParcelID ARE SAME THE PROPERTY ADRESS COULD BE SAME, AND HENCE COULD BE POPULATED WITH THOSE VALUES
-- HENCE SELECTING ALL ParcelID WHERE PROPERTY ADRESS IS NULL FOR THOSE ParcelID.
SELECT * 
FROM nashville_housing_data
WHERE ParcelID IN (SELECT ParcelID
				   FROM nashville_housing_data
				   WHERE PropertyAddress IS NULL);


-- WITH SELF JOIN WE COULD GET DATA WHERE FOR PROPERTY ADRESS THAT ARE NULL AND WHERE , ParcelID ARE SAME AND UNIQUE ID ARE DIFFERENT.
SELECT A.UniqueID,A.ParcelID,A.PropertyAddress,B.UniqueID,B.ParcelID,B.PropertyAddress,
COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing_data A
JOIN nashville_housing_data B ON A.ParcelID = B.ParcelID AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;

-- UPDATING THE TABLE WITH THESE NEW VALUES.
UPDATE nashville_housing_data a
INNER JOIN nashville_housing_data b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- CHECKING TO SEE IF THE DATA IS UPDATED.
SELECT *  FROM nashville_housing_data
WHERE PropertyAddress IS NULL;

-- ------------------------------------------------------------------------------------------------------------------------------
-- BREAKING OUT PropertyAddress INTO INDIVIDUAL COLUMNS (ADRESS,CITY/STATE) - USING SUBSTRING METHOD.

SELECT PropertyAddress FROM nashville_housing_data;

-- GETTING ADRESS FROM PropertyAddress
SELECT SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1) FROM nashville_housing_data;

-- GETTING CITY FROM PropertyAddress
SELECT SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1) FROM nashville_housing_data;

-- ADDING NEW COLUMN FOR ADRESS - PropertySplitAdress, AND UPDATING RECORDS.
ALTER TABLE nashville_housing_data
ADD COLUMN PropertySplitAdress VARCHAR(100) AFTER PropertyAddress;

UPDATE nashville_housing_data
SET PropertySplitAdress = SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1);

-- ADDING NEW COLUMN FOR CITY - PropertySplitCity, AND UPDATING RECORDS.
ALTER TABLE nashville_housing_data
ADD COLUMN PropertySplitCity VARCHAR(100) AFTER PropertySplitAdress;

UPDATE nashville_housing_data
SET PropertySplitCity = SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1);

SELECT * FROM nashville_housing_data;

-- ------------------------------------------------------------------------------------------------------------------------------
-- BREAKING OUT OwnerAddress INTO INDIVIDUAL COLUMNS (ADRESS,CITY,STATE) - USING SUBSTRING_INDEX() METHOD.

SELECT OwnerAddress FROM nashville_housing_data;

-- TO GET THE ADDRESS FROM THE OWNERADDRESS.
SELECT SUBSTRING_INDEX(OwnerAddress,',',1) as ADDRESS
FROM nashville_housing_data;

-- TO GET CITY FROM OWNERADDRESS.
SELECT SUBSTRING_INDEX(OwnerAddress, ',', 2) as OwnerSplitAddress
FROM nashville_housing_data;

SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',',-1) as OwnerSplitCity
FROM nashville_housing_data;

-- TO GET STATE FROM OWNERADDRESS.
SELECT SUBSTRING_INDEX(OwnerAddress,',',-1) as ADDRESS
FROM nashville_housing_data;

-- ADDING NEW COLUMN FOR ADDRESS,CITY,STATE - OwnerSplitAddress,OwnerSplitCity,OwnerSplitState AND UPDATING RECORDS.
ALTER TABLE nashville_housing_data
ADD COLUMN OwnerSplitAddress VARCHAR(100) AFTER OwnerAddress;

ALTER TABLE nashville_housing_data
ADD COLUMN OwnerSplitCity VARCHAR(100) AFTER OwnerSplitAddress;

ALTER TABLE nashville_housing_data
ADD COLUMN OwnerSplitState VARCHAR(100) AFTER OwnerSplitCity;

UPDATE nashville_housing_data
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',',1);

UPDATE nashville_housing_data
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',',-1);

UPDATE nashville_housing_data
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress,',',-1);

-- Checking to see if Records are Updated Correctly
SELECT * FROM nashville_housing_data;

-- ------------------------------------------------------------------------------------------------------------------------------
-- CHANGING Y & N TO Yes & No in Sold and Vacant Field.

SELECT DISTINCT(SoldAsVacant)  FROM nashville_housing_data;

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) AS COUNT 
FROM nashville_housing_data
GROUP BY SoldAsVacant
ORDER BY COUNT;

-- WE SEE HERE WE HAVE , Y & N , WHICH ARE TO BE REPLACE BY Yes and No respectively.

UPDATE nashville_housing_data
SET SoldAsVacant = "Yes" WHERE SoldAsVacant = "Y";

UPDATE nashville_housing_data
SET SoldAsVacant = "No" WHERE SoldAsVacant = "N";

-- Checking for Changes 
SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) AS COUNT 
FROM nashville_housing_data
GROUP BY SoldAsVacant
ORDER BY COUNT;

-- ------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates.

-- GETTING THE NUMBER OF COLUMNS IN AN TABLE.

DESCRIBE nashville_housing_data;

-- WE HAVE 24 COLUMNS..
SELECT COUNT(*) 
FROM information_schema.columns 
WHERE table_name = 'nashville_housing_data';

-- GROUPING BY ALL COLUMNS TO CHECK IF EACH ROW IS UNIQUE.
SELECT *,count(*) AS COUNT
FROM nashville_housing_data
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
HAVING COUNT>1;
-- THIS SHOWS THAT EACH INDIVIDUAL ROW IS UNIQUE.


-- FURTHER DRILLING DOWN.
SELECT UniqueID,count(UniqueID) AS COUNT
FROM nashville_housing_data
GROUP BY UniqueID
HAVING COUNT>1;
-- THIS SHOWS THAT UNIQUE ID IS UNIQUE.

-- FURTHER DRILLING DOWN. KEEPING UNIQUEID OUT, WILL GROUP OTHER COLUMNS AND SEE IF THEY ARE ANY DIFFERENT.
-- THERE COULD BE POSSIBILITY THAT UNIQUEID COULD BE AUTO GENERATED AND SAME RECORDS COULD BE COPIED OVER AND OVER.
SELECT *,count(*) AS COUNT
FROM nashville_housing_data
GROUP BY 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
HAVING COUNT>1;
-- THERE ARE INSTANCES WHERE SAME RECORDS WITH DIFFERENT UNIQUEID ARE COPIED.

-- EXPLORING MORE..
WITH CTE AS (
			SELECT *,count(*) AS COUNT
			FROM nashville_housing_data
			GROUP BY 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
			HAVING COUNT>1)
SELECT UniqueID FROM CTE;

SELECT * 
FROM  nashville_housing_data 
WHERE UniqueID IN (WITH CTE AS (
								SELECT *,count(*) AS COUNT
								FROM nashville_housing_data
								GROUP BY 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
								HAVING COUNT>1)
		          SELECT UniqueID FROM CTE);

-- WE COULD OBSERVE THE DUPLICATES RECORDS HERE... 

-- SAME THING CAN BE DONE WITH ROW_NUMBWER WINDOWS FUNCTION..
-- WE PARTITION BY FEW IMPORTANT COLUMJNS AND ORDER BY UNIQUEID
WITH ROW_CTE AS (
				SELECT *,
				ROW_NUMBER() OVER( PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference 
								   ORDER BY UniqueID) AS RN
				FROM  nashville_housing_data)
SELECT * FROM ROW_CTE WHERE RN>1;
-- THESE ARE DUPLICATES NEED TO DELETE THEM.

-- DELETING DUPLICATE RECORDS.

DELETE 
FROM nashville_housing_data 
WHERE UniqueID IN(
					WITH ROW_CTE AS (
									SELECT *,
									ROW_NUMBER() OVER( PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference 
													   ORDER BY UniqueID) AS RN
									FROM  nashville_housing_data)
					SELECT UniqueID FROM ROW_CTE WHERE RN>1);

-- CHECKING TO SEE IF DUPLICATES STILL EXISTS..
WITH ROW_CTE AS (
				SELECT *,
				ROW_NUMBER() OVER( PARTITION BY ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference 
								   ORDER BY UniqueID) AS RN
				FROM  nashville_housing_data)
SELECT * FROM ROW_CTE WHERE RN>1;
-- SO, NO DUPLICATES FOUND...

-- ------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns.

SELECT * FROM nashville_housing_data;
-- COLUMNS LIKE -- PropertyAddress,OwnerAddress,TaxDistrict CAN BE REMOVED

ALTER TABLE nashville_housing_data
DROP COLUMN PropertyAddress,
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict;

SELECT * FROM nashville_housing_data;

-- UNUSED COLUMNS WERE REMOVED.