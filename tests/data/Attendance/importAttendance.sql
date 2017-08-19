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
INSERT INTO Gradebook.AttendanceStatus VALUES('P', 'Present')
ON CONFLICT DO NOTHING;
INSERT INTO Gradebook.AttendanceStatus VALUES('A', 'Absent')
ON CONFLICT DO NOTHING;
INSERT INTO Gradebook.AttendanceStatus VALUES('E', 'Explained')
ON CONFLICT DO NOTHING;
INSERT INTO Gradebook.AttendanceStatus VALUES('S', 'Stopped Attending')
ON CONFLICT DO NOTHING;
INSERT INTO Gradebook.AttendanceStatus VALUES('X', 'Excused')
ON CONFLICT DO NOTHING;
INSERT INTO Gradebook.AttendanceStatus VALUES('N', 'Not Registered')
ON CONFLICT DO NOTHING;
INSERT INTO Gradebook.AttendanceStatus VALUES('C', 'Cancelled')
ON CONFLICT DO NOTHING;


--Create temporary staging table
CREATE TABLE AttendanceStaging
(
   LName VARCHAR(50),
   FName VARCHAR(50),
   MName VARCHAR(50),
   Date DATE,
   Code CHAR(1)
);


--Define a temporary function for moving data from staging table to AttendanceRecord
CREATE OR REPLACE FUNCTION importToAttnStatus(
   Year NUMERIC(4,0), Season NUMERIC(1,0), Course VARCHAR(8), 
   SectionNumber VARCHAR(3)) 
   RETURNS VOID AS
$$
   INSERT INTO Gradebook.AttendanceRecord
   WITH SectionID AS
   (
      SELECT s.ID
      FROM Gradebook.Section s JOIN Gradebook.Term t ON s.Term = t.ID AND t.Year = $1 AND t.Season = $2
       AND s.Course = $3 AND s.SectionNumber = $4
   )
   SELECT stu.ID, sectionID.ID, a.Date, COALESCE(Code, 'P')
   FROM SectionID, AttendanceStaging a JOIN Gradebook.Student stu ON
        a.FName = stu.FName AND a.LName = stu.LName AND
	    (a.MName = stu.MName OR (a.MName IS NULL AND stu.MName IS NULL));
$$ LANGUAGE SQL;


--Import data from files to staging table and call import function for each section
\COPY FinalAttnStaging FROM '17S_CS110-05Attendance.csv' WITH csv HEADER
SELECT importToAttnStatus(2017, 0, 'CS110', '05');
TRUNCATE FinalAttnStaging;

\COPY FinalAttnStaging FROM '17S_CS110-72Attendance.csv' WITH csv HEADER
SELECT importToAttnStatus(2017, 0, 'CS110', '72');
TRUNCATE FinalAttnStaging;

\COPY FinalAttnStaging FROM '17S_CS110-74Attendance.csv' WITH csv HEADER
SELECT importToAttnStatus(2017, 0, 'CS110', '74');


--Cleanup
DROP TABLE FinalAttnStaging;
DROP FUNCTION importToAttnStatus(NUMERIC, NUMERIC, VARCHAR, VARCHAR);
