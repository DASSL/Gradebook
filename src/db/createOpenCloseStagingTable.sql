--createOpenCloseStagingTable.sql - Gradebook

--Kyle Bella, Zach Boylan, Zaid Bhujwala, Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script creates a temporary staging table to import OpenClose database
-- the table is used to stage data from CSV file as part of the import process

--This script should be the first to run when importing OpenClose data
-- there should be no need to run this script separately, because it is
-- incorporated into the import process batch file importOpenCloseCSV.bat

CREATE TEMPORARY TABLE openCloseStaging
(
   Status VARCHAR(6),
   Level VARCHAR(2),
   CRN  VARCHAR(5),
   Subject VARCHAR(4),
   Course VARCHAR(6),
   Section VARCHAR(3),
   Credits VARCHAR(15),
   Title VARCHAR(100),
   Days VARCHAR(7),
   Time VARCHAR(30),
   Date VARCHAR(15),
   Capacity INTEGER,
   Actual INTEGER,
   Remaining INTEGER,
   XL_Capacity INTEGER,
   XL_Actual INTEGER,
   XL_Remaining INTEGER,
   Location VARCHAR(25),
   Instructor VARCHAR(200)
);
