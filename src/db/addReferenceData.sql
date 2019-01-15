--addReferenceData.sql - Gradebook

--Zaid Bhujwala, Zach Boylan, Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script populates tables that contain "reference data"
-- installers should review and customize the data to meet their requirement

--This script should be run after the script createTables.sql is run
-- the script should be run before adding rows into any other tables because
-- the rows added here influence all other data, either directly or indirectly 

START TRANSACTION;

--Set schema to reference in functions and tables, pg_temp is specified
-- last for security purposes
SET LOCAL search_path TO 'alpha', 'pg_temp';


--populate the Season table with values found in the OpenClose system at WCSU
-- the value of the "Order" column should start with zero and be incremented by
-- 1 with each season;
-- the order of values in the "Order" column must follow the order of seasons
-- in the calendar year; not in the school's academic year. For example, the
-- rows inserted here say that Spring is the first season classes are held in a
-- calendar year, followed by "Spring_Break" and so on
INSERT INTO Season("Order", Name, Code)
VALUES
   ('0','Spring','S'),  ('1','Spring_Break','B'),  ('2','Summer','M'),
   ('3','Fall','F'),    ('4','Intersession','I')
ON CONFLICT DO NOTHING;



--populate the Grade table with values used at most US schools
-- each record establishes a correspondence between a letter grade and eqt. GPA;
-- see schema of Grade for values permitted in these columns
INSERT INTO Grade(Letter, GPA)
VALUES
   ('A+', 4.333), ('A', 4),      ('A-', 3.667), ('B+', 3.333), ('B', 3),
   ('B-', 2.667), ('C+', 2.333), ('C', 2),      ('C-', 1.667), ('D+', 1.333),
   ('D', 1),      ('D-', 0.667), ('F', 0),      ('W', 0),      ('SA', 0)
ON CONFLICT DO NOTHING;



--add some well-known attendance statuses
-- each record creates a correspondence between an internal status code and a
-- description that is displayed to the user
INSERT INTO AttendanceStatus(Status, Description)
VALUES
   ('P', 'Present'),           ('A', 'Absent'),   ('E', 'Explained'),
   ('S', 'Stopped Attending'), ('X', 'Excused'),  ('N', 'Not Registered'),
   ('C', 'Cancelled'),         ('W', 'Withdrawn')
ON CONFLICT DO NOTHING;


COMMIT;
