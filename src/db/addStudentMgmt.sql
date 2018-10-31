--addStudentMgmt.sql - Gradebook

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script creates functions related to seasons
-- the script should be run as part of application installation


--Suppress messages below WARNING level for the duration of this script
SET LOCAL client_min_messages TO WARNING;

--Given Gradebook's identifier for a student, returns a table listing the years
--in which the student has been enrolled in a section. Returns 0 rows if student
--has not been enrolled in a section, or if studentID does not match a valid
--student.
CREATE OR REPLACE FUNCTION getStudentYears(studentID INT)
RETURNS TABLE(Year NUMERIC(4,0))
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getStudentYears(studentID INT) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getStudentYears(studentID INT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentYears(studentID INT) TO GB_Webapp,
GB_Instructor, GB_Registrar, GB_RegistrarAdmin, GB_Admissions, GB_DBAdmin;


--Returns a table listing the years in which the student specified by
--SESSION_USER has been enrolled in at least one section. Returns 0 rows if
--student has not been enrolled in any sections, or NULL if the SESSION_USER is
--not a student.
CREATE OR REPLACE FUNCTION getYearsAsStudent()
RETURNS TABLE(Year NUMERIC(4,0))
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   STABLE;

ALTER FUNCTION getYearsAsStudent() OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getYearsAsStudent() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getYearsAsStudent() TO GB_Student;


--Given Gradebook's identifier for a student and a year, returns a table listing
--the seasons in the given year that the student has been enrolled in a section.
--Returns 0 rows if the student was not enrolled in any section in the given
--year or if studentID does not match a valid student.
CREATE OR REPLACE FUNCTION getStudentSeasons(studentID INT,
                                             year NUMERIC(4,0)
                                            )
RETURNS TABLE(SeasonOrder Numeric(1,0),
              SeasonName VARCHAR(20)
             )
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getStudentSeasons(studentID INT,
                                 year NUMERIC(4,0)
                                )
OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getStudentSeasons(studentID INT, year NUMERIC(4,0))
FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentSeasons(studentID INT, year NUMERIC(4,0))
TO GB_Webapp, GB_Instructor, GB_Registrar, GB_RegistrarAdmin, GB_Admissions,
GB_Admin;


--Returns a table listing the seasons in which the student specified by
--SESSION_USER has been enrolled in at least one section in the given year.
--Returns 0 rows if student has not been enrolled in any sections, or NULL if
--the SESSION_USER is not a student.
CREATE OR REPLACE FUNCTION getSeasonsAsStudent(year NUMERIC(4,0))
RETURNS TABLE(SeasonOrder Numeric(1,0),
              SeasonName VARCHAR(20)
             )
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   STABLE;

ALTER FUNCTION getSeasonsAsStudent(year NUMERIC(4,0)) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getSeasonsAsStudent(year NUMERIC(4,0)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getSeasonsAsStudent(year NUMERIC(4,0)) TO GB_Student;


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
RETURNS NULL
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER;

ALTER FUNCTION addStudent(fName VARCHAR(50), mName VARCHAR(50),
lName VARCHAR(50), schoolIssuedID VARCHAR(50), email VARCHAR(319),
year VARCHAR(30)) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION addStudent(fName VARCHAR(50), mName VARCHAR(50),
lName VARCHAR(50), schoolIssuedID VARCHAR(50), email VARCHAR(319),
year VARCHAR(30)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION addStudent(fName VARCHAR(50), mName VARCHAR(50),
lName VARCHAR(50), schoolIssuedID VARCHAR(50), email VARCHAR(319),
year VARCHAR(30)) TO GB_Admissions, GB_DBAdmin;


--Assigns a major to a student by adding an entry to the Student_Major table.
--The student parameter should match the Gradebook identifier of a student. Use
--getStudentIDByIssuedID(schoolIssuedID)or getStudentIDByEmail(email) if
--necessary. Major should match a known major (case insensitive). Exceptions are
--raised if student does not match a known student or if major does not match a
--known major. A student may have 0 or more majors.
CREATE OR REPLACE FUNCTION assignMajor(student INT,
                                       major VARCHAR(30)
                                      )
RETURNS NULL
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER;

ALTER FUNCTION assignMajor(student INT, major VARCHAR(30))
OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION assignMajor(student INT, major VARCHAR(30)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION assignMajor(student INT, major VARCHAR(30))
TO GB_Registrar, GB_RegistrarAdmin, GB_Admissions, GB_DBAdmin;


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
RETURNS NULL AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER;

ALTER FUNCTION revokeMajor(student INT, major VARCHAR(30))
OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION revokeMajor(student INT, major VARCHAR(30)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION revokeMajor(student INT, major VARCHAR(30))
TO GB_Registrar, GB_RegistrarAdmin, GB_DBAdmin;


--Returns a table with fName, mName, lName, schoolIssuedID, email, and year
--attributes , populated by rows from the Student table which match all of the
--given arguments.
CREATE OR REPLACE FUNCTION searchStudent(fname VARCHAR(50),
                                         mName VARCHAR(50),
                                         lName VARCHAR(50)
                                        )
RETURNS TABLE(FName VARCHAR(50),
              MName VARCHAR(50),
              LName VARCHAR(50),
              SchoolIssuedID VARCHAR(50),
              Email VARCHAR(319),
              Year VARCHAR(30)
             )
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION searchStudent(fname VARCHAR(50), mName VARCHAR(50),
lName VARCHAR(50)) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION searchStudent(fname VARCHAR(50), mName VARCHAR(50),
lName VARCHAR(50)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION searchStudent(fname VARCHAR(50), mName VARCHAR(50),
lName VARCHAR(50)) TO GB_Webapp, GB_Instructor, GB_Registrar, GB_RegistrarAdmin,
GB_Admissions, GB_DBAdmin;


--Returns the ID for the row in the Student table where the row's schoolIssuedID
--attribute matches SESSION_USER. Returns NULL if no such record found.
CREATE OR REPLACE FUNCTION getMyStudentID() RETURNS INT AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   STABLE;

ALTER FUNCTION getMyStudentID() OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getMyStudentID() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getMyStudentID() TO GB_Student;


--Returns the ID for the row in the Student table where the row's schoolIssuedID
--attribute matches the argument schoolIssuedID, or where the row's email
--attribute matches the argument email.
CREATE OR REPLACE FUNCTION getStudentIDByIssuedID(schoolIssuedID VARCHAR(50))
RETURNS INT
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getStudentIDByIssuedID(schoolIssuedID VARCHAR(50))
OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getStudentIDByIssuedID(schoolIssuedID VARCHAR(50))
FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentIDByIssuedID(schoolIssuedID VARCHAR(50))
TO GB_Webapp, GB_Instructor, GB_Registrar, GB_RegistrarAdmin, GB_Admissions,
GB_DBAdmin;


--Returns the ID for the row in the Student table where the row's schoolIssuedID
--attribute matches the argument schoolIssuedID, or where the row's email
--attribute matches the argument email.
CREATE OR REPLACE FUNCTION getStudentIDbyEmail(email VARCHAR(319))
RETURNS INT AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getStudentIDbyEmail(email VARCHAR(319)) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getStudentIDbyEmail(email VARCHAR(319)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getStudentIDbyEmail(email VARCHAR(319)) TO GB_Webapp,
GB_Instructor, GB_Registrar, GB_RegistrarAdmin, GB_Admissions, GB_DBAdmin;


--Changes midtermGradeAwarded in a row of the Enrollee table where the row's
--student attribute matches the argument student, and where the student is in
--the section that the instructor teaches.
CREATE OR REPLACE FUNCTION assignMidtermGrade(student INT,
                                              midtermGradeAwarded VARCHAR(2)
                                             )
RETURNS NULL
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION assignMidtermGrade(student INT, midtermGradeAwarded VARCHAR(2))
OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION assignMidtermGrade(student INT,
midtermGradeAwarded VARCHAR(2)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION assignMidtermGrade(student INT,
midtermGradeAwarded VARCHAR(2)) TO GB_Instructor, GB_DBAdmin;


--Changes finalGradeAwarded in a row of the Enrollee table where the row's
--student attribute matches the argument student, and where the student is in
--the section that the instructor teaches.
CREATE OR REPLACE FUNCTION assignFinalGrade(student INT,
                                            finalGradeAwarded VARCHAR(2)
                                           )
RETURNS NULL
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION assignFinalGrade(student INT, finalGradeAwarded VARCHAR(2))
OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION assignFinalGrade(student INT,
finalGradeAwarded VARCHAR(2)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION assignFinalGrade(student INT,
finalGradeAwarded VARCHAR(2)) TO GB_Instructor, GB_DBAdmin;
