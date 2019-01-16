--prepareRosterImport.sql - Gradebook

--Kyle Bella, Andrew Figueroa, Zaid Bhujwala, Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--This script is part of the procedure to import roster from a CSV file
-- it creates some temporary objects (a table and a function) needed for import
-- it should be run before copying the CSV data to the staging table

--The script addSectionMgmt.sql should have been run before running this script

--Set schema to reference in functions and tables, pg_temp is specified
-- last for security purposes
SET LOCAL search_path TO 'gradebook', 'pg_temp';

--A temporary staging table for a roster
-- table schema is compatible with the CSV roster file generated by the Banner
-- system at WCSU: the directory /tests/data/Roster includes some sample rosters
CREATE TEMPORARY TABLE IF NOT EXISTS RosterStaging
(
   LName VARCHAR(50),
   FName VARCHAR(50),
   MName VARCHAR(50),
   ID VARCHAR(50),
   RegStatus VARCHAR(50),
   Level VARCHAR(30),
   Degree VARCHAR(50),
   Program VARCHAR(50),
   Major VARCHAR(50),
   Class VARCHAR(25),
   Credits INT,
   Email VARCHAR(319)
);

--Creates student ids that match the scheme: namepart00000
--Name part is an all lowercase version of a student's name part, last
-- name (lname) is used first, and falls back to mName than fName if the name
-- part is null or an empty string
--00000 represents a sequence of numbers, which increments based on previously
-- assigned IDs (scans table rather than maintaining a counter)
CREATE OR REPLACE FUNCTION pg_temp.generateStudentIssuedID(fName TEXT,
   mName TEXT, lName TEXT) RETURNS VARCHAR(50) AS
$$
BEGIN
   IF $3 IS NOT NULL OR TRIM($3) <> '' THEN
      RETURN (
         SELECT LOWER(makeValidIssuedID($3)) || LPAD(COUNT(*)::VARCHAR, 5, '0')
         FROM Student S WHERE S.SchoolIssuedID ILIKE makeValidIssuedID($3) || '%');
   ELSIF $2 IS NOT NULL OR TRIM($2) <> '' THEN
      RETURN (
         SELECT LOWER(makeValidIssuedID(2)) || LPAD(COUNT(*)::VARCHAR, 5, '0')
         FROM Student S WHERE S.SchoolIssuedID ILIKE makeValidIssuedID($2) || '%');
   ELSIF $1 IS NOT NULL OR TRIM($1) <> '' THEN
      RETURN (
         SELECT LOWER(makeValidIssuedID($1)) || LPAD(COUNT(*)::VARCHAR, 5, '0')
         FROM Student S WHERE S.SchoolIssuedID ILIKE makeValidIssuedID($1) || '%');
   ELSE
      RETURN (
         SELECT "student" || LPAD(COUNT(*)::VARCHAR, 5, '0')
         FROM Student S WHERE S.SchoolIssuedID ILIKE 'student%');
   END IF;
END;
$$ LANGUAGE plpgsql;


--Function to import a roster currently in the rosterStaging table
--param seasonIdentification is a season order, code, or name
-- see function getSeasonOrder(VARCHAR(20))
CREATE OR REPLACE FUNCTION pg_temp.importRoster(year INT,
                                                seasonIdentification VARCHAR(20),
                                                course VARCHAR(8),
                                                sectionNumber VARCHAR(3),
                                                enrollmentDate DATE DEFAULT NULL
                                               )
RETURNS VOID AS
$$

   --add students: if a student already exists, update selected fields
   -- assumes rosters are imported in chronological order so that updating
   -- info of an existing student reflects the most recent info for that student
   INSERT INTO Student(FName, MName, LName, SchoolIssuedID, Email, Year)
   SELECT r.FName, r.MName, r.LName,
      pg_temp.generateStudentIssuedID(r.FName, r.MName, r.LName), r.Email, r.Class
   FROM pg_temp.RosterStaging r;
   /* Commented out, but still need to find an alternative to address the
   duplicate student problem.
   ON CONFLICT (Email)
      DO UPDATE SET
         FName = EXCLUDED.FName, MName = EXCLUDED.MName,
         LName = EXCLUDED.LName, SchoolIssuedID = EXCLUDED.SchoolIssuedID,
         Email = EXCLUDED.Email, Year = EXCLUDED.Year;
   */

   --determine info that is fixed for all enrollments in this import batch
   -- Section ID is fixed based on first four params
   -- Effective enrollment date is NULL if param enrollmentDate is NULL or
   -- is earlier than section start date
   WITH FixedEnrollmentInfo(SectionID, StartDate) AS
   (
      SELECT ID, (CASE WHEN $5 > N.StartDate THEN $5 ELSE NULL END)
      FROM getSection($1, $2, $3, $4) N
   )
   --record students as enrollees in the section: ignore conflicts
   INSERT INTO Enrollee(Student, Section, DateEnrolled, YearEnrolled,
                                  MajorEnrolled
                                 )
      SELECT S.ID, f.SectionID, f.StartDate, r.Class, r.Major
      FROM FixedEnrollmentInfo f,
           pg_temp.RosterStaging r
           JOIN Student S ON r.email = S.email
      ON CONFLICT DO NOTHING;

$$ LANGUAGE SQL;
