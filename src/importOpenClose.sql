--openCloseImport.sql - GradeBook

--Kyle Bella, Zach Boylan, Zaid Bhujwala, Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC: https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--A function to return individual rows when given a list of instructors that include csv lists

DROP FUNCTION IF EXISTS gradebook.instructorUnnest(instructorNames VARCHAR(200));
CREATE FUNCTION gradebook.instructorUnnest(instructorNames VARCHAR(200))
RETURNS TABLE(Name VARCHAR(100)) AS
$$
   SELECT
   trim(
      unnest
      (
         string_to_array
         (
            replace($1, '(P)', ''), ','
         )
      )
   ) "name"
$$ LANGUAGE sql;

--Checks if the supplied year and season belong to the next term in sequence.
-- Returns true if the supplied term is the next term, otherwise false.
-- This is accomplished using the expression:
-- currentYear * COUNT(Seasons) + Season + 1 =
-- newYear * COUNT(Seasons) + Season
-- Essentially, each year is mapped to a scale counting for the number of
-- seasons that are in gradebook.  This allows a simple equality check to see
-- if the supplied term is in sequence
DROP FUNCTION IF EXISTS gradebook.checkTermSequence(Year INT, Season VARCHAR(10));
CREATE FUNCTION gradebook.checkTermSequence(Year INT, Season VARCHAR(10))
RETURNS BOOLEAN AS
$$

   --Get each term from the latest year
   WITH latestYear AS
   (
      SELECT Year, Season
      FROM gradebook.Term
      WHERE Year = (SELECT MAX(Year) FROM gradebook.Term)
   )
   SELECT CASE --Check for the case when there are no terms, as we can't check
               --the sequence if it hasn't been started yet
      WHEN (SELECT COUNT(*) FROM gradebook.Term) > 0 THEN
         (
            MAX(LY.Year) * (SELECT COUNT(*) FROM gradebook.Season) + MAX(LY.Season) + 1
         ) =
         (
            $1 * (SELECT COUNT(*) FROM gradebook.Season) + (SELECT "Order" FROM gradebook.Season WHERE name = $2 OR code = $2)
         )
      ELSE
         TRUE
      END
   FROM latestYear LY

$$ LANGUAGE sql;

COMMIT;

--Populates Term, Instructor, Course, Course_Section and Section_Instructor from
--the openCloseStaging table - expects there to be one semster of data in the table,
--and that semester is specified by the input parameters startDate and endDate are
--for the term only, each course gets its dates from openCloseStaging
DROP FUNCTION IF EXISTS gradebook.importOpenClose(INT, VARCHAR(10), BOOLEAN);
CREATE FUNCTION gradebook.importOpenClose(Year INT, Season VARCHAR(10), useSequence BOOLEAN DEFAULT TRUE)
RETURNS VOID AS
$$
BEGIN

   IF NOT (SELECT gradebook.checkTermSequence($1, $2)) AND useSequence THEN
      RAISE EXCEPTION 'Error - Supplied term is out of sequence';
   ELSIF NOT (SELECT gradebook.checkTermSequence($1, $2)) AND NOT useSequence THEN
      RAISE NOTICE 'Sequence check failed, but will be overriden';
   END IF;

   WITH termDates AS
   ( --Get the extreme dates from the openClose data to find the term start/end
     --this appears to get dates that are not quite correct currently
      SELECT to_date($1 || '/' || (string_to_array(Date, '-'))[1], 'YYYY/MM/DD') sDate,
             to_date($1 || '/' || (string_to_array(Date, '-'))[2], 'YYYY/MM/DD') eDate
      FROM gradebook.openCloseStaging
   )
   INSERT INTO gradebook.Term(Year, Season, StartDate, EndDate)
   SELECT $1, (SELECT "Order" FROM gradebook.Season WHERE Season.Name = $2 OR Season.Code = $2), MIN(sDate), MAX(eDate)
   FROM gradebook.TermDates
   ON CONFLICT DO NOTHING;

   --Insert course into Course, concat subject || course to make 'Number'
   INSERT INTO gradebook.Course(Number, Title)
   SELECT DISTINCT ON (n) (subject || course) n, title
   FROM gradebook.openCloseStaging
   WHERE NOT subject IS NULL
   AND NOT course IS NULL
   ON CONFLICT DO NOTHING;

    WITH instructorFullNames AS (
      INSERT INTO gradebook.Instructor (FName, MName, LName)
      SELECT Name[1], CASE
         WHEN array_length(Name, 1) < 3 THEN  NULL
         ELSE (SELECT string_agg(n, ' ') FROM unnest(Name[2:array_length(Name, 1) - 1]) n)
      END, Name[array_length(Name, 1)]
      FROM  ( SELECT DISTINCT string_to_array(gradebook.instructorUnnest(instructor), ' ') "name"
              FROM gradebook.openCloseStaging
              WHERE instructor LIKE '% %'--Right now we can't handle names that clearly
                                         --are missing a first or last name
                                         --also ignores "names" like 'TBA'
                                         --LIKE '% %' checks for at least one space
            ) instructorNames
      RETURNING id, FName || ' ' || COALESCE(MName || ' ', '') || LName as FullName
      )

   INSERT INTO gradebook.Section(CRN, Course, SectionNumber, Term, Schedule, StartDate, EndDate,
      Location, Instructor1, Instructor2, Instructor3) --Split the date on -
   SELECT oc.crn, oc.subject || oc.course, oc.Section, t.id, oc.days,
      to_date($1 || '/' || (string_to_array(Date, '-'))[1], 'YYYY/MM/DD'),
      to_date($1 || '/' || (string_to_array(Date, '-'))[2], 'YYYY/MM/DD'),
      oc.location, i1.id, i2.id, i3.id
   FROM gradebook.openCloseStaging oc
   JOIN Term t ON t.Year = $1 AND t.Season = (SELECT "Order" FROM Season WHERE Season.Name = $2 OR Season.Code = $2)
   --Get one instructor record
   --matching is position in
   --the instructor field csv
   JOIN instructorFullNames i1 ON (string_to_array(oc.instructor, ','))[1] LIKE '%' || i1.FullName || '%'
   LEFT OUTER JOIN InstructorFullNames i2 ON (string_to_array(oc.instructor, ','))[2] LIKE '%' || i2.FullName || '%' AND NOT i2.id = i1.id
   LEFT OUTER JOIN InstructorFullNames i3 ON (string_to_array(oc.instructor, ','))[3] LIKE '%' || i3.FullName || '%' AND NOT (i3.id = i2.id OR i3.id = i1.id)
   WHERE NOT oc.crn IS NULL
   ON CONFLICT DO NOTHING;
END
$$ LANGUAGE plpgsql;

COMMIT;
