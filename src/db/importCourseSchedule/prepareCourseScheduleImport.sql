--prepareCourseScheduleImport.sql - Gradebook

--Kyle Bella, Zach Boylan, Zaid Bhujwala, Steven Rollo, Hunter Schloss, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script is part of the procedure to import Course Schedule data from a csv file
-- It is currently designed to work with data from the OpenClose system
-- it creates some temporary objects needed for import
-- it should be run before copying csv data to the staging table

--The script addSeasonMgmt.sql should have been run before running this script

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
-- This is accomplished using the expression:
-- currentYear * COUNT(Seasons) + Season + 1 =
-- newYear * COUNT(Seasons) + Season
-- Essentially, each year is mapped to a scale counting for the number of
-- seasons that are in Gradebook.  This allows a simple equality check to see
-- if the supplied term is in sequence
CREATE FUNCTION pg_temp.checkTermSequence(year INT, seasonOrder NUMERIC(1,0))
RETURNS BOOLEAN AS
$$
   --Get each term from the latest year
   WITH LatestYear AS
   (
      SELECT Year, Season
      FROM Gradebook.Term
      WHERE Year = (SELECT MAX(Year) FROM Gradebook.Term)
   )
   SELECT CASE --Check for the case when there are no terms, as we can't check
               --the sequence if it hasn't been started yet
      WHEN (SELECT COUNT(*) FROM Gradebook.Term) > 0 THEN
         (
            MAX(LY.Year) * (SELECT COUNT(*) FROM Gradebook.Season) +
            MAX(LY.Season) + 1
         ) =
         (
            $1 * (SELECT COUNT(*) FROM Gradebook.Season) + $2
         )
      ELSE
         TRUE
      END
   FROM LatestYear LY;
$$ LANGUAGE sql;

--Populates Term, Instructor, Course, Course_Section and Section_Instructor from
--the CourseScheduleStaging table - expects there to be one semster of data in the table,
--and that semester is specified by the input parameters startDate and endDate are
--for the term only, each course gets its dates from CourseScheduleStaging
CREATE FUNCTION pg_temp.importCourseSchedule(year INT, seasonIdentification VARCHAR(10),
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
   SELECT "Order"
   FROM Gradebook.getSeason($2)
   INTO seasonOrder;

   --Check if the provided term is the next term chronologicaly after the last imported
   SELECT pg_temp.checkTermSequence($1, seasonOrder) INTO termInSequence;

   --If the season is out of order and we are forcing in-order import, throw an error
   IF NOT termInSequence AND useSequence THEN
      RAISE EXCEPTION 'Error - Supplied term is out of sequence';
   ELSIF NOT (termInSequence OR useSequence) THEN
      RAISE NOTICE 'Sequence check failed, but will be overriden';
   END IF;

   WITH termDates AS
   ( --make a list of the start and end dates for each class
      SELECT substring(date FROM 1 FOR 5) sDate,
             substring(date FROM 6 FOR 5) eDate
      FROM pg_temp.CourseScheduleStaging
   )
   --Select from the Table TermDates the most extreme start and
   --end date
   INSERT INTO Gradebook.Term(Year, Season, StartDate, EndDate)
   SELECT $1,
   (
      SELECT "Order" FROM Gradebook.Season s
      WHERE s.Name = $2 OR s.Code = $2
   ),
   $1 + MIN(to_date(sDate, 'MM-DD')),
   $1 + MAX(to_date(eDate, 'MM-DD'))
   FROM termDates
   ON CONFLICT DO NOTHING;

   --Insert course into Course, concat subject || course to make 'Number'
   INSERT INTO Gradebook.Course(Number, Title)
   SELECT DISTINCT ON (n) (subject || course) n, title
   FROM pg_temp.CourseScheduleStaging
   WHERE NOT subject IS NULL
   AND NOT course IS NULL
   ON CONFLICT(Number)
      DO UPDATE
         SET Title = EXCLUDED.Title;

   --The first CTE inserts new instructors into Gradebook.Instructor, and RETURNS
   -- their full names for insertion into  Gradebook.Section table
   WITH insertedFullNames AS
   (
      --This CTE creates a table of individual instructor names from single section,
      -- created from the multi-name csv list provided in the CourseSchedule csv files
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
         WHERE instructor LIKE '% %' --Right now we can't handle names that clearly
                                     --are missing a first or last name
                                     --also ignores "names" like 'TBA'
                                     --LIKE '% %' checks for at least one space
      )
      INSERT INTO Gradebook.Instructor (FName, MName, LName)
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
         Name[array_length(Name, 1)] --We place the last name part into LName
      FROM instructorSplitNames
      ON CONFLICT DO NOTHING
      RETURNING id, FName || ' ' || COALESCE(MName || ' ', '') || LName as FullName
   ),
   --This second CTE UNIONS any existing instructors that were not inserted into
   -- Gradebook.Instructor so they can be used for insertion into Gradebook.Section
   --instructorFullNames AS
   instructorFullNames AS (
      SELECT id, FullName
      FROM insertedFullNames
      UNION
      SELECT id, FName || ' ' || COALESCE(MName || ' ', '') || LName as FullName
      FROM Gradebook.Instructor
   )
   INSERT INTO Gradebook.Section(CRN, Course, SectionNumber, Term, Schedule,
                                 StartDate, EndDate,
                                 Location, Instructor1, Instructor2, Instructor3)
   SELECT oc.crn, oc.subject || oc.course, oc.Section, t.id, oc.days,
          --Split the date on - (dash)
          to_date($1 || '/' || (string_to_array(Date, '-'))[1], 'YYYY/MM/DD'),
          to_date($1 || '/' || (string_to_array(Date, '-'))[2], 'YYYY/MM/DD'),
          oc.location, i1.id, i2.id, i3.id
   FROM pg_temp.CourseScheduleStaging oc
   JOIN Gradebook.Term t ON t.Year = $1
        AND t.Season = (SELECT "Order" FROM Gradebook.Season
                        WHERE Season.Name = $2 OR Season.Code = $2
                       )
   --Get one instructor record
   --matching is position in
   --the instructor field csv
   JOIN instructorFullNames i1 ON
        (string_to_array(oc.instructor, ','))[1] LIKE '%' || i1.FullName || '%'
   LEFT OUTER JOIN InstructorFullNames i2 ON
        (string_to_array(oc.instructor, ','))[2] LIKE '%' || i2.FullName || '%'
        AND NOT i2.id = i1.id
   LEFT OUTER JOIN InstructorFullNames i3 ON
        (string_to_array(oc.instructor, ','))[3] LIKE '%' || i3.FullName || '%'
        AND NOT (i3.id = i2.id OR i3.id = i1.id)
   WHERE NOT oc.crn IS NULL
   ON CONFLICT DO NOTHING;
END
$$ LANGUAGE plpgsql;
