--studentImport.sql - Gradebook

--Kyle Bella, Andrew Figueroa, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--During the INSERTs into the Student table, FName, MName, LName, and ID are 
-- being truncated from the staging table due to MD5 hashes being 32 characters long

--This function imports students that are currently in the rosterImport folder.
-- The sectionID corresponds to a section in the Section table from the Gradebook
-- schema, which is determined by Term, Course, and sectionNumber

CREATE OR REPLACE FUNCTION importStudents(Term INTEGER, Course VARCHAR(8), 
   SectionNumber VARCHAR(3), enrollmentDate DATE DEFAULT current_date) RETURNS VOID AS
$$
   INSERT INTO public.Student(FName, MName, LName, SchoolIssuedID, Email, Major, Year)
   SELECT substring(r.FName FOR 30), substring(r.MName FOR 30), substring(r.MName FOR 30),
         substring(r.ID FOR 30), r.email, r.Major, r.class
   FROM rosterStaging r
   ON CONFLICT (SchoolIssuedID) DO NOTHING;
   
   INSERT INTO public.Enrollee(Student, Section, EnrollmentDate)
   WITH sectionID AS (
      SELECT ID
	  FROM public.Section S
	  WHERE Term = S.Term AND Course = S.course AND SectionNumber = S.sectionNumber
   )
   SELECT Stu.ID, sectionID.ID, $4
   FROM rosterImport r JOIN Student Stu ON substring(r.ID FOR 30) = Stu.schoolIssuedID,
        sectionID;
$$ LANGUAGE SQL
   SET search_path TO '$user, public';