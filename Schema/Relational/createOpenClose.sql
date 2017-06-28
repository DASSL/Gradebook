DROP TABLE IF EXISTS openCloseImport;

CREATE TABLE openCloseImport
(
   Status VARCHAR(6),
   "Level" VARCHAR(2),
   CRN  VARCHAR(5),
   Subject VARCHAR(4),
   Course VARCHAR(6), 
   "Section" VARCHAR(3),
   Credits VARCHAR(15),
   Title VARCHAR(100),
   Days VARCHAR(7),
   "Time" VARCHAR(30),
   "Date" VARCHAR(15),
   Capacity INTEGER,
   Actual INTEGER,
   Remaining INTEGER,
   XL_Capacity INTEGER,
   XL_Actual INTEGER,
   XL_Remaining INTEGER,
   Location VARCHAR(25),
   Instructor VARCHAR(200)
);
