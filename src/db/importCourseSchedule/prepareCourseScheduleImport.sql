--prepareCourseScheduleImport.sql - Gradebook

--Kyle Bella, Zach Boylan, Zaid Bhujwala, Steven Rollo, Hunter Schloss, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script is part of the procedure to import course schedules from a CSV file.
-- This script is currently designed to work with data from the OpenClose system.
-- To accomplish this, this script creates some temporary objects needed for import.
-- It should be run before copying CSV data to the staging table.

--The script prepareDB.psql should have been run before running this script

--Set schema to reference in functions and tables, pg_temp is specified
-- last for security purposes
SET LOCAL search_path TO 'alpha', 'pg_temp';


--This table is used to stage data from CSV file as part of the import process
CREATE TEMPORARY TABLE CourseScheduleStaging
(
   Status VARCHAR(6),
   Level VARCHAR(2),
   CRN  VARCHAR(5),
   Subject VARCHAR(4),
   Course VARCHAR(6),
   Section VARCHAR(3),
   Credits VARCHAR(15),
   Title VARCHAR(100),
   Days VARCHAR(7),
   Time VARCHAR(30),
   Date VARCHAR(15),
   Capacity INTEGER,
   Actual INTEGER,
   Remaining INTEGER,
   XL_Capacity INTEGER,
   XL_Actual INTEGER,
   XL_Remaining INTEGER,
   Location VARCHAR(25),
   Instructor VARCHAR(200)
);

--Checks if the supplied year and season belong to the next term in sequence.
-- Returns true if the supplied term is the next term, otherwise false.
-- This is accomplished by testing if [currentYear * COUNT(Seasons) + Season + 1]
-- is equal to [newYear * COUNT(Seasons) + Season].
--Each year is mapped to a scale counting for the number of
-- seasons that are in Gradebook. This allows a simple equality check to see
-- if the supplied term is in sequence
CREATE FUNCTION pg_temp.checkTermSequence(year INT, seasonOrder NUMERIC(1,0))
RETURNS BOOLEAN AS
$$
   --Get each term from the latest year
   WITH LatestYear AS
   (
      SELECT Year, Season
      FROM Term
      WHERE Year = (SELECT MAX(Year) FROM Term)
   )
   SELECT CASE --Check for the case when there are no terms, as we can't check
               --the sequence if it hasn't been started yet
      WHEN (SELECT COUNT(*) FROM Term) > 0 THEN
         (
            MAX(LY.Year) * (SELECT COUNT(*) FROM Season) +
            MAX(LY.Season) + 1
         ) =
         (
            $1 * (SELECT COUNT(*) FROM Season) + $2
         )
      ELSE
         TRUE
      END
   FROM LatestYear LY;
$$ LANGUAGE sql;

--Creates instructor ids that match the scheme: namepart0000
--Name part is an all lowercase version of an instructor's name part, last
-- name (lname) is used first, and falls back to mName than fName if the name
-- part is null or an empty string
--0000 represents a sequence of numbers, which increments based on previously
-- assigned IDs (scans table rather than maintaining a counter)
CREATE OR REPLACE FUNCTION pg_temp.generateInstructorIssuedID(fName TEXT,
   mName TEXT, lName TEXT) RETURNS VARCHAR(50) AS
$$
BEGIN
   IF $3 IS NOT NULL OR TRIM($3) <> '' THEN
      RETURN (
         SELECT LOWER(makeValidIssuedID($3)) || LPAD(COUNT(*)::VARCHAR, 4, '0')
         FROM Instructor I WHERE I.SchoolIssuedID ILIKE makeValidIssuedID($3) || '%');
   ELSIF $2 IS NOT NULL OR TRIM($2) <> '' THEN
      RETURN (
         SELECT LOWER(makeValidIssuedID(2)) || LPAD(COUNT(*)::VARCHAR, 4, '0')
         FROM Instructor I WHERE I.SchoolIssuedID ILIKE makeValidIssuedID($2) || '%');
   ELSIF $1 IS NOT NULL OR TRIM($1) <> '' THEN
      RETURN (
         SELECT LOWER(makeValidIssuedID($1)) || LPAD(COUNT(*)::VARCHAR, 4, '0')
         FROM Instructor I WHERE I.SchoolIssuedID ILIKE makeValidIssuedID($1) || '%');
   ELSE
      RETURN (
         SELECT "instructor" || LPAD(COUNT(*)::VARCHAR, 4, '0')
         FROM Instructor I WHERE I.SchoolIssuedID ILIKE 'instructor%');
   END IF;
END;
$$ LANGUAGE plpgsql;

--Populates Term, Instructor, Course, Course_Section and Section_Instructor from
-- the CourseScheduleStaging table.
--importCouseSchedule() expects there to be one term of data in the table per execution.
-- That term is specified by the input parameters year and
-- seasonIdentification, which can be a name, code, or order number
--All sections in CourseScheduleStaging will be placed in the supplied term
CREATE FUNCTION pg_temp.importCourseSchedule(year INT, seasonIdentification VARCHAR(20),
                                             useSequence BOOLEAN DEFAULT TRUE
                                            )
RETURNS VOID AS
$$
DECLARE
   termInSequence BOOLEAN;
   seasonOrder NUMERIC(1,0);
