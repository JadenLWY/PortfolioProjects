select *
from [dbo].[NashvilleHousing];

-- Standardizing Date Format
select SaleDateConverted, convert(Date,SaleDate)
from [dbo].[NashvilleHousing]


Update [NashvilleHousing]
set SaleDate = convert(Date,SaleDate)

alter table [dbo].[NashvilleHousing]
add SaleDateConverted Date;

Update [NashvilleHousing]
set SaleDateConverted = convert(Date,SaleDate);


-- Populate Address data

select *
from [dbo].[NashvilleHousing]
-- where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into individual columns (address, city, state)

select PropertyAddress
from [dbo].[NashvilleHousing]
-- where PropertyAddress is null
-- order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from [dbo].[NashvilleHousing]

alter table [dbo].[NashvilleHousing]
add PropertySplitAddress Nvarchar(255);

Update [NashvilleHousing]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

alter table [dbo].[NashvilleHousing]
add PropertySplitCity Nvarchar(255);

Update [NashvilleHousing]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress));

select *
from [dbo].[NashvilleHousing]

-- Repeat for owner address using 'PARSENAME'

select OwnerAddress
from [dbo].[NashvilleHousing]


Select 
PARSENAME(Replace(OwnerAddress, ',','.'),3)
, PARSENAME(Replace(OwnerAddress, ',','.'),2)
, PARSENAME(Replace(OwnerAddress, ',','.'),1)
from [dbo].[NashvilleHousing]

alter table [dbo].[NashvilleHousing]
add OwnerSplitAddress Nvarchar(255);

Update [NashvilleHousing]
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3);

alter table [dbo].[NashvilleHousing]
add OwnerSplitCity Nvarchar(255);

Update [NashvilleHousing]
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),2);

alter table [dbo].[NashvilleHousing]
add OwnerSplitState Nvarchar(255);

Update [NashvilleHousing]
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),1);

select *
from [dbo].[NashvilleHousing]



-- Change Y and N to Yes and No in 'Sold as Vacant' Field

select DISTINCT(SoldAsVacant), count(SoldAsVacant)
from [dbo].[NashvilleHousing]
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
from [dbo].[NashvilleHousing]

Update [NashvilleHousing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END;


-- Remove Duplicates
WITH RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

from [dbo].[NashvilleHousing]
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
-- Order by PropertyAddress
-------------------------------------------------------------



-- Delete Unused Column

select *
from [dbo].[NashvilleHousing]

ALTER TABLE [NashvilleHousing]
drop column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [NashvilleHousing]
drop column SaleDate