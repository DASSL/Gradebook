--dropFunctions.sql - Gradebook

--Zaid Bhujwala, Zach Boylan, Steven Rollo, Andrew Figueroa, Jonathan Middleton,
-- Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU).
-- With contributions from Bruno DaSilva

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


START TRANSACTION;

SET LOCAL search_path TO 'gradebook', 'pg_temp';

-- addAttendanceMgmt Functions: 
DROP FUNCTION IF EXISTS getScheduleDates(startDate DATE, endDate DATE,
                            schedule VARCHAR(7)
                            );
DROP FUNCTION IF EXISTS getScheduleDates(sectionID INT);
DROP FUNCTION IF EXISTS getAttendance(sectionID INT);
DROP FUNCTION IF EXISTS getAttendance(year NUMERIC(4,0),
                            seasonIdentification VARCHAR(20),
                            course VARCHAR(8),
                            sectionNumber VARCHAR(3)
                            );

-- addInstructorMgmt Functions:
DROP FUNCTION IF EXISTS getInstructors();
DROP FUNCTION IF EXISTS getInstructor(Email Instructor.Email%TYPE);
DROP FUNCTION IF EXISTS getInstructor(instructorID INT);
DROP FUNCTION IF EXISTS getInstructorIDByIssuedID(schoolIssuedID VARCHAR(50));
DROP FUNCTION IF EXISTS getInstructorYears(instructorID INT);
DROP FUNCTION IF EXISTS getInstructorSeasons(instructorID INT,
                            year NUMERIC(4,0)
                            );
DROP FUNCTION IF EXISTS getInstructorCourses(instructorID INT,
                            year NUMERIC(4,0),
                            seasonOrder NUMERIC(1,0)
                            );
DROP FUNCTION IF EXISTS getInstructorSections(instructorID INT,
                            year NUMERIC(4,0),
                            seasonOrder NUMERIC(1,0)
                            );
DROP FUNCTION IF EXISTS getInstructorSections(instructorID INT,
                            year NUMERIC(4,0),
                            seasonOrder NUMERIC(1,0),
                            courseNumber VARCHAR(8)
                            );
DROP FUNCTION IF EXISTS getInstructorName(instructorID INT);

-- addSeasonMgmt Functions: 
DROP FUNCTION IF EXISTS getSeason(seasonIdentification VARCHAR(20));
DROP FUNCTION IF EXISTS getSeason(seasonOrder NUMERIC(1,0));
DROP FUNCTION IF EXISTS getSeasonOrder(seasonIdentification VARCHAR(20));

-- addSectionMgmt Functions:
DROP FUNCTION IF EXISTS getSectionID(year NUMERIC(4,0),
                            seasonIdentification VARCHAR(20),
                            course VARCHAR(8),
                            sectionNumber VARCHAR(3)
                            );
DROP FUNCTION IF EXISTS getSectionID(year NUMERIC(4,0),
                            seasonOrder NUMERIC(1,0),
                            course VARCHAR(8),
                            sectionNumber VARCHAR(3)
                            );
DROP FUNCTION IF EXISTS getSection(year NUMERIC(4,0),
                            seasonIdentification VARCHAR(20),
                            course VARCHAR(8), sectionNumber VARCHAR(3)
                            );
DROP FUNCTION IF EXISTS getSection(year NUMERIC(4,0), 
                            seasonOrder NUMERIC(1,0),
                            course VARCHAR(8), sectionNumber VARCHAR(3)
                            );
DROP FUNCTION IF EXISTS getSectionID(term INT,
                            courseNumber VARCHAR(8),
                            sectionNumber VARCHAR(3)
                            );
DROP FUNCTION IF EXISTS getSectionID(term INT, CRN VARCHAR(5));
DROP FUNCTION IF EXISTS getSection(sectionID INT);
DROP FUNCTION IF EXISTS searchSectionTitles(termID INT,
                            title VARCHAR(100)
                            );

-- addStudentMgmt Functions: 
DROP FUNCTION IF EXISTS getStudentSections(studentID INT,
                            year NUMERIC(4,0),
                            seasonOrder NUMERIC(1,0)
                            );
DROP FUNCTION IF EXISTS getStudentSections(studentID INT,
                            year NUMERIC(4,0),
                            seasonOrder NUMERIC(1,0),
                            courseNumber VARCHAR(8)
                            );

-- prepareRosterImport Function:
DROP FUNCTION IF EXISTS pg_temp.importRoster(year INT,
                            seasonIdentification VARCHAR(20),
                            course VARCHAR(8),
                            sectionNumber VARCHAR(3),
                            enrollmentDate DATE DEFAULT NULL
                            );

-- prepareCourseScheduleImport Functions:
DROP FUNCTION IF EXISTS pg_temp.checkTermSequence(year INT, 
                            seasonOrder NUMERIC(1,0))
DROP FUNCTION IF EXISTS pg_temp.importCourseSchedule(year INT, 
                            seasonIdentification VARCHAR(20),
                            useSequence BOOLEAN DEFAULT TRUE
                            );

COMMIT;
