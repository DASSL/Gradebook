--createTables.sql - GradeBook

--Zaid Bhujwala, Zach Boylan, Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--remove the following two comment lines after discussion
--use camel case for table/field names containing more than one word
--use hyphen in table names when combining multiple table names as in that for a m-n relationship


DROP TABLE Course CASCADE;
DROP TABLE Term CASCADE;
DROP TABLE Instructor CASCADE;
DROP TABLE Section CASCADE;
DROP TABLE Grade CASCADE;
DROP TABLE Section_GradeTier CASCADE;
DROP TABLE Student CASCADE;
DROP TABLE Enrollee CASCADE;
DROP TABLE AttendanceStatus CASCADE;
DROP TABLE AttendanceRecord CASCADE;
DROP TABLE Section_AssessmentComponent CASCADE;
DROP TABLE Section_AssessmentItem CASCADE;
DROP TABLE Enrollee_AssessmentItem CASCADE;
DROP TABLE opencloseimport CASCADE;