

-- Cleaning Data in SQL Queries


-------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

UPDATE project.nashville_housing
SET 
    SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');
   
/*

UPDATE project.nashville_housing
SET 
    SaleDate = convert(Date, SaleDate); 

*/


    
----------------------------------------------------------------------------------------------------------------------------------

-- Populate Prorerty Address data
   
UPDATE project.nashville_housing 
SET 
    PropertyAddress = IF(PropertyAddress = '',
        NULL,
        PropertyAddress);    
    
SELECT 
    *
FROM
    project.nashville_housing
WHERE
    PropertyAddress IS NULL;   
    
    
SELECT 
    a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM
    project.nashville_housing a
        JOIN
    project.nashville_housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
WHERE
    a.PropertyAddress IS NULL;   
    
    
UPDATE project.nashville_housing a
        JOIN
    project.nashville_housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID 
SET 
    a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;      
    
    
    
    
----------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)    
  
  
SELECT 
    SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1,
        LENGTH(PropertyAddress)) AS City
FROM
    project.nashville_housing;
    
    
    
alter table project.nashville_housing
add PropertySplitAddress varchar(200);

UPDATE project.nashville_housing 
SET 
    PropertySplitAddress = SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1);


alter table project.nashville_housing
add PropertySplitCity varchar(200);
    
UPDATE project.nashville_housing 
SET 
    PropertySplitCity = SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1,
        LENGTH(PropertyAddress));    
        



SELECT 
    OwnerAddress
FROM
    project.nashville_housing;   
    
SELECT 
    SUBSTR(OwnerAddress,
        1,
        INSTR(OwnerAddress, ',') - 1) AS Address,
    SUBSTR(OwnerAddress,
        INSTR(OwnerAddress, ',') + 1,
        LENGTH(OwnerAddress) - INSTR(OwnerAddress, ',') - INSTR(REVERSE(OwnerAddress), ',')) AS City,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3),
            ',',
            - 1) AS State
FROM
    project.nashville_housing;


alter table project.nashville_housing
add OwnerSplitAddress varchar(200);

UPDATE project.nashville_housing 
SET 
    OwnerSplitAddress = SUBSTR(OwnerAddress,
        1,
        INSTR(OwnerAddress, ',') - 1);


alter table project.nashville_housing
add OwnerSplitCity varchar(200);
    
UPDATE project.nashville_housing 
SET 
    OwnerSplitCity = SUBSTR(OwnerAddress,
        INSTR(OwnerAddress, ',') + 1,
        LENGTH(OwnerAddress) - INSTR(OwnerAddress, ',') - INSTR(REVERSE(OwnerAddress), ','));    

alter table project.nashville_housing
add OwnerSplitState varchar(200);
    
UPDATE project.nashville_housing 
SET 
    OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3),
            ',',
            - 1);  



------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT
    SoldAsVacant, COUNT(SoldAsVacant)
FROM
    project.nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2; 

SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM
    project.nashville_housing; 
    
UPDATE project.nashville_housing 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;
    
-------------------------------------------------------------------------------------------------------------------    
    
-- Remove Duplicates   

   
DELETE FROM project.nashville_housing
WHERE (ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference) 
IN 
(
    SELECT ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
    FROM 
    (
        SELECT ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference,
            ROW_NUMBER() OVER(
                PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference 
                ORDER BY UniqueID) row_num
        FROM project.nashville_housing
    ) t
    WHERE row_num > 1
);


SELECT *
    FROM 
    (
        SELECT ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference,
            ROW_NUMBER() OVER(
                PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference 
                ORDER BY UniqueID) row_num
        FROM project.nashville_housing
    ) t
    WHERE row_num > 1;


---------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE `project`.`nashville_housing` 
DROP COLUMN `TaxDistrict`,
DROP COLUMN `OwnerAddress`,
DROP COLUMN `PropertyAddress`;

SELECT 
    *
FROM
    project.nashville_housing; 



