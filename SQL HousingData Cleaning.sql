SELECT * FROM Housingdata



/* Populate Property Address Data*/
/* Since some columns in parcelID are repeated, in these cases the address is exactly the same. So, we want to populate the Property 
Address that has same ParcelID (in cases where PropertyAddress is same). What we will do is : If ParcelID A = ParcelID B, then, 
PropertyAddress A= PropertyAddress B.*/
Select *
From HousingData
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, 
a.PropertyAddress, 
b.ParcelID, 
b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)   /* It means If a.PropertyAddress is null , then populate it with b.PropertAddress*/

From HousingData a
Join HousingData b

on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]

Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingData a
JOIN HousingData b
on a.ParcelID = b.ParcelID
AND a.[UniqueiD] <> b.[UniqueID]
Where a.PropertyAddress is null


/*Breaking Adress into individual Columns (Address, City, State)*/


Select PropertyAddress
From HousingData
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,     /*Looking at the property Address, starting at first value,going till ','*/ /*CHARINDEX GIVES US A POSITION*/
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address /*Start just after ',' and end till length of propertyaddress*/
From HousingData

ALTER TABLE HousingData
Add PropertySplitAddress Nvarchar(255);

Update HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE HousingData
Add PropertySplitCity Nvarchar(255);

Update HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT * FROM HousingData

/* Using PARSENAME to split owner address, basically another way to split address*/


SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) ,   /* Replace owners address ',' with'.' as PARSENAME looks for '.' */ /* Also, PARSENAME looks from BAckwords*/
PARSENAME(REPLACE(OwnerAddress,',','.'),2),     
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM HousingData


ALTER TABLE HousingData
Add OwnerSplitAddress Nvarchar(255);

Update HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE HousingData
Add OwnerSplitCity Nvarchar(255);

Update HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE HousingData
Add OwnerSplitState Nvarchar(255);

Update HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


/* Change 1 and 0 to Yes and No in SOLD AS VACANT */




Select SoldAsVacant,
CASE When SoldAsVacant = '1' THEN 'Yes'
     When SoldAsVacant = '0' THEN 'No'
	 END
From Housingdata



ALTER TABLE HousingData
ALTER COLUMN SoldAsVacant varchar(3)

Update HousingData
SET SoldAsVacant = CASE When SoldAsVacant = '1' THEN 'Yes'
     When SoldAsVacant = '0' THEN 'No'
	 END
     
/*Remove Duplicates*/   /* Usually, standard practice: we dont delete data*/

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From HousingData
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



/*Delete some unused columns that we don't care about*/ /*Don't do this to raw data*/

Select * From HousingData

Alter Table HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter Table HousingData
DROP COLUMN SaleDate





