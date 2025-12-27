/* 
FERID GURBANOV

Cleaning Data in SQL Queries

*/

-- Populate Property Address Data

select propertyaddress from port_project 
--where propertyaddress is null
order by parcelid

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, coalesce(a.propertyaddress, b.propertyaddress) 
from port_project a
join port_project b on a.parcelid=b.parcelid 
and a.uniqueid_ <> b.uniqueid_
where a.propertyaddress is null

update port_project a
set propertyaddress = (select max(b.propertyaddress)
    from port_project b
    where a.parcelid = b.parcelid
      and b.propertyaddress is not null)
where a.propertyaddress is null

--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City , State)

select propertyaddress from port_project
select  substr(propertyaddress, 1, instr(propertyaddress, ',' )-1) as Address ,
substr(propertyaddress, instr(propertyaddress, ',')+1) as Address2 from port_project

alter table port_project
add propertysplitaddress varchar2(255)

update port_project
set propertysplitaddress = substr(propertyaddress, 1, instr(propertyaddress, ',' )-1)

alter table port_project
add propertysplitcity varchar2(255)

update port_project
set propertysplitcity = substr(propertyaddress, instr(propertyaddress, ',')+1)

select owneraddress, substr(owneraddress, 1, instr(owneraddress, ',' )-1),
substr(owneraddress, instr(owneraddress, ',')+1, instr(owneraddress, ',',1,2)-instr(owneraddress,',')-1),
substr(owneraddress, -2)
from port_project

alter table port_project
add ownersplitaddress varchar2(255)

update port_project
set ownersplitaddress = substr(owneraddress, 1, instr(owneraddress, ',' )-1)

alter table port_project
add ownersplitcity varchar2(255)

update port_project
set ownersplitcity = substr(owneraddress, instr(owneraddress, ',')+1, instr(owneraddress, ',',1,2)-instr(owneraddress,',')-1)

alter table port_project
add ownersplitstate varchar2(255)

update port_project
set ownersplitstate = substr(owneraddress, -2)

select * from port_project

-----------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldasVacant"

select soldasvacant, 
case
when soldasvacant = 'N' then 'No'
when soldasvacant = 'Y' then 'Yes'
else soldasvacant
end 
from port_project

update port_project
set soldasvacant = case
when soldasvacant = 'N' then 'No'
when soldasvacant = 'Y' then 'Yes'
else soldasvacant
end 

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Dublicates

DELETE FROM port_project
WHERE uniqueid_ IN ( select uniqueid_ from (
select uniqueid_, row_number() over (partition by parcelid,
                                       propertyaddress,
                                       saleprice,
                                       saledate,
                                       legalreference order by uniqueid_) as row_num 

from port_project 
--order by parcelid 
)
 WHERE row_num > 1)
 
----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

--select * from port_project

alter table port_project
drop column owneraddress 

alter table port_project
drop column taxdistrict

alter table port_project
drop column propertyaddress

---------------------------------------------------------------------------------------------------------------------------------------

-- Replace NULL with Unknown and 0

update port_project
set ownername = 'Unknown', acreage = 0,
landvalue = 0, buildingvalue = 0, totalvalue = 0,
yearbuilt = 0, fullbath = 0, halfbath = 0, bedrooms = 0, ownersplitaddress = 'Unknown', 
ownersplitstate = 'Unknown', ownersplitcity = 'Unknown'
where ownername is null or acreage is null or landvalue is null or 
buildingvalue is null or totalvalue is null or yearbuilt is null or
fullbath is null or ownersplitaddress is null or ownersplitstate is null or halfbath is null or
bedrooms is null or ownersplitcity is null

select * from port_project