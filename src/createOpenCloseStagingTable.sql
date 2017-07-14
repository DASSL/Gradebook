--createOpenCloseStagingTable.sql - GradeBook

--Kyle Bella, Zach Boylan, Zaid Bhujwala, Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC: https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--Creating temporary table for openCloseStaging. Table will be used to copy from CSV files and later to be
--used to populate the database. 

CREATE TEMPORARY TABLE gradebook.openCloseStaging
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
