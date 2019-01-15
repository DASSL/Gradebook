--addStudentMgmt.sql - Gradebook

--Edited by Bruno DaSilva, Andrew Figueroa, and Jonathan Middleton (Team Alpha)
-- in support of CS305 coursework at Western Connecticut State University.

--Licensed to others under CC 4.0 BY-SA-NC
 
--This work is a derivative of Gradebook, originally developed by:

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

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
SET LOCAL search_path TO 'alpha', 'pg_temp';


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

GRANT EXECUTE ON FUNCTION getMyStudentID() TO alpha_GB_Student;


--Given Gradebook's identifier for a student, returns a table listing the years
--in which the student has been enrolled in a section. Returns 0 rows if student
--has not been enrolled in a section, or if studentID does not match a valid
--student.
CREATE OR REPLACE FUNCTION getStudentYears(studentID INT)
   RETURNS TABLE(Year NUMERIC(4,0)) AS
$$
   SELECT DISTINCT T.Year
   FROM Term T JOIN Section S ON T.ID = S.Term
      JOIN Enrollee E ON S.ID = E.Section
   WHERE E.Student = $1
   ORDER BY T.Year DESC;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getStudentYears(studentID INT) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getStudentYears(studentID INT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentYears(studentID INT) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Registrar, alpha_GB_RegistrarAdmin,
   alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns a table listing the years in which the student specified by
--SESSION_USER has been enrolled in at least one section. Returns 0 rows if
--student has not been enrolled in any sections, or NULL if the SESSION_USER is
--not a student.
CREATE OR REPLACE FUNCTION getYearsAsStudent()
   RETURNS TABLE(Year NUMERIC(4,0)) AS
$$
   SELECT getStudentYears(getMyStudentID());
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE;

ALTER FUNCTION getYearsAsStudent() OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getYearsAsStudent() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getYearsAsStudent() TO alpha_GB_Student;


--Given Gradebook's identifier for a student and a year, returns a table listing
--the seasons in the given year that the student has been enrolled in a section.
--Returns 0 rows if the student was not enrolled in any section in the given
--year or if studentID does not match a valid student.
CREATE OR REPLACE FUNCTION getStudentSeasons(studentID INT,
                                             year NUMERIC(4,0)
                                            )
   RETURNS TABLE(SeasonOrder Numeric(1,0),
               SeasonName VARCHAR(20)
               ) AS
$$
   SELECT DISTINCT S."Order", S.Name
   FROM Season S JOIN Term T ON S."Order" = T.Season
      JOIN Section C ON T.ID = C.Term
      JOIN Enrollee E ON C.ID = E.Section
   WHERE E.Student = $1 AND T.Year = $2
   ORDER BY S."Order" ASC;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getStudentSeasons(studentID INT,
                                 year NUMERIC(4,0)
                                )
   OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getStudentSeasons(studentID INT, year NUMERIC(4,0))
   FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentSeasons(studentID INT, year NUMERIC(4,0))
TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Registrar, 
alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Adds a student to the student table and creates database role for new student
--with schoolIssuedID as the role name and password. At least one of fName,
--mName, or lName must be provided. schoolIssuedID should be unique among
--students and instructors combined. Raises exception if schoolIssuedID or email
--are not unique among instructors and students.
CREATE OR REPLACE FUNCTION addStudent(fName VARCHAR(50),
                                      mName VARCHAR(50),
                                      lName VARCHAR(50),
                                      schoolIssuedID VARCHAR(50),
                                      email VARCHAR(319),
                                      year VARCHAR(30)
                                     )
   RETURNS VOID AS
$$
BEGIN
   --May eventually integrate checks with helper functions
   IF EXISTS (SELECT * FROM Student S WHERE S.schoolIssuedID = $4) THEN
      RAISE EXCEPTION 'SchoolIssuedID ''%'' is already assigned to a student', $4;
   ELSIF EXISTS (SELECT * FROM Instructor I WHERE I.schoolIssuedID = $4) THEN
      RAISE EXCEPTION 'SchoolIssuedID ''%'' is already assigned to an instructor', $4;
   END IF;

   --Server role name will be set to schoolIssuedID, so an existing role name
   -- should not match schoolIssuedID. ILIKE is used to ignore case sensitivity
   IF EXISTS (SELECT * FROM pg_catalog.pg_roles WHERE rolname ILIKE $4)
   THEN
      RAISE EXCEPTION 'Server role matching SchoolIssuedID already exists';
   END IF;

   --Create student user with lowercase schoolIssuedID
   EXECUTE FORMAT('CREATE USER alpha_%s IN ROLE alpha_GB_Student'
                  ' ENCRYPTED PASSWORD ''%s''', LOWER($4), LOWER($4));

   INSERT INTO Student VALUES(DEFAULT, $1, $2, $3, $4, $5, $6);
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path FROM CURRENT;

ALTER FUNCTION addStudent(fName VARCHAR(50), mName VARCHAR(50),
   lName VARCHAR(50), schoolIssuedID VARCHAR(50), email VARCHAR(319),
   year VARCHAR(30)) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION addStudent(fName VARCHAR(50), mName VARCHAR(50),
   lName VARCHAR(50), schoolIssuedID VARCHAR(50), email VARCHAR(319),
   year VARCHAR(30)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION addStudent(fName VARCHAR(50), mName VARCHAR(50),
   lName VARCHAR(50), schoolIssuedID VARCHAR(50), email VARCHAR(319),
   year VARCHAR(30)) TO alpha_GB_Admissions, alpha_GB_DBAdmin;


--Assigns a major to a student by adding an entry to the Student_Major table.
--The student parameter should match the Gradebook identifier of a student. Use
--getStudentIDByIssuedID(schoolIssuedID)or getStudentIDByEmail(email) if
--necessary. Major should match a known major (case insensitive). Exceptions are
--raised if student does not match a known student or if major does not match a
--known major. A student may have 0 or more majors.
CREATE OR REPLACE FUNCTION assignMajor(student INT,
                                       major VARCHAR(30)
                                      )
   RETURNS VOID AS
$$
BEGIN
   IF NOT EXISTS(SELECT * FROM Student S WHERE S.ID = $1) THEN
      RAISE EXCEPTION 'ID does not match known student';
   END IF;

   IF NOT EXISTS(SELECT * FROM Major M WHERE M.Name ILIKE $2) THEN
      RAISE EXCEPTION 'Major does not match known major';
   END IF;

   IF EXISTS (SELECT * FROM Student_Major SM
              WHERE SM.Student = $1 AND SM.Major ILIKE $2)
   THEN
      RAISE WARNING 'Student was already majoring in %', $2;
      RETURN;
   END IF;

   WITH CasedMajor AS
   (
      SELECT M.Name Maj
      FROM Major M
      WHERE M.Name ILIKE $2
   )
   INSERT INTO Student_Major VALUES($1, (SELECT Maj FROM CasedMajor));
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path FROM CURRENT;

ALTER FUNCTION assignMajor(student INT, major VARCHAR(30))
   OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION assignMajor(student INT, major VARCHAR(30)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION assignMajor(student INT, major VARCHAR(30))
   TO alpha_GB_Registrar, alpha_GB_RegistrarAdmin, alpha_GB_Admissions,
   alpha_GB_DBAdmin;


--Removes a major from a student by deleting an entry to the Student_Major table
--which matches both student and major arguments. The student parameter should
--match the Gradebook identifier of a student. Use
--getStudentIDByIssuedID(schoolIssuedID)or getStudentIDByEmail(email) if
--necessary. Major should match a major assigned to the student (case
--insensitive). Exceptions are raised if student does not match a known student
--or if the student is not assigned the given major.
CREATE OR REPLACE FUNCTION revokeMajor(student INT,
                                       major VARCHAR(30)
                                      )
   RETURNS VOID AS
$$
BEGIN
   IF NOT EXISTS(SELECT * FROM Student S WHERE S.ID = $1) THEN
      RAISE EXCEPTION 'ID does not match known student';
   END IF;

   IF NOT EXISTS(SELECT * FROM Major M WHERE M.Name ILIKE $2) THEN
      RAISE EXCEPTION 'Major does not match known major';
   END IF;

   IF NOT EXISTS (SELECT * FROM Student_Major SM
              WHERE SM.Student = $1 AND SM.Major ILIKE $2)
   THEN
      RAISE WARNING 'Student was not majoring in %', $2;
      RETURN;
   END IF;

   WITH CasedMajor AS
   (
      SELECT M.Name Maj
      FROM Major M
      WHERE M.Name ILIKE $2
   )
   DELETE FROM Student_Major SM
   WHERE SM.Student = $1 AND SM.Major = (SELECT Maj FROM CasedMajor);
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path FROM CURRENT;

ALTER FUNCTION revokeMajor(student INT, major VARCHAR(30))
   OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION revokeMajor(student INT, major VARCHAR(30)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION revokeMajor(student INT, major VARCHAR(30))
   TO alpha_GB_Registrar, alpha_GB_RegistrarAdmin, alpha_GB_DBAdmin;


--Returns a table with fName, mName, lName, schoolIssuedID, email, and year
--attributes , populated by rows from the Student table which match all of the
--given arguments.
CREATE OR REPLACE FUNCTION searchStudent(fname VARCHAR(50),
                                         mName VARCHAR(50),
                                         lName VARCHAR(50)
                                        )
RETURNS TABLE("FirstName" VARCHAR(50),
              "MiddleName" VARCHAR(50),
              "LastName" VARCHAR(50),
              "SchoolID" VARCHAR(50),
              "Email" VARCHAR(319),
              "Year" VARCHAR(30)
             ) AS
$$
SELECT COALESCE(s.fname, ''),
       COALESCE(s.mname, ''), 
       COALESCE(s.lname, ''), 
       schoolissuedid, email, year
FROM student s
WHERE TRIM(COALESCE(s.fname, '')) ILIKE TRIM($1) AND
      TRIM(COALESCE(s.mname, '')) ILIKE TRIM($2) AND
      TRIM(COALESCE(s.lname, '')) ILIKE TRIM($3);
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION searchStudent(fname VARCHAR(50), mName VARCHAR(50),
   lName VARCHAR(50)) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION searchStudent(fname VARCHAR(50), mName VARCHAR(50),
   lName VARCHAR(50)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION searchStudent(fname VARCHAR(50), mName VARCHAR(50),
   lName VARCHAR(50)) TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns the ID for the row in the Student table where the row's schoolIssuedID
--attribute matches the argument schoolIssuedID, or where the row's email
--attribute matches the argument email.
CREATE OR REPLACE FUNCTION getStudentIDByIssuedID(schoolIssuedID VARCHAR(50))
   RETURNS INT AS
$$
SELECT s.id
FROM student s
WHERE TRIM(s.schoolissuediD) ILIKE TRIM($1);
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getStudentIDByIssuedID(schoolIssuedID VARCHAR(50))
   OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getStudentIDByIssuedID(schoolIssuedID VARCHAR(50))
   FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentIDByIssuedID(schoolIssuedID VARCHAR(50))
   TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns the ID for the row in the Student table where the row's schoolIssuedID
--attribute matches the argument schoolIssuedID, or where the row's email
--attribute matches the argument email.
CREATE OR REPLACE FUNCTION getStudentIDbyEmail(email VARCHAR(319))
   RETURNS INT AS
$$
SELECT s.id
FROM student s
WHERE TRIM(s.email) ILIKE TRIM($1);
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getStudentIDbyEmail(email VARCHAR(319)) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getStudentIDbyEmail(email VARCHAR(319)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentIDbyEmail(email VARCHAR(319))
   TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns a table containing information about the student that has a
-- SchoolIssuedID matching SESSION_USER
CREATE OR REPLACE FUNCTION getStudentAsStudent()
RETURNS TABLE
(
   ID INTEGER,
   FName VARCHAR(50),
   MName VARCHAR(50),
   LName VARCHAR(50),
   Email VARCHAR(319)
) AS
$$
   SELECT S.ID, S.FName, S.MName, S.LName, S.Email
   FROM Student S
   WHERE S.SchoolIssuedID = SESSION_USER;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   ROWS 1;

ALTER FUNCTION getStudentAsStudent() OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getStudentAsStudent() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentAsStudent() TO alpha_GB_Student;


--Changes midtermGradeAwarded in a row of the Enrollee table where the row's
--student attribute matches the argument student, and where the student is in
--the section that the instructor teaches.
CREATE OR REPLACE FUNCTION assignMidtermGrade(student INT, sectionID INT,
                                              midtermGradeAwarded VARCHAR(2)
                                             )
   RETURNS VOID AS
$$
BEGIN
   IF NOT EXISTS(
      SELECT * FROM section s
      WHERE s.id = $2 AND getInstructorID(SESSION_USER)
                           IN (instructor1, instructor2, instructor3))
   THEN
      RAISE EXCEPTION 'Current user is not an instructor of specified student';
   ELSE
      UPDATE enrollee e
      SET e.midtermgradeawarded = $3
      WHERE e.student = $1;
   END IF;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION assignMidtermGrade(student INT, sectionID INT,
                                  midtermGradeAwarded VARCHAR(2))
   OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION assignMidtermGrade(student INT, sectionID INT,
   midtermGradeAwarded VARCHAR(2)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION assignMidtermGrade(student INT, sectionID INT,
   midtermGradeAwarded VARCHAR(2)) TO alpha_GB_Instructor, alpha_GB_DBAdmin;


--Changes finalGradeAwarded in a row of the Enrollee table where the row's
--student attribute matches the argument student, and where the student is in
--the section that the instructor teaches.
CREATE OR REPLACE FUNCTION assignFinalGrade(student INT, sectionID INT,
                                            finalGradeAwarded VARCHAR(2)
                                           )
   RETURNS VOID AS
$$
BEGIN
   IF NOT EXISTS(
      SELECT * FROM section s
      WHERE s.id = $2 AND getInstructorID(SESSION_USER)
                           IN (instructor1, instructor2, instructor3))
   THEN
      RAISE EXCEPTION 'Current user is not an instructor of specified student';
   ELSE
      UPDATE enrollee e
      SET e.finalgradeawarded = $3
      WHERE e.student = $1;
   END IF;
END;
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION assignFinalGrade(student INT, sectionID INT,
                                finalGradeAwarded VARCHAR(2))
   OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION assignFinalGrade(student INT, sectionID INT,
   finalGradeAwarded VARCHAR(2)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION assignFinalGrade(student INT, sectionID INT,
   finalGradeAwarded VARCHAR(2)) TO alpha_GB_Instructor, alpha_GB_DBAdmin;


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
   seasonOrder NUMERIC(1,0)) OWNER TO alpha;

REVOKE ALL ON FUNCTION getStudentSections(studentID INT,
   year NUMERIC(4,0), seasonOrder NUMERIC(1,0)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentSections(studentID INT,
   year NUMERIC(4,0), seasonOrder NUMERIC(1,0)) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Registrar, alpha_GB_RegistrarAdmin,
   alpha_GB_Admissions, alpha_GB_DBAdmin, alpha_GB_Student;


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
   seasonOrder NUMERIC(1,0), courseNumber VARCHAR(8)) OWNER TO alpha;

REVOKE ALL ON FUNCTION getStudentSections(studentID INT, year NUMERIC(4,0),
   seasonOrder NUMERIC(1,0), courseNumber VARCHAR(8)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentSections(studentID INT, year NUMERIC(4,0),
   seasonOrder NUMERIC(1,0), courseNumber VARCHAR(8)) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Registrar, alpha_GB_RegistrarAdmin,
   alpha_GB_Admissions, alpha_GB_DBAdmin, alpha_GB_Student;

--Returns a table listing the seasons in which the student specified by
--SESSION_USER has been enrolled in at least one section in the given year.
--Returns 0 rows if student has not been enrolled in any sections, or NULL if
--the SESSION_USER is not a student.
CREATE OR REPLACE FUNCTION getSeasonsAsStudent(year NUMERIC(4,0))
   RETURNS TABLE(SeasonOrder Numeric(1,0),
                 SeasonName VARCHAR(20)
                ) AS
$$
   SELECT getStudentSeasons(getMyStudentID(), $1);
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE;

ALTER FUNCTION getSeasonsAsStudent(year NUMERIC(4,0)) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getSeasonsAsStudent(year NUMERIC(4,0)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getSeasonsAsStudent(year NUMERIC(4,0)) TO
   alpha_GB_Student;

COMMIT;
