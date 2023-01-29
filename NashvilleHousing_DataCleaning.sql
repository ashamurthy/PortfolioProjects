--CLEANING DATA IN SQL QUERY
SELECT * FROM PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------
--STANDARDIZE DATE FORMAT
--Saledate column is formatted as date time
select SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

select SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------
--POULATE PROPERTY ADDRESS DATA
select *
FROM PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
Order by ParcelID

--property address shouldn't be null. Noticed that someof them had null values.
--Diagnose: Property address = parcel id. Where there is null
--pick the property address from the parcel id with adress.
--Achieved this by self join.
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--This fixed the null values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------
--BREAKING OUT ADDRESS INTO INVIDUAL CLUMNS (Address, City, State)
--
select PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

select
--looks for first coma in the PropertyAddress and -1 removes coma in the address
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)
as Address,
---+1 skips coma and prints only city name in the city column
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
as City
FROM PortfolioProject.dbo.NashvilleHousing

--THIS WILL ADD NEW COLUMNS TO THE TABLE WITH SPLIT ADDRESS AND CITY:
ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

SELECT * FROM 
PortfolioProject.dbo.NashvilleHousing

--SPLITTING ADDRESS,CITY AND STATE USING 'PARSE'

Select OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing
 
select
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

---------------------------------------------------------------------------------
-- CHANGE Y and N to to YES and NO in "Sold as vacant" field
--Problem: table has soldasvacant column with 4 distinct yes and no value
--It has y-52, N-399,yes-4623, No-51403

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order BY 2

Select SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

------------------------------------------------------------------
--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
           PropertyAddress,
		   SalePrice,
		   SaleDate,
		   LegalReference
		   ORDER BY
		   UniqueID
		   ) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
Delete 
FROM RowNumCTE
WHERE row_num > 1
---------------------------------------------------------------------------------------------
--Delete Unused columns:

SELECT * FROM 
PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate