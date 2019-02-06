--addEmailByInstructorName.sql - Gradebook

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--This script adds e-mail address to instructors who don't already have one
-- constructs unique addresses using instructor's last name and first
-- initial, and if necessary adds 1 or 2 letters from middle name, or ID;
-- assigns e-mail addresses of the form 'x@example.edu', where 'x' is a string
-- composed as outlined in the previous lines
-- does not guarantee all instructors get an e-mail address, but guarantees
-- that any assigned address is unique

--The e-mail addresses assigned are syntactically valid, but are not real
-- addresses because the domain 'example.edu' cannot actually be registered: W3C
-- designates this domain for use only in examples

--Run the script addEmailByInstructorID.sql to add e-mail addresses based on
--instructor IDs instead of names


--suppress NOTICE and other lower messages from being displayed
SET client_min_messages TO WARNING;

--use a temporary table with an index to construct unique e-mail addresses
DROP TABLE IF EXISTS pg_temp.Instructor;
CREATE TEMPORARY TABLE Instructor
(
   ID INTEGER,
   Email VARCHAR(319)
);

CREATE UNIQUE INDEX idx_Unique_Temp_Instructor
ON pg_temp.Instructor(LOWER(TRIM(Email)));


--gather existing e-mail addresses in the example.edu domain
-- need to do this so existing addresses are not reused
INSERT INTO pg_temp.Instructor
SELECT ID, Email
FROM Instructor
WHERE Email LIKE '%@example.edu';


--try assigning last name and first initial for instructors with no middle name
INSERT INTO pg_temp.Instructor
SELECT ID, CONCAT(LName, LEFT(FName, 1), '@example.edu')
FROM Instructor
WHERE Email IS NULL AND COALESCE(MName, '') = ''
ON CONFLICT DO NOTHING;


--try assigning last name and first initial
INSERT INTO pg_temp.Instructor
SELECT ID, CONCAT(LName, LEFT(FName, 1), '@example.edu')
FROM Instructor
WHERE Email IS NULL AND ID NOT IN (SELECT ID FROM pg_temp.Instructor)
ON CONFLICT DO NOTHING;


--try assigning last name, first initial, middle initial
INSERT INTO pg_temp.Instructor
SELECT ID, CONCAT(LName, LEFT(FName, 1), LEFT(MName, 1), '@example.edu')
FROM Instructor
WHERE Email IS NULL AND ID NOT IN (SELECT ID FROM pg_temp.Instructor)
ON CONFLICT DO NOTHING;


--try assigning last name, first initial, 2 letters of middle name
INSERT INTO pg_temp.Instructor
SELECT ID, CONCAT(LName, LEFT(FName, 1), LEFT(MName, 2), '@example.edu')
FROM Instructor
WHERE Email IS NULL AND ID NOT IN (SELECT ID FROM pg_temp.Instructor)
ON CONFLICT DO NOTHING;


--try assigning last name, first initial, ID
INSERT INTO pg_temp.Instructor
SELECT ID, CONCAT(LName, LEFT(FName, 1), ID, '@example.edu')
FROM Instructor
WHERE Email IS NULL AND ID NOT IN (SELECT ID FROM pg_temp.Instructor)
ON CONFLICT DO NOTHING;


--transfer e-mail addresses from the temporary table to Gradebook
UPDATE Instructor I1
SET Email = I2.Email
FROM pg_temp.Instructor I2
WHERE I1.Email IS NULL AND I1.ID = I2.ID;
