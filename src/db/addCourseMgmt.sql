--addCourseMgmt.sql - Gradebook

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script creates functions related to courses
-- the script should be run as part of application installation

START TRANSACTION;

--Suppress messages below WARNING level for the duration of this script
SET LOCAL client_min_messages TO WARNING;

--Set schema to reference in functions and tables, pg_temp is specified
-- last for security purposes
SET LOCAL search_path TO 'alpha', 'pg_temp';


--Removes a row from the Course table where courseName matches the course
--number. Returns the previous course title or NULL if the courseNumber did not
--correspond to a known course.
CREATE OR REPLACE FUNCTION changeCourseDefaultTitle(courseNumber VARCHAR(8),
                                                    newDefaultTitle VARCHAR(100)
                                                   )
RETURNS VARCHAR(100)
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION changeCourseDefaultTitle(courseNumber VARCHAR(8),
newDefaultTitle VARCHAR(100)) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION changeCourseDefaultTitle(courseNumber VARCHAR(8),
                                                newDefaultTitle VARCHAR(100)
                                               )
FROM PUBLIC;

GRANT EXECUTE ON FUNCTION changeCourseDefaultTitle(courseNumber VARCHAR(8),
                                                   newDefaultTitle VARCHAR(100)
                                                  )
TO alpha_GB_RegistrarAdmin, alpha_GB_DBAdmin;

--Returns a table of rows from the course table where the argument matches or
--closely matches course title, with an added attribute that represents the
--relative difference from the original string to the matched string (a value
--of 0 represents an exact match). Uses fuzzy matching to make comparisons.
--Returns no rows if no course titles reasonably match the argument.
CREATE OR REPLACE FUNCTION searchCourseTitles(titleSearch VARCHAR(100))
RETURNS TABLE(Number VARCHAR(8),
              Title VARCHAR(100),
              Difference INTEGER)
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION searchCourseTitles(title VARCHAR(100)) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION searchCourseTitles(title VARCHAR(100)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION searchCourseTitles(title VARCHAR(100)) TO alpha_GB_Webapp,
alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar, alpha_GB_RegistrarAdmin, 
alpha_GB_Admissions, alpha_GB_DBAdmin;


--Adds a course to the Course table. Name represents the abbreviated name of the
--course (“CS305”, “MAT182”, and so on), and defaultTitle represents the default
--long form name of the course (such as “Database Systems Engineering”,
--“Calculus II”, or “Faculty Developed Study”). This default title may be later
--used for sections, or a section of the course may use its own title. Exception
--raised if course name (not default title) already corresponded to an existing
--course.
CREATE OR REPLACE FUNCTION addCourse(name VARCHAR(8),
                                     defaultTitle VARCHAR(100)
                                    )
RETURNS VOID
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path FROM CURRENT;

ALTER FUNCTION addCourse(name VARCHAR(8), defaultTitle VARCHAR(100))
OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION addCourse(name VARCHAR(8), defaultTitle VARCHAR(100))
FROM PUBLIC;

GRANT EXECUTE ON FUNCTION addCourse(name VARCHAR(8), defaultTitle VARCHAR(100))
TO alpha_GB_RegistrarAdmin, alpha_GB_DBAdmin;


--Returns the default title of the Course corresponding to the given
--courseNumber. Returns NULL if no course matches the argument.
CREATE OR REPLACE FUNCTION getCourseDefaultTitle(courseNumber VARCHAR(8))
RETURNS VARCHAR(100)
AS
$$
BEGIN
   RAISE WARNING 'Function not implemented';
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getCourseDefaultTitle(courseNumber VARCHAR(8))
OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getCourseDefaultTitle(courseNumber VARCHAR(8))
FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getCourseDefaultTitle(courseNumber VARCHAR(8)) TO
alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar, 
alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


COMMIT;
