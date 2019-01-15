--createTables.sql - Gradebook

--Edited by Bruno DaSilva, Andrew Figueroa, and Jonathan Middleton (Team Alpha)
-- in support of CS305 coursework at Western Connecticut State University.

--Licensed to others under CC 4.0 BY-SA-NC

--This work is a derivative of Gradebook, originally developed by:

--Zaid Bhujwala, Zach Boylan, Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--remove the following two comment lines after discussion
--use camel case for table/field names containing more than one word
--use hyphen in table names when combining multiple table names as in that for a m-n relationship

START TRANSACTION;


--Set schema to reference in functions and tables, pg_temp is specified
-- last for security purposes
SET LOCAL search_path TO 'alpha', 'pg_temp';


DROP TABLE IF EXISTS Course CASCADE;
DROP TABLE IF EXISTS Season CASCADE;
DROP TABLE IF EXISTS Term CASCADE;
DROP TABLE IF EXISTS SignificantDate CASCADE;
DROP TABLE IF EXISTS Instructor CASCADE;
DROP TABLE IF EXISTS Section CASCADE;
DROP TABLE IF EXISTS Grade CASCADE;
DROP TABLE IF EXISTS Section_GradeTier CASCADE;
DROP TABLE IF EXISTS Student CASCADE;
DROP TABLE IF EXISTS Major CASCADE;
DROP TABLE IF EXISTS Student_Major CASCADE;
DROP TABLE IF EXISTS Enrollee CASCADE;
DROP TABLE IF EXISTS AttendanceStatus CASCADE;
DROP TABLE IF EXISTS AttendanceRecord CASCADE;
DROP TABLE IF EXISTS Section_AssessmentComponent CASCADE;
DROP TABLE IF EXISTS Section_AssessmentItem CASCADE;
DROP TABLE IF EXISTS Enrollee_AssessmentItem CASCADE;
DROP TABLE IF EXISTS openCloseStaging CASCADE;


COMMIT;
