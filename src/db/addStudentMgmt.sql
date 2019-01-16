--addStudentMgmt.sql - Gradebook

--Sean Murthy, Andrew Figueroa, Jonathan Middleton
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU).
-- With contributions from Bruno DaSilva

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script creates functions related to students
-- the script should be run as part of application installation

START TRANSACTION;


--Suppress messages below WARNING level for the duration of this script
SET LOCAL client_min_messages TO WARNING;

--Set schema to reference in functions and tables, pg_temp is specified
-- last for security purposes
SET LOCAL search_path TO 'gradebook', 'pg_temp';


--Returns the ID for the row in the Student table where the row's schoolIssuedID
--attribute matches SESSION_USER. Returns NULL if no such record found.
CREATE OR REPLACE FUNCTION getMyStudentID() RETURNS INT AS
$$
   SELECT id FROM student WHERE schoolissuedid like SESSION_USER;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE;

ALTER FUNCTION getMyStudentID() OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getMyStudentID() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getMyStudentID() TO GB_Student;







--Function to get the course-section combos a student has attended in a
--  year-season combo
--For each matching section, returns course name and section number as well as
--  a string of the form "course-sectionNumber";
--This function is useful in showing Course-Section combinations directly
--  without having to first explicitly choose a course to get sections

CREATE OR REPLACE FUNCTION getStudentSections(studentID INT,
                                                year NUMERIC(4,0),
                                                seasonOrder NUMERIC(1,0)
                                               )
RETURNS TABLE(SectionID INT,
              Course VARCHAR(8),
              SectionNumber VARCHAR(3),
              CourseSection VARCHAR(12)
             )
AS
$$
   SELECT N.ID, N.Course, N.SectionNumber,
          N.Course || '-' || N.SectionNumber AS CourseSection
   FROM Enrollee E JOIN Section N ON E.section = N.id 
      JOIN Term T ON N.Term  = T.ID 
   WHERE $1 = E.Student
         AND T.Year = $2
         AND T.Season = $3
   ORDER BY CourseSection;
$$ LANGUAGE sql
   SECURITY DEFINER
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getStudentSections(studentID INT, year NUMERIC(4,0),
   seasonOrder NUMERIC(1,0)) OWNER TO gradebook;

REVOKE ALL ON FUNCTION getStudentSections(studentID INT,
   year NUMERIC(4,0), seasonOrder NUMERIC(1,0)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentSections(studentID INT,
   year NUMERIC(4,0), seasonOrder NUMERIC(1,0)) TO GB_Webapp,
   GB_Instructor, GB_Registrar, GB_RegistrarAdmin,
   GB_Admissions, GB_DBAdmin, GB_Student;


--function to get the section number(s) of a course a student has attended
CREATE OR REPLACE FUNCTION getStudentSections(studentID INT,
                                                year NUMERIC(4,0),
                                                seasonOrder NUMERIC(1,0),
                                                courseNumber VARCHAR(8)
                                               )
RETURNS TABLE(SectionID INT, SectionNumber VARCHAR(3))
AS
$$

   SELECT SectionID, SectionNumber
   FROM getStudentSections($1, $2, $3)
   WHERE Course ILIKE $4
   ORDER BY SectionNumber;

$$ LANGUAGE sql
   SECURITY DEFINER
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getStudentSections(studentID INT, year NUMERIC(4,0),
   seasonOrder NUMERIC(1,0), courseNumber VARCHAR(8)) OWNER TO gradebook;

REVOKE ALL ON FUNCTION getStudentSections(studentID INT, year NUMERIC(4,0),
   seasonOrder NUMERIC(1,0), courseNumber VARCHAR(8)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentSections(studentID INT, year NUMERIC(4,0),
   seasonOrder NUMERIC(1,0), courseNumber VARCHAR(8)) TO GB_Webapp,
   GB_Instructor, GB_Registrar, GB_RegistrarAdmin,
   GB_Admissions, GB_DBAdmin, GB_Student;


COMMIT;
