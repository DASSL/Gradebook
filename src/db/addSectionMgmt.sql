--addSectionMgmt.sql - Gradebook

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script creates functions related to sections
-- the script should be run as part of application installation

START TRANSACTION;

--Suppress messages below WARNING level for the duration of this script
SET LOCAL client_min_messages TO WARNING;

--Set schema to reference in functions and tables, pg_temp is specified
-- last for security purposes
SET LOCAL search_path TO 'alpha', 'pg_temp';

--Function to get ID of section matching a year-season-course-section# combo
-- season is "season identification"
DROP FUNCTION IF EXISTS getSectionID(NUMERIC(4,0), VARCHAR(20),
                                               VARCHAR(8), VARCHAR(3)
                                              );

CREATE FUNCTION getSectionID(year NUMERIC(4,0),
                                       seasonIdentification VARCHAR(20),
                                       course VARCHAR(8),
                                       sectionNumber VARCHAR(3)
                                      )
RETURNS INT
AS
$$

   SELECT N.ID
   FROM Section N JOIN Term T ON N.Term  = T.ID
   WHERE T.Year = $1
         AND T.Season = getSeasonOrder($2)
         AND LOWER(N.Course) = LOWER($3)
         AND LOWER(N.SectionNumber) = LOWER($4);

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT;


--Function to get ID of section matching a year-season-course-section# combo
-- season is "season order"
-- reuses the season-identification version
-- this function exists to support clients that pass season order as a number
DROP FUNCTION IF EXISTS getSectionID(NUMERIC(4,0), NUMERIC(1,0),
                                               VARCHAR(8), VARCHAR(3)
                                              );

CREATE FUNCTION getSectionID(year NUMERIC(4,0),
                                       seasonOrder NUMERIC(1,0),
                                       course VARCHAR(8),
                                       sectionNumber VARCHAR(3)
                                      )
RETURNS INT
AS
$$

    SELECT getSectionID($1, $2::VARCHAR, $3, $4);

$$ LANGUAGE sql
 STABLE
 RETURNS NULL ON NULL INPUT;


--Function to get details of section matching a year-season-course-section# combo
-- input season is "season identification"
-- StartDate column contains term start date if section does not have start date;
-- likewise with EndDate column
DROP FUNCTION IF EXISTS getSection(NUMERIC(4,0), VARCHAR(20),
                                             VARCHAR(8), VARCHAR(3)
                                            );

CREATE FUNCTION getSection(year NUMERIC(4,0),
                                     seasonIdentification VARCHAR(20),
                                     course VARCHAR(8), sectionNumber VARCHAR(3)
                                    )
RETURNS TABLE
(
   ID INT,
   Term INT,
   Course VARCHAR(8),
   SectionNumber VARCHAR(3),
   CRN VARCHAR(5),
   Schedule VARCHAR(7),
   Location VARCHAR(25),
   StartDate DATE,
   EndDate DATE,
   MidtermDate DATE,
   Instructor1 INT,
   Instructor2 INT,
   Instructor3 INT
)
AS
$$

   SELECT N.ID, N.Term, N.Course, N.SectionNumber, N.CRN, N.Schedule, N.Location,
          COALESCE(N.StartDate, T.StartDate), COALESCE(N.EndDate, T.EndDate),
          N.MidtermDate, N.Instructor1, N.Instructor2, N.Instructor3
   FROM Section N JOIN Term T ON N.Term  = T.ID
   WHERE T.Year = $1
         AND T.Season = getSeasonOrder($2)
         AND LOWER(N.Course) = LOWER($3)
         AND LOWER(N.SectionNumber) = LOWER($4);

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT
   ROWS 1;


--Function to get details of section matching a year-season-course-section# combo
-- input season is "season order"
-- reuses the season-identification version
-- this function exists to support clients that pass season order as a number
DROP FUNCTION IF EXISTS getSection(NUMERIC(4,0), NUMERIC(1,0),
                                             VARCHAR(8), VARCHAR(3)
                                            );

CREATE FUNCTION getSection(year NUMERIC(4,0), seasonOrder NUMERIC(1,0),
                                    course VARCHAR(8), sectionNumber VARCHAR(3)
                                   )
RETURNS TABLE
(
  ID INT,
  Term INT,
  Course VARCHAR(8),
  SectionNumber VARCHAR(3),
  CRN VARCHAR(5),
  Schedule VARCHAR(7),
  Location VARCHAR(25),
  StartDate DATE,
  EndDate DATE,
  MidtermDate DATE,
  Instructor1 INT,
  Instructor2 INT,
  Instructor3 INT
)
AS
$$

   SELECT ID, Term, Course, SectionNumber, CRN, Schedule, Location,
          StartDate, EndDate,
          MidtermDate, Instructor1, Instructor2, Instructor3
   FROM getSection($1, $2::VARCHAR, $3, $4);

