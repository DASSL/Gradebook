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

--Populates Term, Instructor, Course, Course_Section and Section_Instructor from the openCloseImport table
--Expects there to be one semster of data in the table, and that semester is specified by the input parameters
--startDate and endDate are for the term only, each course gets its dates from openCloseImport
CREATE OR REPLACE FUNCTION populateFromOpenClose("Year" INT, Season VARCHAR(10), startDate DATE, endDate DATE)
RETURNS VOID AS
$$
   INSERT INTO Term("Year", Season, Start_Date, End_Date) VALUES($1, $2, $3, $4)
   ON CONFLICT DO NOTHING;
   
   --Use the instructorUnnest function to convert csv instructor fields to individual rows
   WITH instructorNames AS 
   (
      SELECT DISTINCT string_to_array(instructorUnnest(instructor), ' ') "Name"
      FROM openCloseImport
   )
   INSERT INTO Instructor (FName, MName, LName)
   SELECT CASE 
      WHEN array_length("Name") = 2 THEN "Name"[1], NULL, "Name"[2]
      WHEN array_length("Name") = 3 THEN "Name"[1], "Name"[2], "Name"[3]
   END
   FROM openCloseImport
   ON CONFLICT DO NOTHING;
   
   --Insert course into Course, concat subject || course to make 'Number'
   INSERT INTO Course("Number", Title)
   SELECT DISTINCT ON (n) (subject || course) n, title
   FROM openCloseImport
   WHERE NOT subject IS NULL
   AND NOT course IS NULL
   ON CONFLICT DO NOTHING;
   
   --Insert into Course_Section.  Get Term ID based on input paramenters.  Get the start and end dates of a course by
   --Splitting the date field in openCloseImport
   INSERT INTO Course_Section(CRN, Course, Section_Number, Term, Schedule, Start_Date, End_Date, Location_Taught)
   SELECT i.crn, i.subject || i.course, i."Section", t.id, i.days, to_date($1 || '/' || (string_to_array("Date", '-'))[1], 'YYYY/MM/DD'), to_date($1 || '/' || (string_to_array("Date", '-'))[2], 'YYYY/MM/DD'), i.location
   FROM openCloseImport i
   JOIN Term t ON t."Year" = $1 AND t.Season = $2
   WHERE NOT i.crn IS NULL
   ON CONFLICT DO NOTHING;
  
   --Insert into section_instructor
   --LIKE name is used to check if the instructor name is in a csv list.  This is easier than using instructorUnnest in this case
   INSERT INTO Section_Instructor
   SELECT i.id, cs.id, t.id
   FROM openCloseImport oc
   JOIN Instructor i ON oc.instructor LIKE '%' || i."Name" || '%'
   JOIN Course_Section cs ON cs.crn = oc.crn
   JOIN Term t ON t."Year" = $1 AND t.Season = $2
   ON CONFLICT DO NOTHING;
   
$$ LANGUAGE sql;