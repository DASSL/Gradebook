--addSectionMgmt.sql - Gradebook

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script creates functions related to sections
-- the script should be run as part of application installation


--Suppress messages below WARNING level for the duration of this script
SET LOCAL client_min_messages TO WARNING;


--Drop function from M1 that have since been renamed or removed
-- remove the DROP statements after M2
DROP FUNCTION IF EXISTS Gradebook.getSectionID(NUMERIC(4,0), NUMERIC(1,0),
                                               VARCHAR(8), VARCHAR(3)
                                              );
DROP FUNCTION IF EXISTS Gradebook.getSection(NUMERIC(4,0), NUMERIC(1,0),
                                           VARCHAR(8), VARCHAR(3)
                                          );


--Function to get ID of section matching a year-season-course-section# combo
-- season is "season identification"
DROP FUNCTION IF EXISTS Gradebook.getSectionID(NUMERIC(4,0), VARCHAR(20),
                                               VARCHAR(8), VARCHAR(3)
                                              );

CREATE FUNCTION Gradebook.getSectionID(year NUMERIC(4,0),
                                       seasonIdentification VARCHAR(20),
                                       course VARCHAR(8),
                                       sectionNumber VARCHAR(3)
                                      )
RETURNS INT
AS
$$

   SELECT N.ID
   FROM Gradebook.Section N JOIN Gradebook.Term T ON N.Term  = T.ID
   WHERE T.Year = $1
         AND T.Season = Gradebook.getSeasonOrder(seasonIdentification)
         AND LOWER(N.Course) = LOWER($3)
         AND LOWER(N.SectionNumber) = LOWER($4);

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT;



--Function to get details of section matching a year-season-course-section# combo
-- input season is "season identification"
-- StartDate column contains term start date if section does not have start date;
-- likewise with EndDate column
DROP FUNCTION IF EXISTS Gradebook.getSection(NUMERIC(4,0), VARCHAR(20),
                                             VARCHAR(8), VARCHAR(3)
                                            );

CREATE FUNCTION Gradebook.getSection(year NUMERIC(4,0),
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
   FROM Gradebook.Section N JOIN Gradebook.Term T ON N.Term  = T.ID
   WHERE T.Year = $1
         AND T.Season = Gradebook.getSeasonOrder(seasonIdentification)
         AND LOWER(N.Course) = LOWER($3)
         AND LOWER(N.SectionNumber) = LOWER($4);

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT
   ROWS 1;
