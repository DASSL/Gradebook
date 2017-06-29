--studentImport.sql - Gradebook

--Kyle Bella, Andrew Figueroa, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--During the INSERTs into the Student table, FName, MName, LName, and ID are being truncated
-- from the staging table due to MD5 hashes being 32 characters long

--This function imports students that are currently in the rosterImport folder.
-- The sectionID corresponds to a section in the Section table from the Gradebook schema

CREATE OR REPLACE FUNCTION importStudents(SectionID INTEGER, enrollmentDate DATE 
   DEFAULT current_date) RETURNS VOID AS
$$
   INSERT INTO Student(FName, MName, LName, SchoolIssuedID, Email, Major, Year)
   SELECT substring(I.FName FOR 30), substring(I.MName FOR 30), substring(I.MName FOR 30),
         substring(I.ID FOR 30), I.email, I.Major, I.class
   FROM rosterImport I
   ON CONFLICT (SchoolIssuedID) DO NOTHING; --Ignore repeated students

   INSERT INTO Enrollee(Student, Section, EnrollmentDate)
   SELECT Stu.ID, $1, $2
   FROM rosterImport r JOIN Student Stu ON substring(r.ID FOR 30) = Stu.schoolIssuedID;
$$ LANGUAGE SQL;


--This function has the same behavior as the previous function, but uses Term, Course, and SectionNumber as an alternative to SectionID

CREATE OR REPLACE FUNCTION importStudents(Term INTEGER, Course VARCHAR(8), 
   SectionNumber VARCHAR(3), enrollmentDate DATE DEFAULT current_date) RETURNS VOID AS
$$
   INSERT INTO Student(FName, MName, LName, SchoolIssuedID, Email, Major, Year)
   SELECT I.FName, I.MName, I.MName, I.ID, I.email, I.Major, I.class
   FROM rosterImport I
   ON CONFLICT (SchoolIssuedID) DO UPDATE FName = EXCLUDED.FName, MName = EXCLUDED.MName, LName = EXCLUDED.LName,
         Email = EXCLUDED.email, Major = EXCLUDED.Major, Year = EXCLUDED.class;
   
   INSERT INTO Enrollee(Student, Section, DateEnrolled, YearEnrolled, MajorEnrolled)
   WITH sectionID AS (
      SELECT ID
	  FROM Section S
	  WHERE Term = S.Term AND Course = S.course AND SectionNumber = S.sectionNumber
   )
   SELECT Stu.ID, sectionID.ID, $4, r.class, r.Major
   FROM rosterImport r JOIN Student Stu ON substring(r.ID FOR 30) = Stu.schoolIssuedID,
        sectionID;
$$ LANGUAGE SQL;