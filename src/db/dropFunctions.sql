--dropFunctions.sql - Gradebook

--Created by Bruno DaSilva, Andrew Figueroa, and Jonathan Middleton (Team Alpha)
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

SET LOCAL search_path TO 'alpha', 'pg_temp';
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

-- addCourseMgmt Functions: 
DROP FUNCTION IF EXISTS changeCourseDefaultTitle(courseNumber VARCHAR(8),
                                                    newDefaultTitle VARCHAR(100));
DROP FUNCTION IF EXISTS searchCourseTitles(titleSearch VARCHAR(100));
DROP FUNCTION IF EXISTS addCourse(name VARCHAR(8),
                                     defaultTitle VARCHAR(100));
DROP FUNCTION IF EXISTS getCourseDefaultTitle(courseNumber VARCHAR(8));

-- addHelpers Function:
DROP FUNCTION IF EXISTS isValidSQLID(ID VARCHAR);

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
DROP FUNCTION IF EXISTS getSection(year NUMERIC(4,0), seasonOrder NUMERIC(1,0),
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
DROP FUNCTION IF EXISTS getStudentYears(studentID INT);
DROP FUNCTION IF EXISTS getYearsAsStudent();
DROP FUNCTION IF EXISTS getStudentSeasons(studentID INT,
                                             year NUMERIC(4,0)
                                            );
DROP FUNCTION IF EXISTS getSeasonsAsStudent(year NUMERIC(4,0));
DROP FUNCTION IF EXISTS addStudent(fName VARCHAR(50),
                                      mName VARCHAR(50),
                                      lName VARCHAR(50),
                                      schoolIssuedID VARCHAR(50),
                                      email VARCHAR(319),
                                      year VARCHAR(30)
                                     );
DROP FUNCTION IF EXISTS assignMajor(student INT,
                                       major VARCHAR(30)
                                      );
DROP FUNCTION IF EXISTS revokeMajor(student INT,
                                       major VARCHAR(30)
                                      );
DROP FUNCTION IF EXISTS searchStudent(fname VARCHAR(50),
                                         mName VARCHAR(50),
                                         lName VARCHAR(50)
                                        );
DROP FUNCTION IF EXISTS getMyStudentID();
DROP FUNCTION IF EXISTS getStudentIDByIssuedID(schoolIssuedID VARCHAR(50));
DROP FUNCTION IF EXISTS getStudentIDbyEmail(email VARCHAR(319));
DROP FUNCTION IF EXISTS assignMidtermGrade(student INT, sectionID INT
                                              midtermGradeAwarded VARCHAR(2)
                                             );
DROP FUNCTION IF EXISTS assignFinalGrade(student INT, sectionID INT,
                                            finalGradeAwarded VARCHAR(2)
                                           );
DROP FUNCTION IF EXISTS getStudentSections(studentID INT,
                                                year NUMERIC(4,0),
                                                seasonOrder NUMERIC(1,0)
                                               );
DROP FUNCTION IF EXISTS getStudentSections(studentID INT,
                                                year NUMERIC(4,0),
                                                seasonOrder NUMERIC(1,0),
                                                courseNumber VARCHAR(8)
                                               );

-- addTermMgmt Functions:
DROP FUNCTION IF EXISTS addSignificantDate(term INT,
                                              date DATE,
                                              name VARCHAR(30),
                                              classesHeld BOOLEAN,
                                              reason VARCHAR(30)
                                             );
DROP FUNCTION IF EXISTS getTermID(year NUMERIC(4,0),
                                     season CHAR(1)
                                    );
DROP FUNCTION IF EXISTS getTermStart(termID INT);
DROP FUNCTION IF EXISTS getTermEnd(termID INT);
DROP FUNCTION IF EXISTS getSignificantDates(termID INT);
DROP FUNCTION IF EXISTS getTermCourseCount(termID INT);
DROP FUNCTION IF EXISTS getTermSectionCount(termID INT);
DROP FUNCTION IF EXISTS getTermInstructorCount(termID INT);
DROP FUNCTION IF EXISTS getTermSectionsReport(termID INT);
DROP FUNCTION IF EXISTS getTermSections(termID INT);
DROP FUNCTION IF EXISTS getTermStudentCount(termID INT);
DROP FUNCTION IF EXISTS showCoursesByYear();
DROP FUNCTION IF EXISTS showCoursesByYear(year NUMERIC(4,0));
DROP FUNCTION IF EXISTS showCoursesByTerm(termID INT);

-- prepareRosterImport Function:
DROP FUNCTION IF EXISTS pg_temp.importRoster(year INT,
                                                seasonIdentification VARCHAR(20),
                                                course VARCHAR(8),
                                                sectionNumber VARCHAR(3),
                                                enrollmentDate DATE DEFAULT NULL
                                               );

-- prepareCourseScheduleImport Functions:
DROP FUNCTION IF EXISTS pg_temp.checkTermSequence(year INT, seasonOrder NUMERIC(1,0))
DROP FUNCTION IF EXISTS pg_temp.importCourseSchedule(year INT, seasonIdentification VARCHAR(20),
                                             useSequence BOOLEAN DEFAULT TRUE
                                            );

COMMIT;
