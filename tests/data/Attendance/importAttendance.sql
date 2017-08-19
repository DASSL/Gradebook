-- importAttendance.sql

-- Andrew Figueroa, Sean Murthy

-- CC 4.0 BY-NC-SA
-- https://creativecommons.org/licenses/by-nc-sa/4.0/

-- Copyright (c) 2017- DASSL. ALL RIGHTS RESERVED.

-- ALL ARTIFACTS PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--The following three files must be in the same directory as this script:
-- 17S_CS110-05Attendance.csv
-- 17S_CS110-72Attendance.csv
-- 17S_CS110-74Attendance.csv

--The Enrollee table must be populated with the students from all three sections

INSERT INTO gradebook.attendanceStatus VALUES('P', 'Present')
ON CONFLICT DO NOTHING;
INSERT INTO gradebook.attendanceStatus VALUES('A', 'Absent')
ON CONFLICT DO NOTHING;
INSERT INTO gradebook.attendanceStatus VALUES('E', 'Explained')
ON CONFLICT DO NOTHING;
INSERT INTO gradebook.attendanceStatus VALUES('S', 'Stopped Attending')
ON CONFLICT DO NOTHING;
INSERT INTO gradebook.attendanceStatus VALUES('X', 'Excused')
ON CONFLICT DO NOTHING;
INSERT INTO gradebook.attendanceStatus VALUES('N', 'Not Registered')
ON CONFLICT DO NOTHING;
INSERT INTO gradebook.attendanceStatus VALUES('C', 'Cancelled')
ON CONFLICT DO NOTHING;


CREATE TABLE finalAttnStaging
(
   lName VARCHAR(50),
   fName VARCHAR(50),
   mName VARCHAR(50),
   date DATE,
   code CHAR(1)
);


CREATE OR REPLACE FUNCTION importToAttnStatus(
   Year NUMERIC(4,0), Season NUMERIC(1,0), Course VARCHAR(8), 
   SectionNumber VARCHAR(3)) 
   RETURNS VOID AS
$$
   INSERT INTO gradebook.attendanceRecord
   WITH sectionID AS
   (
      SELECT s.id
      FROM gradebook.Section s JOIN gradebook.Term t ON s.term = t.id AND t.Year = $1 AND t.Season = $2
       AND course = $3 AND sectionNumber = $4
   )
   SELECT stu.ID, sectionID.id, f.Date, COALESCE(code, 'P')
   FROM SectionID, finalAttnStaging f JOIN gradebook.Student stu ON
        f.fName = stu.fname AND f.lName = stu.lName AND
	    (f.mName = stu.mName OR (f.mName IS NULL AND stu.mName IS NULL));
$$ LANGUAGE SQL;

 
\COPY finalAttnStaging FROM '17S_CS110-05Attendance.csv' WITH csv Header
SELECT importToAttnStatus(2017, 0, 'CS110', '05');
TRUNCATE finalAttnStaging;

\COPY finalAttnStaging FROM '17S_CS110-72Attendance.csv' WITH csv Header
SELECT importToAttnStatus(2017, 0, 'CS110', '72');
TRUNCATE finalAttnStaging;

\COPY finalAttnStaging FROM '17S_CS110-74Attendance.csv' WITH csv Header
SELECT importToAttnStatus(2017, 0, 'CS110', '74');
DROP TABLE finalAttnStaging;
DROP FUNCTION importToAttnStatus(NUMERIC, NUMERIC, VARCHAR, VARCHAR);
