--addInstructorMgmt.sql - Gradebook

--Zaid Bhujwala, Elly Griffin, Steven Rollo, Andrew Figueroa, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script creates functions to obtain instructor-related information
-- the script should be run as part of application installation

--All get* functions in this script are marked as follows:
-- STABLE: result remains the same for a given input within the same statement
-- RETURNS NULL ON NULL INPUT: returns NULL or no result if any input is NULL


--Function to get details of all known instructors
DROP FUNCTION IF EXISTS Gradebook.getInstructors();

CREATE FUNCTION Gradebook.getInstructors()
RETURNS TABLE
(
   ID INT,
   FName VARCHAR(50),
   MName VARCHAR(50),
   LName VARCHAR(50),
   Department VARCHAR(30),
   Email VARCHAR(319)
)
AS
$$

   SELECT ID, FName, MName, LName, Department, Email
   FROM Gradebook.Instructor;

$$ LANGUAGE sql
   STABLE; --no need for RETURN NULL ON... because the function takes no input

    ALTER FUNCTION getInstructors()
    OWNER TO alpha;

    REVOKE ALL ON FUNCTION getInstructors()
    FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION getInstructors()
    TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Registrar, 
            alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--function to get details of the instructor with the given e-mail address
-- performs a case-insensitive match of email address;
-- returns 0 or 1 row: Instructor.Email is unique;
DROP FUNCTION IF EXISTS Gradebook.getInstructor(Gradebook.Instructor.Email%TYPE);

CREATE FUNCTION Gradebook.getInstructor(Email Gradebook.Instructor.Email%TYPE)
RETURNS TABLE
(
   ID INT,
   FName VARCHAR(50),
   MName VARCHAR(50),
   LName VARCHAR(50),
   Department VARCHAR(30)
)
AS
$$

   SELECT ID, FName, MName, LName, Department
   FROM Gradebook.Instructor
   WHERE LOWER(TRIM(Email)) = LOWER(TRIM($1));

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT
   ROWS 1; --returns at most one row

    ALTER FUNCTION getInstructor(Email Gradebook.Instructor.Email%TYPE)
    OWNER TO alpha;

    REVOKE ALL ON FUNCTION getInstructor(Email Gradebook.Instructor.Email%TYPE)
    FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION getInstructor(Email Gradebook.Instructor.Email%TYPE)
    TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Registrar, 
            alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--function to get details of the instructor with the given ID
DROP FUNCTION IF EXISTS Gradebook.getInstructor(INT);

CREATE FUNCTION Gradebook.getInstructor(instructorID INT)
RETURNS TABLE
(
   FName VARCHAR(50),
   MName VARCHAR(50),
   LName VARCHAR(50),
   Department VARCHAR(30),
   Email VARCHAR(319)
)
AS
$$

   SELECT FName, MName, LName, Department, Email
   FROM Gradebook.Instructor
   WHERE ID = $1;

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT
   ROWS 1;

    ALTER FUNCTION getInstructor(instructorID INT)
    OWNER TO alpha;

    REVOKE ALL ON FUNCTION getInstructor(instructorID INT)
    FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION getInstructor(instructorID INT)
    TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Registrar, 
            alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--drop functions with older names due to names being revised
-- remove this block of code after milestone M1
DROP FUNCTION IF EXISTS Gradebook.getYears(INT);
DROP FUNCTION IF EXISTS Gradebook.getSeasons(INT, NUMERIC(4,0));
DROP FUNCTION IF EXISTS Gradebook.getCourses(INT, NUMERIC(4,0), NUMERIC(1,0));
DROP FUNCTION IF EXISTS Gradebook.getSections(INT, NUMERIC(4,0),
                                              NUMERIC(1,0), VARCHAR(8)
                                             );


--function to get the years in which an instructor has taught
DROP FUNCTION IF EXISTS Gradebook.getInstructorYears(INT);

CREATE FUNCTION Gradebook.getInstructorYears(instructorID INT)
RETURNS TABLE(Year NUMERIC(4,0))
AS
$$

   SELECT DISTINCT Year
   FROM Gradebook.Term T JOIN Gradebook.Section N ON T.ID  = N.Term
   WHERE $1 IN (N.Instructor1, N.Instructor2, N.Instructor3)
   ORDER BY Year DESC;

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT;

    ALTER FUNCTION getInstructorYears(instructorID INT)
    OWNER TO alpha;

    REVOKE ALL ON FUNCTION getInstructorYears(instructorID INT)

    GRANT EXECUTE ON FUNCTION getInstructorYears(instructorID INT)
    TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Registrar, 
            alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--function to get all seasons an instructor has taught in a specfied year
DROP FUNCTION IF EXISTS Gradebook.getInstructorSeasons(INT, NUMERIC(4,0));

CREATE FUNCTION Gradebook.getInstructorSeasons(instructorID INT,
                                               year NUMERIC(4,0)
                                              )
