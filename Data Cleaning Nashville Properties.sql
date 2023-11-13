SELECT * 
FROM PortfolioProjects..NashvilleProperties

------- Adding new formatted Date Column --------
SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProjects..NashvilleProperties

ALTER TABLE NashvilleProperties
ADD SaleDateConverted DATE;

UPDATE NashvilleProperties
SET SaleDateConverted = CONVERT(DATE, SaleDate)


------- Checking if new column is added and formatted -------
SELECT SaleDateConverted
FROM PortfolioProjects..NashvilleProperties


------- Populating Null Values in PropertAddress column (by executing a self-join) -------
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects..NashvilleProperties a
JOIN PortfolioProjects..NashvilleProperties b
	on a.PARCELID = b.PARCELID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Updateing the Property Address column
UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjects..NashvilleProperties a
JOIN PortfolioProjects..NashvilleProperties b
	on a.PARCELID = b.PARCELID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


------- Seperating Address field into (Address, City, State) --------

SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as Address1
FROM PortfolioProjects..NashvilleProperties

ALTER TABLE NashvilleProperties
ADD PropertyAddressSplit Nvarchar(255);

UPDATE NashvilleProperties
SET PropertyAddressSplit = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleProperties
ADD PropertyCitySplit Nvarchar(255);

UPDATE NashvilleProperties
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

-- Splitting Owner Address 

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProjects..NashvilleProperties

ALTER TABLE NashvilleProperties
ADD OwnerAddressSplit Nvarchar(255);

UPDATE NashvilleProperties
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleProperties
ADD OwnerCitySplit Nvarchar(255);

UPDATE NashvilleProperties
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleProperties
ADD OwnerStateSplit Nvarchar(255);

UPDATE NashvilleProperties
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


------- Changing Y and N values in SoldasVacant to Yes and no -------
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjects..NashvilleProperties
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProjects..NashvilleProperties

UPDATE NashvilleProperties
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END


-------- Removing Duplicates (This is for demonstration. Best practice is to remove duplicates from a copy of the dataset and not the raw data ---------

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
				  PARTITION BY ParcelID,
							   PropertyAddress,
							   SalePrice,
							   SaleDate,
							   LegalReference
				  ORDER BY UniqueID) row_num
FROM PortfolioProjects..NashvilleProperties)

DELETE
FROM RowNumCTE
Where row_num > 1
-- This deleted 104 rows of duplicates


-------- Deleting unused columns ---------

SELECT *
FROM PortfolioProjects..NashvilleProperties

ALTER TABLE PortfolioProjects..NashvilleProperties
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate