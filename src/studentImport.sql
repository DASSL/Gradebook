--studentImport.sql - Gradebook

--Kyle Bella, Andrew Figueroa, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--This function imports students that are currently in the rosterStaging folder.
-- The sectionID corresponds to a section in the Section table from the Gradebook
-- schema, which is determined by Term, Course, and SectionNumber

CREATE OR REPLACE FUNCTION importStudents(Term INTEGER, Course VARCHAR(8), 
   SectionNumber VARCHAR(3), enrollmentDate DATE DEFAULT current_date) RETURNS VOID AS
$$
   INSERT INTO Student(FName, MName, LName, SchoolIssuedID, Email, Major, Year)
   SELECT r.FName, r.MName, r.MName, r.ID, r.email, r.Major, r.class
   FROM rosterStaging r
   ON CONFLICT (SchoolIssuedID) DO UPDATE FName = EXCLUDED.FName, MName = 
         EXCLUDED.MName, LName = EXCLUDED.LName, Email = EXCLUDED.email, 
		 Major = EXCLUDED.Major, Year = EXCLUDED.Year;
   
   INSERT INTO Enrollee(Student, Section, DateEnrolled, YearEnrolled, MajorEnrolled)
   WITH sectionID AS (
      SELECT ID
	  FROM public.Section S
	  WHERE Term = S.Term AND Course = S.course AND SectionNumber = S.sectionNumber
   )
   SELECT Stu.ID, sectionID.ID, $4, r.class, r.Major
   FROM rosterStaging r JOIN Student Stu ON r.ID = Stu.schoolIssuedID,
        sectionID;
$$ LANGUAGE SQL
   SET search_path TO '$user, public';