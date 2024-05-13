

 --Format Date Column


ALTER TABLE Housing
Add SaleDateClean Date;

Update Housing
SET SaleDateClean = CONVERT(Date,SaleDate)


--Populate Property Adress Data:


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Housing a
JOIN Housing b on a.ParcelID=b.ParcelID and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Housing a
JOIN Housing b 
	on a.ParcelID=b.ParcelID 
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


--Parsing Address columns (Address, City, State)


ALTER TABLE Housing
Add PropertySplitAddress Nvarchar(255)
Add PropertySplitCity Nvarchar(255)


Update Housing
SET PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',',PropertyAddress)-1)

Update Housing
SET PropertySplitCity = Substring(PropertyAddress, Charindex(',',PropertyAddress)+1, LEN(PropertyAddress))


ALTER TABLE Housing
Add SplitOwnerAddress Nvarchar(255)
ALTER TABLE Housing
Add SplitOwnerCity Nvarchar(255)
ALTER TABLE Housing
Add SplitOwnerState Nvarchar(255)


Update Housing
SET SplitOwnerAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Update Housing
SET SplitOwnerCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Update Housing
SET SplitOwnerState = PARSENAME(Replace(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No in the 'Sold as Vacant' Field


Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant end SoldAsVacantFixed
from Housing


Update Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant end


--Remove Duplicates


with cte as(Select *, 
	row_number() over (
	partition by ParcelID, PropertyAddress, SalePrice, Saledate, Legalreference
	order by ParcelID) rownum
from Housing)

DELETE 
from cte
where rownum>1


--Delete Unused Columns


Alter table Housing
drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate


--Clean Up Column Names


EXEC sp_rename 'Housing.PropertySplitCity', 'PropertyCity', 'Column'
EXEC sp_rename 'Housing.PropertySplitAddress', 'PropertyAddress', 'Column'
EXEC sp_rename 'Housing.SplitOwnerAddress', 'OwnerAddress', 'Column'
EXEC sp_rename 'Housing.SplitOwnerCity', 'OwnerCity', 'Column'
EXEC sp_rename 'Housing.SplitOwnerstate', 'OwnerState', 'Column'
EXEC sp_rename 'Housing.SaleDateClean', 'SaleDate', 'Column'


