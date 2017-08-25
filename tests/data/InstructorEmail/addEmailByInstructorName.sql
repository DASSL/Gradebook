--addEmailByInstructorName.sql - Gradebook

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--This script adds e-mail address to instructors with specific names
-- the script adds e-mail address by updating Instructor.Email column in
-- each matching instructor row, provided the current value in that column is
-- not NULL

--This script is designed to work with the sample course schedules present in
-- the directory /tests/data/OpenClose;
-- the number of instructor rows affected depends on which sample course
-- schedules have already been imported. For example, running this script  after
-- importing the 2017 Spring schedule updates the e-mail address of every
-- instructor identified in this script

--The e-mail addresses assigned are syntactically valid, but they are guaranteed
-- to not be real addresses because the domain 'example.edu' cannot actually be
-- registered: W3C designates this domain for use only in examples

-- Run the script addEmailByInstructorID.sql to add e-mail addresses based on
-- instructor IDs instead of names


WITH SpecificInstructor(FName, LName, Email) AS
(
   SELECT 'Patrice', 'Boily', 'BoilyP@example.edu'
   UNION ALL
   SELECT 'Russell', 'Selzer', 'selzerr@example.edu'
   UNION ALL
   SELECT 'Stavros', 'Christofi', 'christofis@example.edu'
   UNION ALL
   SELECT 'Dennis', 'Dawson', 'dawsond@example.edu'
   UNION ALL
   SELECT 'Zuohong', 'Pan', 'PanZ@example.edu'
   UNION ALL
   SELECT 'Gancho', 'Ganchev', 'ganchevg@example.edu'
   UNION ALL
   SELECT 'Todor', 'Ivanov', 'IvanovT@example.edu'
   UNION ALL
   SELECT 'William', 'Joel', 'joelw@example.edu'
   UNION ALL
   SELECT 'Daniel', 'Coffman', 'coffmand@example.edu'
   UNION ALL
   SELECT 'Rona', 'Gurkewitz', 'GurkewitzR@example.edu'
   UNION ALL
   SELECT 'Sean', 'Murthy', 'murthys@example.edu'
)
UPDATE Gradebook.Instructor I
SET Email = SI.Email
FROM SpecificInstructor SI
WHERE I.FName = SI.FName AND I.LName = SI.LName
      AND I.Email IS NULL;
