--Cleaning Data in SQL Queries
select * from [HousingProject]..NashvilleHousing



-- Standardize Date Format
select saledate,convert(date,saledate)
from NashvilleHousing

update NashvilleHousing
set saledate=convert(date , saledate)

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted=convert(date,saledate)

select SaleDateConverted,convert(date,saledate)
from NashvilleHousing


-- Populate Property Address data

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,B.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
AND a.UniqueID<>b.UniqueID
Where a.PropertyAddress is NULL

Update a
Set PropertyAddress=ISNULL(a.PropertyAddress,B.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID=b.ParcelID
AND a.UniqueID<>b.UniqueID
Where a.PropertyAddress is NULL

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
--:) NO MORE NULL ADDRESS


-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM NashvilleHousing

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
       SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

SELECT [OwnerAddress]
FROM [HousingProject]..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [HousingProject]..NashvilleHousing

ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerAddressSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerAddressSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerAddressSplitCity NVARCHAR(255)

UPDATE [dbo].[NashvilleHousing]
SET OwnerAddressSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerAddressSplitState NVARCHAR(255)

UPDATE [dbo].[NashvilleHousing]
SET OwnerAddressSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
FROM [dbo].[NashvilleHousing]
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant,count(SoldAsVacant)
FROM [dbo].[NashvilleHousing]
Group By SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM [dbo].[NashvilleHousing]

UPDATE [dbo].[NashvilleHousing]
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM [dbo].[NashvilleHousing]

SELECT *
FROM [dbo].[NashvilleHousing]

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT * ,
ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								Order By 
								UniqueID) AS row_num
FROM [dbo].[NashvilleHousing]
)
--SELECT *
DELETE
FROM RowNumCTE 
WHERE row_num >1

-- Delete Unused Columns

ALTER TABLE [dbo].[NashvilleHousing]
DROP Column OwnerAddress,PropertyAddress,SaleDate,TaxDistrict

SELECT * 
FROM
[dbo].[NashvilleHousing]