BEGIN
   --Get the season order from the provided 'season identification'
   --This can be either a code, order, or name
   SELECT getSeasonOrder($2)
   INTO seasonOrder;

   --Check if the provided term is the next term chronologically after the last imported
   SELECT pg_temp.checkTermSequence($1, seasonOrder) INTO termInSequence;

   --If the season is out of order and we are forcing in-order import, throw an error
   IF NOT termInSequence AND useSequence THEN
      RAISE EXCEPTION 'Error - Supplied term is out of sequence';
   ELSIF NOT (termInSequence OR useSequence) THEN
      RAISE NOTICE 'Sequence check failed, but will be overridden';
   END IF;

   WITH termDates AS
   ( --make a list of the start and end dates for each class
      SELECT substring(date FROM 1 FOR 5) sDate,
             substring(date FROM 7 FOR 5) eDate
      FROM pg_temp.CourseScheduleStaging
   )
   --Select the extreme start and end dates from TermDates
   INSERT INTO Term(Year, Season, StartDate, EndDate)
   SELECT $1, seasonOrder,
   $1 + MIN(to_date(sDate, 'MM-DD')),
   $1 + MAX(to_date(eDate, 'MM-DD'))
   FROM termDates
   ON CONFLICT DO NOTHING;

   --Insert course into Course, concat subject || course to make 'Number'
   INSERT INTO Course(Number, DefaultTitle)
   SELECT DISTINCT ON (n) (Subject || Course) n, Title
   FROM pg_temp.CourseScheduleStaging
   WHERE NOT Subject IS NULL
   AND NOT Course IS NULL
   ON CONFLICT(Number)
      DO UPDATE
         SET DefaultTitle = EXCLUDED.DefaultTitle;

   --The first CTE inserts new instructors into Instructor, and RETURNS
   -- their full names for insertion into  Section table
   WITH insertedFullNames AS
   (
      --This CTE creates a table of individual instructor names from single section,
      -- created from the multi-name CSV list provided in the CourseSchedule CSV files
      -- The names are then split into arrays using spaces as a delimiter, creating a
      -- table of instructor name arrays
      WITH instructorSplitNames AS
      (
         SELECT DISTINCT
            regexp_split_to_array( --This split isolates FName, MName, and LName
               trim(
                  regexp_split_to_table(
                     replace(instructor, '(P)', ''), ','
                  )
               ), ' '
            ) "name"
         FROM pg_temp.CourseScheduleStaging
         --Ignore names that only have one name part
         -- EX. only have a first or last name
         -- LIKE '% %' checks for at least one space,
         -- which should mean there is at least a
         -- first and last name
         -- This method also ignores "names" like 'TBA'
         WHERE instructor LIKE '% %'
      )
      INSERT INTO Instructor (FName, MName, LName, SchoolIssuedID)
      --Select the name parts from the array into the new Instructor row
      --EX. Name[1] = FName
      SELECT Name[1],
         --If there are less than 3 enteries in the name array, we assume there is no MName
         CASE WHEN array_length(Name, 1) < 3 THEN NULL
         ELSE ( --Because some names have more than 3 'name parts', we concat all
                --parts except the first and last into MName
               SELECT string_agg(n, ' ')
               FROM unnest(Name[2:array_length(Name, 1) - 1]) n
              ) END,
         Name[array_length(Name, 1)], --We place the last name part into LName
         pg_temp.generateInstructorIssuedID(Name[1], --same code is repeated from above
                                             -- for call to generateInstructorIssuedID
            CASE WHEN array_length(Name, 1) < 3 THEN NULL
            ELSE ( --Because some names have more than 3 'name parts', we concat all
                  --parts except the first and last into MName
                  SELECT string_agg(n, ' ')
                  FROM unnest(Name[2:array_length(Name, 1) - 1]) n
               ) END,
            Name[array_length(Name, 1)])
      FROM instructorSplitNames
      ON CONFLICT DO NOTHING
      RETURNING id, FName || ' ' || COALESCE(MName || ' ', '') || LName as FullName
   ),
   --This second CTE UNIONS any existing instructors that were not inserted into
   -- Instructor so they can be used for insertion into Section
   instructorFullNames AS (
      SELECT id, FullName
      FROM insertedFullNames
      UNION
      SELECT id, FName || ' ' || COALESCE(MName || ' ', '') || LName as FullName
      FROM Instructor
   )
   INSERT INTO Section(CRN, Course, SectionNumber, Title, Term, Schedule,
                                 StartDate, EndDate,
                                 Location, Instructor1, Instructor2, Instructor3)
   SELECT oc.CRN, oc.Subject || oc.Course, oc.Section, oc.title, t.ID, oc.Days,
          --Split the date on - (dash)
          to_date($1 || '/' || (string_to_array(Date, '-'))[1], 'YYYY/MM/DD'),
          to_date($1 || '/' || (string_to_array(Date, '-'))[2], 'YYYY/MM/DD'),
          oc.Location, i1.ID, i2.ID, i3.ID
   FROM pg_temp.CourseScheduleStaging oc
   JOIN Term t ON t.Year = $1
        AND t.Season = seasonOrder
   --These joins get the instructor ID for up to three instructors teaching a section
   JOIN instructorFullNames i1 ON
        (string_to_array(oc.Instructor, ','))[1] LIKE '%' || i1.FullName || '%'
   LEFT OUTER JOIN InstructorFullNames i2 ON
        (string_to_array(oc.Instructor, ','))[2] LIKE '%' || i2.FullName || '%'
        AND NOT i2.ID = i1.ID
   LEFT OUTER JOIN InstructorFullNames i3 ON
        (string_to_array(oc.instructor, ','))[3] LIKE '%' || i3.FullName || '%'
        AND NOT (i3.ID = i2.ID OR i3.ID = i1.ID)
   WHERE NOT oc.CRN IS NULL
   ON CONFLICT DO NOTHING;
END
$$ LANGUAGE plpgsql;
