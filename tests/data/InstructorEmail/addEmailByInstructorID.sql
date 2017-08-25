--addEmailByInstructorID.sql - Gradebook

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--This script adds e-mail address to instructors with specific IDs
-- the script adds e-mail address by updating Instructor.Email column in
-- each matching instructor row, provided the current value in that column is
-- not NULL

--This script is independent of the sample course schedules present in
-- the directory /tests/data/OpenClose

--The script adds e-mail addresses of the form `n@example.edu` where n is a
--number (which also happens to be an instructor ID)

--The e-mail addresses assigned are syntactically valid, but they are guaranteed
-- to not be real addresses because the domain 'example.edu' cannot actually be
-- registered: W3C designates this domain for use only in examples

--Run the script addEmailByInstructorName.sql to add e-mail addresses based on
--instructor names instead of IDs


WITH SomeInstructor(ID, Email) AS
(
   SELECT 1, '1@example.edu'
   UNION ALL
   SELECT 2, '2@example.edu'
   UNION ALL
   SELECT 3, '3@example.edu'
   UNION ALL
   SELECT 4, '4@example.edu'
   UNION ALL
   SELECT 5, '5@example.edu'
   UNION ALL
   SELECT 6, '6@example.edu'
   UNION ALL
   SELECT 7, '7@example.edu'
   UNION ALL
   SELECT 8, '8@example.edu'
   UNION ALL
   SELECT 9, '9@example.edu'
   UNION ALL
   SELECT 10, '10@example.edu'
   UNION ALL
   SELECT 11, '11@example.edu'
)
UPDATE Gradebook.Instructor I
SET Email = SI.Email
FROM SomeInstructor SI
WHERE I.ID = SI.ID AND I.Email IS NULL;