RETURNS TABLE(SeasonOrder NUMERIC(1,0), SeasonName VARCHAR(20))
AS
$$

   SELECT DISTINCT S."Order", S.Name
   FROM Gradebook.Season S JOIN Gradebook.Term T ON S."Order" = T.Season
        JOIN Gradebook.Section N ON N.Term  = T.ID
   WHERE $1 IN (N.Instructor1, N.Instructor2, N.Instructor3)
         AND T.Year = $2
   ORDER BY S."Order";

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT;

    ALTER FUNCTION getInstructorSeasons(instructorID INT,
                                               year NUMERIC(4,0)
                                              )
    OWNER TO alpha;

    REVOKE ALL ON FUNCTION getInstructorSeasons(instructorID INT,
                                               year NUMERIC(4,0)
                                              )

    GRANT EXECUTE ON FUNCTION getInstructorSeasons(instructorID INT,
                                               year NUMERIC(4,0)
                                              )
    TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Registrar, 
            alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--function to get all courses an instructor has taught in a year-season combo
DROP FUNCTION IF EXISTS Gradebook.getInstructorCourses(INT, NUMERIC(4,0),
                                                       NUMERIC(1,0)
                                                      );

CREATE FUNCTION Gradebook.getInstructorCourses(instructorID INT,
                                               year NUMERIC(4,0),
                                               seasonOrder NUMERIC(1,0)
                                              )
RETURNS TABLE(Course VARCHAR(8))
AS
$$

   SELECT DISTINCT N.Course
   FROM Gradebook.Section N JOIN Gradebook.Term T ON N.Term  = T.ID
   WHERE $1 IN (N.Instructor1, N.Instructor2, N.Instructor3)
         AND T.Year = $2
         AND T.Season = $3
   ORDER BY N.Course;

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT;

    ALTER FUNCTION getInstructorCourses(instructorID INT,
                                               year NUMERIC(4,0),
                                               seasonOrder NUMERIC(1,0)
                                              )
    OWNER TO alpha;

    REVOKE ALL ON FUNCTION getInstructorCourses(instructorID INT,
                                               year NUMERIC(4,0),
                                               seasonOrder NUMERIC(1,0)
                                              )

    GRANT EXECUTE ON FUNCTION getInstructorCourses(instructorID INT,
                                               year NUMERIC(4,0),
                                               seasonOrder NUMERIC(1,0)
                                              )
    TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Registrar, 
            alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--function to get the course-section combos an instructor has taught in a
--year-season combo
-- for each matching section, returns course name and section number as well as
-- a string of the form "course-sectionNumber";
--this function is useful in showing Course-Section combinations directly
--without having to first explicitly choose a course to get sections
DROP FUNCTION IF EXISTS Gradebook.getInstructorSections(INT, NUMERIC(4,0),
                                                        NUMERIC(1,0)
                                                       );

CREATE FUNCTION Gradebook.getInstructorSections(instructorID INT,
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
   FROM Gradebook.Section N JOIN Gradebook.Term T ON N.Term  = T.ID
   WHERE $1 IN (N.Instructor1, N.Instructor2, N.Instructor3)
         AND T.Year = $2
         AND T.Season = $3
   ORDER BY CourseSection;

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT;

    ALTER FUNCTION getInstructorSections(instructorID INT,
                                                year NUMERIC(4,0),
                                                seasonOrder NUMERIC(1,0)
                                               )
    OWNER TO alpha;

    REVOKE ALL ON FUNCTION getInstructorSections(instructorID INT,
                                                year NUMERIC(4,0),
                                                seasonOrder NUMERIC(1,0)
                                               )

    GRANT EXECUTE ON FUNCTION getInstructorSections(instructorID INT,
                                                year NUMERIC(4,0),
                                                seasonOrder NUMERIC(1,0)
                                               )
    TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Registrar, 
            alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;

--function to get the section number(s) of a course an instructor has taught
-- performs case-insensitive match for course
DROP FUNCTION IF EXISTS Gradebook.getInstructorSections(INT, NUMERIC(4,0),
                                                        NUMERIC(1,0), VARCHAR(8)
                                                       );

CREATE FUNCTION Gradebook.getInstructorSections(instructorID INT,
                                                year NUMERIC(4,0),
                                                seasonOrder NUMERIC(1,0),
                                                courseNumber VARCHAR(8)
                                               )
RETURNS TABLE(SectionID INT, SectionNumber VARCHAR(3))
AS
$$

   SELECT SectionID, SectionNumber
   FROM Gradebook.getInstructorSections($1, $2, $3)
   WHERE LOWER(Course) = LOWER($4)
   ORDER BY SectionNumber;

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT;

    ALTER FUNCTION getInstructorSections(instructorID INT,
                                                year NUMERIC(4,0),
                                                seasonOrder NUMERIC(1,0),
                                                courseNumber VARCHAR(8)
                                               )
    OWNER TO alpha;

    REVOKE ALL ON FUNCTION getInstructorSections(instructorID INT,
                                                year NUMERIC(4,0),
                                                seasonOrder NUMERIC(1,0),
                                                courseNumber VARCHAR(8)
                                               )

    GRANT EXECUTE ON FUNCTION getInstructorSections(instructorID INT,
                                                year NUMERIC(4,0),
                                                seasonOrder NUMERIC(1,0),
                                                courseNumber VARCHAR(8)
                                               )
    TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Registrar, 
            alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;
