--addEmailByInstructorID.sql - Gradebook

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--This script adds e-mail address to instructors who don't already have one
-- constructs unique addresses using instructor ID;
-- assigns e-mail addresses of the form 'n@example.edu', where 'n' is an
-- instructor ID;
-- does not guarantee all instructors get an e-mail address, but guarantees
-- that any assigned address is unique

--The e-mail addresses assigned are syntactically valid, but are real addresses
-- because the domain 'example.edu' cannot actually be registered: W3C
-- designates this domain for use only in examples

--Run the script addEmailByInstructorName.sql to add e-mail addresses based on
--instructor names instead of IDs


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


--try assigning ID
INSERT INTO pg_temp.Instructor
SELECT ID, CONCAT(ID, '@example.edu')
FROM Gradebook.Instructor
WHERE Email IS NULL
ON CONFLICT DO NOTHING;


--transfer e-mail addresses from the temporary table to Gradebook
UPDATE Gradebook.Instructor I1
SET Email = I2.Email
FROM pg_temp.Instructor I2
WHERE I1.Email IS NULL AND I1.ID = I2.ID;
