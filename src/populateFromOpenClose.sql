--populateFromOpenClose.sql - GradeBook

--Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC: https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--A function to return individual rows when given a list of instructors that include csv lists
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

--Populates Term, Instructor, Course, Course_Section and Section_Instructor from 
--the openCloseImport table - expects there to be one semster of data in the table, 
--and that semester is specified by the input parameters startDate and endDate are 
--for the term only, each course gets its dates from openCloseImport
CREATE OR REPLACE FUNCTION populateFromOpenClose("Year" INT, Season VARCHAR(10), 
   startDate DATE, endDate DATE)
RETURNS VOID AS
$$
   INSERT INTO Term("Year", Season, StartDate, EndDate) VALUES($1, $2, $3, $4)
   ON CONFLICT DO NOTHING;
   
   --Use the instructorUnnest function to convert csv instructor fields to 
   --individual rows
   WITH instructorNames AS 
   (
      SELECT DISTINCT string_to_array(instructorUnnest(instructor), ' ') "Name"
      FROM openCloseImport
      WHERE instructor LIKE '% %'--Right now we can't handle names that clearly 
                                 --are missing a first or last name
                                 --also ignores "names" like 'TBA'
                                 --LIKE '% %' checks for at least one space
   )
   INSERT INTO Instructor (FName, MName, LName)
   SELECT "Name"[1], CASE 
      WHEN array_length("Name", 1) = 2 THEN  NULL
      ELSE (SELECT string_agg(n, ' ') FROM unnest("Name"[2:array_length("Name", 1) - 1]) n)
   END, "Name"[array_length("Name", 1)]
   FROM instructorNames
   ON CONFLICT DO NOTHING;
   
   --Insert course into Course, concat subject || course to make 'Number'
   INSERT INTO Course("Number", Title)
   SELECT DISTINCT ON (n) (subject || course) n, title
   FROM openCloseImport
   WHERE NOT subject IS NULL
   AND NOT course IS NULL
   ON CONFLICT DO NOTHING;
   
   --Insert into Section.  Get Term ID based on input paramenters.  
   --Get the start and end dates of a course by
   --Splitting the date field in openCloseImport
   INSERT INTO Section(CRN, Course, SectionNumber, Term, Schedule, StartDate, EndDate, 
      Location, Instructor1, Instructor2, Instructor3) --Split the date on -
   SELECT oc.crn, oc.subject || oc.course, oc."Section", t.id, oc.days, 
      to_date($1 || '/' || (string_to_array("Date", '-'))[1], 'YYYY/MM/DD'), 
      to_date($1 || '/' || (string_to_array("Date", '-'))[2], 'YYYY/MM/DD'), oc.location,
      i1.id, i2.id, i3.id
   FROM openCloseImport oc
   JOIN Term t ON t."Year" = $1 AND t.Season = $2 --Get one instructor record
                                                  --matching is position in
                                                  --the instructor field csv
   JOIN Instructor i1 ON (string_to_array(oc.instructor, ','))[1] LIKE '%' || i1.FName || ' ' || 
      COALESCE(i1.MName, '') || ' ' || i1.LName || '%'
   JOIN Instructor i2 ON (string_to_array(oc.instructor, ','))[2] LIKE '%' || i2.FName || ' ' || 
      COALESCE(i2.MName, '') || ' ' || i2.LName || '%' AND NOT i2.id = i1.id
   JOIN Instructor i3 ON (string_to_array(oc.instructor, ','))[3] LIKE '%' || i3.FName || ' ' || 
      COALESCE(i3.MName, '') || ' ' || i3.LName || '%' AND NOT i3.id = i2.id
   WHERE NOT oc.crn IS NULL
   ON CONFLICT DO NOTHING;
  
$$ LANGUAGE sql;