$$ LANGUAGE sql
  STABLE
  RETURNS NULL ON NULL INPUT
  ROWS 1;


  --Returns the ID
  --attribute of a row from the Section table where the row's term, course, and
  --sectionNumber attributes match all of the arguments term, courseNumber, and
  --sectionNumber, respectively.
  CREATE OR REPLACE FUNCTION getSectionID(term INT,
                                          courseNumber VARCHAR(8),
                                          sectionNumber VARCHAR(3)
                                         )
  RETURNS INT
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

  ALTER FUNCTION getSectionID(term INT, courseNumber VARCHAR(8),
  sectionNumber VARCHAR(3)) OWNER TO CURRENT_USER;

  REVOKE ALL ON FUNCTION getSectionID(term INT, courseNumber VARCHAR(8),
  sectionNumber VARCHAR(3)) FROM PUBLIC;

  GRANT EXECUTE ON FUNCTION getSectionID(term INT, courseNumber VARCHAR(8),
  sectionNumber VARCHAR(3)) TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Student,
  alpha_GB_Registrar, alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


  --Returns the ID attribute of a row from the Section table where the row's
  --term, course, and sectionNumber attributes match all of the arguments term,
  --courseNumber, and sectionNumber, respectively.
  CREATE OR REPLACE FUNCTION getSectionID(term INT, CRN VARCHAR(5))
  RETURNS INT
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

  ALTER FUNCTION getSectionID(term INT, CRN VARCHAR(5)) OWNER TO CURRENT_USER;

  REVOKE ALL ON FUNCTION getSectionID(term INT, CRN VARCHAR(5)) FROM PUBLIC;

  GRANT EXECUTE ON FUNCTION getSectionID(term INT, CRN VARCHAR(5)) TO alpha_GB_Webapp,
  alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar, alpha_GB_RegistrarAdmin, 
  alpha_GB_Admissions, alpha_GB_DBAdmin;


  --Returns a table describing the section, which is populated with rows in
  --which the ID attribute of Section matches the argument ID.
  CREATE OR REPLACE FUNCTION getSection(sectionID INT)
  RETURNS TABLE(Term INT,
                Course VARCHAR(8),
                SectionNumber VARCHAR(3),
                CRN VARCHAR(5),
                Schedule VARCHAR(7),
                Location VARCHAR(25),
                StartDate DATE,
                EndDate DATE,
                MidtermDate DATE,
                Instructors VARCHAR(150)
               )
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

  ALTER FUNCTION getSection(sectionID INT) OWNER TO CURRENT_USER;

  REVOKE ALL ON FUNCTION getSection(sectionID INT) FROM PUBLIC;

  GRANT EXECUTE ON FUNCTION getSection(sectionID INT) TO alpha_GB_Webapp, 
  alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar, 
  alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


  --Generates a list of class dates within a specified range. Uses char codes for
  --days of the week (In order, starting with Sunday: NMTWRFS).
  CREATE OR REPLACE FUNCTION getScheduleDates(startDate DATE,
                                              endDate DATE,
                                              schedule VARCHAR(7)
                                             )
 RETURNS TABLE("Dates" DATE)
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

  ALTER FUNCTION getScheduleDates(startDate DATE, endDate DATE,
  schedule VARCHAR(7)) OWNER TO CURRENT_USER;

  REVOKE ALL ON FUNCTION getScheduleDates(startDate DATE, endDate DATE,
  schedule VARCHAR(7)) FROM PUBLIC;

  GRANT EXECUTE ON FUNCTION getScheduleDates(startDate DATE, endDate DATE,
  schedule VARCHAR(7)) TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Student, 
  alpha_GB_Registrar, alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


  --Returns a table of rows from the section table where the title argument
  --matches or closely matches section number or course title, with an added
  --attribute that represents the relative difference from the original string
  --to the matched string (a value of 0 represents an exact match). Uses fuzzy
  --matching to make comparisons. Returns no rows if no section titles reasonably
  --match the argument.
  CREATE OR REPLACE FUNCTION searchSectionTitles(termID INT,
                                                 title VARCHAR(100)
                                                )
  RETURNS TABLE(Number VARCHAR(8),
                SectionTitle VARCHAR(100),
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

  ALTER FUNCTION searchSectionTitles(termID INT, title VARCHAR(100))
  OWNER TO CURRENT_USER;

  REVOKE ALL ON FUNCTION searchSectionTitles(termID INT, title VARCHAR(100))
  FROM PUBLIC;

  GRANT EXECUTE ON FUNCTION searchSectionTitles(termID INT, title VARCHAR(100))
  TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar, 
  alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


COMMIT;
