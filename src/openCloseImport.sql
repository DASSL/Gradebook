--populateFromOpenClose.sql - GradeBook

--Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC: https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--A function to return individual rows when given a list of instructors that include csv lists
DROP TABLE IF EXISTS openCloseStaging;

CREATE TABLE openCloseStaging
(
   Status VARCHAR(6),
   "Level" VARCHAR(2),
   CRN  VARCHAR(5),
   Subject VARCHAR(4),
   Course VARCHAR(6),
   "Section" VARCHAR(3),
   Credits VARCHAR(15),
   Title VARCHAR(100),
   Days VARCHAR(7),
   "Time" VARCHAR(30),
   "Date" VARCHAR(15),
   Capacity INTEGER,
   Actual INTEGER,
   Remaining INTEGER,
   XL_Capacity INTEGER,
   XL_Actual INTEGER,
   XL_Remaining INTEGER,
   Location VARCHAR(25),
   Instructor VARCHAR(200)
);

CREATE OR REPLACE FUNCTION instructorUnnest("instructorNames" VARCHAR(200))
RETURNS TABLE("Name" VARCHAR(100)) AS
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
   ) "Name"
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION termImport("Year" INT, Season VARCHAR(10))
RETURNS BOOLEAN AS
$$
    WITH latestYear AS(
    SELECT "Year", Season
    FROM Term
    WHERE "Year" = (SELECT MAX("Year") FROM Term);

)

    SELECT MAX(S."Order") + LY."Year" + 1 = "Year" + (SELECT Order FROM Season WHERE Name = Season)
    FROM latestYear LY
    JOIN Season S on S."Order" = LY.Season;

SS LANGUAGE sql;

--Populates Term, Instructor, Course, Course_Section and Section_Instructor from
--the openCloseStaging table - expects there to be one semster of data in the table,
--and that semester is specified by the input parameters startDate and endDate are
--for the term only, each course gets its dates from openCloseStaging
CREATE OR REPLACE FUNCTION openCloseImport("Year" INT, Season VARCHAR(10))
RETURNS VOID AS
$$
   WITH termDates AS
   ( --Get the extreme dates from the openClose data to find the term start/end
     --this appears to get dates that are not quite correct currently
      SELECT to_date($1 || '/' || (string_to_array("Date", '-'))[1], 'YYYY/MM/DD') sDate,
             to_date($1 || '/' || (string_to_array("Date", '-'))[2], 'YYYY/MM/DD') eDate
      FROM openCloseStaging
   )
   INSERT INTO Term("Year", Season, StartDate, EndDate)
   SELECT $1, $2, MIN(sDate), MAX(eDate)
   FROM termDates
   ON CONFLICT DO NOTHING;

   --Insert course into Course, concat subject || course to make 'Number'
   INSERT INTO Course("Number", Title)
   SELECT DISTINCT ON (n) (subject || course) n, title
   FROM openCloseStaging
   WHERE NOT subject IS NULL
   AND NOT course IS NULL
   ON CONFLICT DO NOTHING;

    WITH instructorFullNames AS (
      INSERT INTO Instructor (FName, MName, LName)
      SELECT "Name"[1], CASE
         WHEN array_length("Name", 1) < 3 THEN  NULL
         ELSE (SELECT string_agg(n, ' ') FROM unnest("Name"[2:array_length("Name", 1) - 1]) n)
      END, "Name"[array_length("Name", 1)]
      FROM  ( SELECT DISTINCT string_to_array(instructorUnnest(instructor), ' ') "Name"
              FROM openCloseStaging
              WHERE instructor LIKE '% %'--Right now we can't handle names that clearly
                                         --are missing a first or last name
                                         --also ignores "names" like 'TBA'
                                         --LIKE '% %' checks for at least one space
            ) instructorNames
      RETURNING id, FName || ' ' || COALESCE(MName, '') || ' ' || LName as FullName
      )

   INSERT INTO Section(CRN, Course, SectionNumber, Term, Schedule, StartDate, EndDate,
      Location, Instructor1, Instructor2, Instructor3) --Split the date on -
   SELECT oc.crn, oc.subject || oc.course, oc."Section", t.id, oc.days,
      to_date($1 || '/' || (string_to_array("Date", '-'))[1], 'YYYY/MM/DD'),
      to_date($1 || '/' || (string_to_array("Date", '-'))[2], 'YYYY/MM/DD'),
      oc.location, i1.id, i2.id, i3.id
   FROM openCloseStaging oc
   JOIN Term t ON t."Year" = $1 AND t.Season = $2 --Get one instructor record
                                                  --matching is position in
                                                  --the instructor field csv
   JOIN instructorFullNames i1 ON (string_to_array(oc.instructor, ','))[1] LIKE '%' || i1.FullName || '%'
   LEFT OUTER JOIN InstructorFullNames i2 ON (string_to_array(oc.instructor, ','))[2] LIKE '%' || i2.FullName || '%' AND NOT i2.id = i1.id
   LEFT OUTER JOIN InstructorFullNames i3 ON (string_to_array(oc.instructor, ','))[3] LIKE '%' || i3.FullName || '%' AND NOT (i3.id = i2.id OR i3.id = i1.id)
   WHERE NOT oc.crn IS NULL
   ON CONFLICT DO NOTHING;

$$ LANGUAGE sql;
