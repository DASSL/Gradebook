--importAttendance.sql - Gradebook

--Andrew Figueroa
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--Due to the use of the /COPY meta-command, this script needs to be run using the
-- psql command line tool provided with most PostgreSQL installations. The current 
-- working directory needs be the same as this script's location.

--This script should be run after importing the Roster test data, but before any
-- humanization of student names occurs.

--The following three files contain sample Attendance data that corresponds with
-- the sample Roster data provided in \tests\data\Roster. The files must be in 
-- the same directory as this script:
-- 2017SpringCS110-05Attendance.csv
-- 2017SpringCS110-72Attendance.csv
-- 2017SpringCS110-74Attendance.csv


--Populate AttendanceStatus with necessary attendance codes
INSERT INTO Gradebook.AttendanceStatus 
VALUES
   ('P', 'Present'),           ('A', 'Absent'),   ('E', 'Explained'),
   ('S', 'Stopped Attending'), ('X', 'Excused'),  ('N', 'Not Registered'),
   ('C', 'Cancelled'),         ('W', 'Withdrawn')
ON CONFLICT DO NOTHING;


--Create temporary staging table
DROP TABLE IF EXISTS pg_temp.AttendanceStaging;
CREATE TABLE pg_temp.AttendanceStaging
(
   LName VARCHAR(50),
   FName VARCHAR(50),
   MName VARCHAR(50),
   Date DATE,
   Code CHAR(1)
);


--Define a temporary function for moving data from staging table to AttendanceRecord
CREATE OR REPLACE FUNCTION pg_temp.importAttendance(
   Year NUMERIC(4,0), Season NUMERIC(1,0), Course VARCHAR(8), 
   SectionNumber VARCHAR(3)) 
   RETURNS VOID AS
$$
   --Match student from each entry in sample data with their corresponsing entry in 
   -- Student table by joining on a match of the 3 name parts. MName can be NULL.
   INSERT INTO Gradebook.AttendanceRecord
   WITH SectionID AS
   (
      SELECT s.ID
      FROM Gradebook.Section s JOIN Gradebook.Term t ON s.Term = t.ID AND t.Year = $1
       AND t.Season = $2 AND s.Course = $3 AND s.SectionNumber = $4
   )
   SELECT stu.ID, sectionID.ID, a.Date, a.Code
   FROM SectionID, pg_temp.AttendanceStaging a JOIN Gradebook.Student stu ON
        a.FName = stu.FName AND a.LName = stu.LName AND
        COALESCE(a.MName, '') = COALESCE(stu.MName, '')
   WHERE a.Code IS NOT NULL
   ON CONFLICT DO NOTHING;
$$ LANGUAGE SQL;


--Import data from files to staging table and call import function for each section
\COPY pg_temp.AttendanceStaging FROM '2017SpringCS110-05Attendance.csv' WITH csv HEADER
SELECT pg_temp.importAttendance(2017, 0, 'CS110', '05');
TRUNCATE pg_temp.AttendanceStaging;

\COPY pg_temp.AttendanceStaging FROM '2017SpringCS110-72Attendance.csv' WITH csv HEADER
SELECT pg_temp.importAttendance(2017, 0, 'CS110', '72');
TRUNCATE pg_temp.AttendanceStaging;

\COPY pg_temp.AttendanceStaging FROM '2017SpringCS110-74Attendance.csv' WITH csv HEADER
SELECT pg_temp.importAttendance(2017, 0, 'CS110', '74');
TRUNCATE pg_temp.AttendanceStaging;
