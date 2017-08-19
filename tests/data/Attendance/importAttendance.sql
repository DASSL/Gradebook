--importAttendance.sql - Gradebook

--Andrew Figueroa, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--Due to the use of the /COPY command, this script needs to be run using the psql
-- command line tool provided with most PostgreSQL installations.

--This script should be run after importing the Roster test data, but before any
-- humanization of student names occurs.

--The following three files must be in the same directory as this script:
-- 17S_CS110-05Attendance.csv
-- 17S_CS110-72Attendance.csv
-- 17S_CS110-74Attendance.csv


--Populate AttendanceStatus with necessary attendance codes
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


--Create temporary staging table
CREATE TABLE finalAttnStaging
(
   lName VARCHAR(50),
   fName VARCHAR(50),
   mName VARCHAR(50),
   date DATE,
   code CHAR(1)
);


--Define a temporary function for moving data from staging table to AttendanceRecord
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


--Import data from files to staging table and call importFunction for each section
\COPY finalAttnStaging FROM '17S_CS110-05Attendance.csv' WITH csv Header
SELECT importToAttnStatus(2017, 0, 'CS110', '05');
TRUNCATE finalAttnStaging;

\COPY finalAttnStaging FROM '17S_CS110-72Attendance.csv' WITH csv Header
SELECT importToAttnStatus(2017, 0, 'CS110', '72');
TRUNCATE finalAttnStaging;

\COPY finalAttnStaging FROM '17S_CS110-74Attendance.csv' WITH csv Header
SELECT importToAttnStatus(2017, 0, 'CS110', '74');


--Cleanup
DROP TABLE finalAttnStaging;
DROP FUNCTION importToAttnStatus(NUMERIC, NUMERIC, VARCHAR, VARCHAR);
