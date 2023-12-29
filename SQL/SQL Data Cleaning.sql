/*

Cleaning Data

*/


Select *
From PortfolioProject.dbo.HousingData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select St_dSaleDate, CONVERT(date,SaleDate)
From PortfolioProject.dbo.HousingData
ORDER BY SaleDate 

UPDATE HousingData
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE HousingData
ADD St_dSaleDate Date

UPDATE HousingData
SET St_dSaleDate = CONVERT(date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data, in the data set there are PropertyAddresses that are NULL,
--there are also repeated ParcelIDs that have the same PropertyAddresses. Thuse we can populate those NULL 
--PropertyAddresses with those of equal ParcelID.



Select *
From PortfolioProject.dbo.HousingData
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


Select a.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL	



--------------------------------------------------------------------------------------------------------------------------

-- Splitting the address colum


Select PropertyAddress
From PortfolioProject.dbo.HousingData
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

--It is to show the position of comma in the PropertyAddress
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address, CHARINDEX(',', PropertyAddress)

From PortfolioProject.dbo.HousingData

--Knowing thhis we can write the code as follows to remove the comma, which means we are going to comma and then go back one behind the comma
--and then by adding (+1) we are removing the comma from beang appeared at the before City name.
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
From PortfolioProject.dbo.HousingData


ALTER TABLE HousingData
ADD PropertySplitAddress NVARCHAR(255);

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE HousingData
ADD PropertySplitCity NVARCHAR(255);

UPDATE HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



--Another way to split address column into(Address, City , State) is to parse our column, the
--since using parse shows new column in backward form it is better to start with 3,2,1 

SELECT OwnerAddress
From PortfolioProject.dbo.HousingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.HousingData


ALTER TABLE HousingData
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE HousingData
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE HousingData
ADD OwnerSplitState NVARCHAR(255);


UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------

-- Uniforming all data in a column (Y to Yes)


Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.HousingData

UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	                    END






