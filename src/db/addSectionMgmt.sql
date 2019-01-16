--addSectionMgmt.sql - Gradebook

--Sean Murthy, Andrew Figueroa, Jonathan Middleton
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU).
-- With contributions from Bruno DaSilva

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
SET LOCAL search_path TO 'gradebook', 'pg_temp';

--Function to get ID of section matching a year-season-course-section# combo
-- season is "season identification"
DROP FUNCTION IF EXISTS getSectionID(NUMERIC(4,0), VARCHAR(20),
                                             VARCHAR(8), VARCHAR(3)
                                             );

CREATE FUNCTION getSectionID(year NUMERIC(4,0),
                             seasonIdentification VARCHAR(20),
                             course VARCHAR(8),
                             sectionNumber VARCHAR(3)
                            ) RETURNS INT AS
$$
   SELECT N.ID
   FROM Section N JOIN Term T ON N.Term  = T.ID
   WHERE T.Year = $1
         AND T.Season = getSeasonOrder($2)
         AND N.Course ILIKE $3
         AND N.SectionNumber ILIKE $4;
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
                            ) RETURNS INT AS
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
                                   VARCHAR(8), VARCHAR(3));

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
   Title VARCHAR(100),
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
   SELECT N.ID, N.Term, N.Course, N.SectionNumber, N.Title, N.CRN, N.Schedule,
         N.Location, COALESCE(N.StartDate, T.StartDate),
         COALESCE(N.EndDate, T.EndDate), N.MidtermDate, N.Instructor1,
         N.Instructor2, N.Instructor3
   FROM Section N JOIN Term T ON N.Term  = T.ID
   WHERE T.Year = $1
         AND T.Season = getSeasonOrder($2)
         AND N.Course ILIKE $3
         AND N.SectionNumber ILIKE $4;
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
   Title VARCHAR(100),
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
   SELECT ID, Term, Course, SectionNumber, Title, CRN, Schedule, Location,
         StartDate, EndDate,
         MidtermDate, Instructor1, Instructor2, Instructor3
   FROM getSection($1, $2::VARCHAR, $3, $4);
$$ LANGUAGE sql
STABLE
RETURNS NULL ON NULL INPUT
ROWS 1;


COMMIT;
