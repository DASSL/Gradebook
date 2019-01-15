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

--This script creates schema, tables, and indexes for the Gradebook application
-- It also defines a few triggers on the Student and Instructor tables

--E-mail address management is based on the discussion presented at:
-- https://gist.github.com/smurthys/feba310d8cc89c4e05bdb797ca0c6cac

--This script should be run after running the script initializeDB.sql
-- in the normal course of operations, this script should not be run
-- individually, but instead should be called from the script prepareDB.sql

--This script assumes a schema named "alpha" already exists and is empty,
-- but this can be changed in the line that begins with "SET LOCAL SCHEMA"

START TRANSACTION;

--Set schema to reference in functions and tables, pg_temp is specified
-- last for security purposes
SET LOCAL search_path TO 'alpha', 'pg_temp';

CREATE TABLE IF NOT EXISTS Course
(
   --Wonder if this table will eventually need a separate ID field
   Number VARCHAR(8) NOT NULL PRIMARY KEY, --e.g., 'CS170'
   DefaultTitle VARCHAR(100) NOT NULL --e.g., 'C++ Programming'
);

ALTER TABLE Course OWNER TO CURRENT_USER;
REVOKE ALL ON Course FROM PUBLIC;
GRANT ALL ON Course TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS Season
(
   --Order denotes the sequence of seasons within a year: 0, 1,...9
   "Order" NUMERIC(1,0) PRIMARY KEY CHECK ("Order" >= 0),

   --Name is a description such as Spring and Summer: must be 2 or more chars
   -- uniqueness is enforced using a case-insensitive index
   Name VARCHAR(20) NOT NULL CHECK(LENGTH(TRIM(Name)) > 1),

   --Code is 'S', 'M', etc.: makes it easier for user to specify a season
   -- permit only A-Z (upper case)
   Code CHAR(1) NOT NULL UNIQUE CHECK(Code ~ '[A-Z]')
);

--enforce case-insensitive uniqueness of season name
CREATE UNIQUE INDEX IF NOT EXISTS idx_Unique_SeasonName ON Season(LOWER(TRIM(Name)));

ALTER TABLE Season OWNER TO CURRENT_USER;
REVOKE ALL ON Season FROM PUBLIC;
GRANT ALL ON Season TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS Term
(
   ID SERIAL NOT NULL PRIMARY KEY,
   Year NUMERIC(4,0) NOT NULL CHECK (Year > 0), --'2017'
   Season NUMERIC(1,0) NOT NULL REFERENCES Season,
   StartDate DATE NOT NULL, --date the term begins
   EndDate DATE NOT NULL, --date the term ends (last day of  "finals" week)
   UNIQUE(Year, Season)
);

ALTER TABLE Term OWNER TO CURRENT_USER;
REVOKE ALL ON Term FROM PUBLIC;
GRANT ALL ON Term TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS SignificantDate
(
   Term INTEGER REFERENCES Term,
   Date DATE NOT NULL,
   Name VARCHAR(30) NOT NULL CHECK (TRIM(Name) <> ''), --"Memorial Day", "Snow Day", ...
   ClassesHeld BOOLEAN NOT NULL,
   Reason VARCHAR(30), --"Holiday", "Weather", etc.
   PRIMARY KEY(Term, Date, Name)

   --May be later implemented as a normalized table
   --CHECK (Reason IN ('Holiday', 'Weather', 'Other'))
);

ALTER TABLE SignificantDate OWNER TO CURRENT_USER;
REVOKE ALL ON SignificantDate FROM PUBLIC;
GRANT ALL ON SignificantDate TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS Instructor
(
   ID SERIAL PRIMARY KEY,
   FName VARCHAR(50) NOT NULL,
   MName VARCHAR(50),
   LName VARCHAR(50) NOT NULL,
   SchoolIssuedID VARCHAR(50) NOT NULL UNIQUE, --cannot match any other schoolIssuedID
   Department VARCHAR(30),
   Email VARCHAR(319) CHECK(TRIM(Email) LIKE '_%@_%._%'),
   UNIQUE(FName, MName, LName),

   CONSTRAINT instructor_SchoolID_ValidChars CHECK(isValidSQLID(SchoolIssuedID))
);

--enforce case-insensitive uniqueness of instructor e-mail addresses
CREATE UNIQUE INDEX IF NOT EXISTS idx_Unique_InstructorEmail
ON Instructor(LOWER(TRIM(Email)));

--Create a partial index on the instructor names.  This enforces the CONSTRAINT
-- that only one of any (FName, NULL, LName) is unique
CREATE UNIQUE INDEX IF NOT EXISTS idx_Unique_Names_NULL
ON Instructor(FName, LName)
WHERE MName IS NULL;

ALTER TABLE Instructor OWNER TO CURRENT_USER;
REVOKE ALL ON Instructor FROM PUBLIC;
GRANT ALL ON Instructor TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS Section
(
   ID SERIAL PRIMARY KEY,
   Term INT NOT NULL REFERENCES Term,
   Course VARCHAR(8) NOT NULL REFERENCES Course,
   SectionNumber VARCHAR(3) NOT NULL, --'01', '72', etc.
   CRN VARCHAR(5) NOT NULL, --store this info for the registrar's benefit?
   Title VARCHAR(100) NOT NULL, --may or may not match course's default title
   Schedule VARCHAR(7),  --days the class meets: 'MW', 'TR', 'MWF', etc.
   Location VARCHAR(25), --likely a classroom
   StartDate DATE, --first date the section meets
   EndDate DATE, --last date the section meets
   MidtermDate DATE, --date of the "middle" of term: used to compute mid-term grade
   Instructor1 INT NOT NULL REFERENCES Instructor, --primary instructor
   Instructor2 INT REFERENCES Instructor, --optional 2nd instructor
   Instructor3 INT REFERENCES Instructor, --optional 3rd instructor
   UNIQUE(Term, Course, SectionNumber),

   --make sure instructors are distinct
   CONSTRAINT DistinctSectionInstructors
        CHECK (Instructor1 <> Instructor2
               AND Instructor1 <> Instructor3
               AND Instructor2 <> Instructor3
              )
);

ALTER TABLE Section OWNER TO CURRENT_USER;
REVOKE ALL ON Section FROM PUBLIC;
GRANT ALL ON Section TO alpha_GB_DBAdmin;



--Table to store all possible letter grades
--some universities permit A+
CREATE TABLE IF NOT EXISTS Grade
(
   Letter VARCHAR(2) NOT NULL PRIMARY KEY,
   GPA NUMERIC(4,3) NOT NULL,
   CONSTRAINT LetterChoices
      CHECK (Letter IN ('A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+',
                        'C', 'C-', 'D+', 'D', 'D-', 'F', 'W', 'SA')
            ),
   CONSTRAINT GPAChoices
      CHECK (GPA IN (4.333, 4, 3.667, 3.333, 3, 2.667, 2.333, 2, 1.667, 1.333, 1, 0.667, 0))
);

ALTER TABLE Grade OWNER TO CURRENT_USER;
REVOKE ALL ON Grade FROM PUBLIC;
GRANT ALL ON Grade TO alpha_GB_DBAdmin;



--Table to store mapping of percentage score to a letter grade: varies by section
CREATE TABLE IF NOT EXISTS Section_GradeTier
(
   Section INT REFERENCES Section,
   LetterGrade VARCHAR(2) NOT NULL REFERENCES Grade,
   LowPercentage NUMERIC(4,2) NOT NULL CHECK (LowPercentage > 0),
   HighPercentage NUMERIC(5,2) NOT NULL CHECK (HighPercentage > 0),
   PRIMARY KEY(Section, LetterGrade),
   UNIQUE(Section, LowPercentage, HighPercentage)
);

ALTER TABLE Section_GradeTier OWNER TO CURRENT_USER;
REVOKE ALL ON Section_GradeTier FROM PUBLIC;
GRANT ALL ON Section_GradeTier TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS Student
(
   ID SERIAL PRIMARY KEY,
   FName VARCHAR(50), --at least one of the name fields must be used: see below
   MName VARCHAR(50), --permit NULL in all 3 fields because some people have only one name: not sure which field will be used
   LName VARCHAR(50), --use a CONSTRAINT on names instead of NOT NULL until we understand the data
   SchoolIssuedID VARCHAR(50) NOT NULL UNIQUE,
   Email VARCHAR(319) CHECK(TRIM(Email) LIKE '_%@_%._%'),
   Year VARCHAR(30), --represents the student year. Ex: Freshman, Sophomore, Junior, Senior
   CONSTRAINT StudentNameRequired --ensure at least one of the name fields is used
      CHECK (FName IS NOT NULL OR MName IS NOT NULL OR LName IS NOT NULL),

   CONSTRAINT instructor_SchoolID_ValidChars CHECK(isValidSQLID(SchoolIssuedID))
);

--enforce case-insensitive uniqueness of student e-mail addresses
CREATE UNIQUE INDEX IF NOT EXISTS idx_Unique_StudentEmail
ON Student(LOWER(TRIM(Email)));

ALTER TABLE Student OWNER TO CURRENT_USER;
REVOKE ALL ON Student FROM PUBLIC;
GRANT ALL ON Student TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS Major
(
   Name VARCHAR(30) PRIMARY KEY  --ensures names of majors are unique
);

ALTER TABLE Major OWNER TO CURRENT_USER;
REVOKE ALL ON Major FROM PUBLIC;
GRANT ALL ON Major TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS Student_Major
(
    Student INTEGER NOT NULL REFERENCES Student,
    Major VARCHAR(30) NOT NULL REFERENCES Major
);

ALTER TABLE Student_Major OWNER TO CURRENT_USER;
REVOKE ALL ON Student_Major FROM PUBLIC;
GRANT ALL ON Student_Major TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS Enrollee
(
   Student INT NOT NULL REFERENCES Student,
   Section INT REFERENCES Section,
   DateEnrolled DATE NULL, --used to figure out which assessment components to include/exclude
   YearEnrolled VARCHAR(30) NOT NULL,
   MajorEnrolled VARCHAR(30) NOT NULL REFERENCES Major,
   MidtermWeightedAggregate NUMERIC(5,2), --weighted aggregate computed at mid-term
   MidtermGradeComputed VARCHAR(2), --will eventually move to a view
   MidtermGradeAwarded VARCHAR(2), --actual grade assigned, if any
   FinalWeightedAggregate NUMERIC(5,2), --weighted aggregate computed at end
   FinalGradeComputed VARCHAR(2),  --will eventually move to a view
   FinalGradeAwarded VARCHAR(2), --actual grade assigned
   PRIMARY KEY (Student, Section),
   FOREIGN KEY (Section, MidtermGradeComputed) REFERENCES Section_GradeTier,
   FOREIGN KEY (Section, MidtermGradeAwarded) REFERENCES Section_GradeTier,
   FOREIGN KEY (Section, FinalGradeAwarded) REFERENCES Section_GradeTier,
   FOREIGN KEY (Section, FinalGradeComputed) REFERENCES Section_GradeTier
);

ALTER TABLE Enrollee OWNER TO CURRENT_USER;
REVOKE ALL ON Enrollee FROM PUBLIC;
GRANT ALL ON Enrollee TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS AttendanceStatus
(
   Status CHAR(1) NOT NULL PRIMARY KEY, --'P', 'A', ...
   Description VARCHAR(20) NOT NULL UNIQUE --'Present', 'Absent', ...
);

ALTER TABLE AttendanceStatus OWNER TO CURRENT_USER;
REVOKE ALL ON AttendanceStatus FROM PUBLIC;
GRANT ALL ON AttendanceStatus TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS AttendanceRecord
(
   Student INT NOT NULL,
   Section INT NOT NULL,
   Date DATE NOT NULL,
   Status CHAR(1) NOT NULL REFERENCES AttendanceStatus,
   PRIMARY KEY (Student, Section, Date),
   FOREIGN KEY (Student, Section) REFERENCES Enrollee
);

ALTER TABLE AttendanceRecord OWNER TO CURRENT_USER;
REVOKE ALL ON AttendanceRecord FROM PUBLIC;
GRANT ALL ON AttendanceRecord TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS Section_AssessmentComponent
(
   Section INT NOT NULL REFERENCES Section,
   Type VARCHAR(20) NOT NULL, --"Assignment", "Quiz", "Exam",...
   Weight NUMERIC(3,2) NOT NULL CHECK (Weight >= 0), --a percentage value: 0.25, 0.5,...
   NumItems INT NOT NULL DEFAULT 1,
   PRIMARY KEY (Section, Type)
);

ALTER TABLE Section_AssessmentComponent OWNER TO CURRENT_USER;
REVOKE ALL ON Section_AssessmentComponent FROM PUBLIC;
GRANT ALL ON Section_AssessmentComponent TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS Section_AssessmentItem
(
   Section INT NOT NULL,
   Component VARCHAR(20) NOT NULL,
   SequenceInComponent INT NOT NULL  NOT NULL CHECK (SequenceInComponent > 0),
   BasePoints NUMERIC(5,2) NOT NULL CHECK (BasePoints >= 0),
   ExtraCreditPoints NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (ExtraCreditPoints >= 0),
   AssignedDate Date,
   DueDate Date,
   PRIMARY KEY(Section, Component, SequenceInComponent),
   FOREIGN KEY (Section, Component) REFERENCES Section_AssessmentComponent
);

ALTER TABLE Section_AssessmentItem OWNER TO CURRENT_USER;
REVOKE ALL ON Section_AssessmentItem FROM PUBLIC;
GRANT ALL ON Section_AssessmentItem TO alpha_GB_DBAdmin;



CREATE TABLE IF NOT EXISTS Enrollee_AssessmentItem
(
   Student INT NOT NULL,
   Section INT NOT NULL,
   Component VARCHAR(20) NOT NULL,
   SequenceInComponent INT NOT NULL,
   BasePointsEarned NUMERIC(5,2) CHECK (BasePointsEarned >= 0),
   ExtraCreditPointsEarned NUMERIC(5,2) CHECK (ExtraCreditPointsEarned >= 0),
   SubmissionDate DATE,
   Penalty NUMERIC(5,2) CHECK (Penalty >= 0),
   PRIMARY KEY(Student, Section, Component, SequenceInComponent),
   FOREIGN KEY (Student, Section) REFERENCES Enrollee,
   FOREIGN KEY (Section, Component, SequenceInComponent) REFERENCES Section_AssessmentItem
);

ALTER TABLE Enrollee_AssessmentItem OWNER TO CURRENT_USER;
REVOKE ALL ON Enrollee_AssessmentItem FROM PUBLIC;
GRANT ALL ON Enrollee_AssessmentItem TO alpha_GB_DBAdmin;


--Create function for INSERT and UPDATE triggers that check to see if
-- schoolIssuedID provided is unique among all users.
CREATE OR REPLACE FUNCTION checkUniqueSchoolID() RETURNS TRIGGER AS
$$
BEGIN
   IF EXISTS (SELECT * FROM Student S WHERE S.SchoolIssuedID
                                         ILIKE NEW.SchoolIssuedID)
      OR EXISTS (SELECT * FROM Instructor I WHERE I.SchoolIssuedID 
                                               ILIKE NEW.SchoolIssuedID)
   THEN
      IF (TG_OP <> 'UPDATE' OR OLD.SchoolIssuedID <> NEW.SchoolIssuedID) THEN
      RAISE EXCEPTION 'SchoolIssuedID ''%'' is already assigned', TG_ARGV[0];
      END IF;
   END IF;

   RETURN NEW;
END;
$$
   LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path FROM CURRENT;

   
DROP TRIGGER IF EXISTS triggerSchoolIDUniquenessInsertIns ON Instructor;
DROP TRIGGER IF EXISTS triggerSchoolIDUniquenessInsertStu ON Student;
DROP TRIGGER IF EXISTS triggerSchoolIDUniquenessUpdateIns ON Instructor;
DROP TRIGGER IF EXISTS triggerSchoolIDUniquenessUpdateStu ON Student;


CREATE TRIGGER triggerSchoolIDUniquenessInsertIns BEFORE INSERT ON Instructor
FOR EACH ROW EXECUTE PROCEDURE checkUniqueSchoolID();

CREATE TRIGGER triggerSchoolIDUniquenessInsertStu BEFORE INSERT ON Student
FOR EACH ROW EXECUTE PROCEDURE checkUniqueSchoolID();

CREATE TRIGGER triggerSchoolIDUniquenessUpdateIns
BEFORE UPDATE OF SchoolIssuedID ON Instructor
FOR EACH ROW EXECUTE PROCEDURE checkUniqueSchoolID();

CREATE TRIGGER triggerSchoolIDUniquenessUpdateStu
BEFORE UPDATE OF SchoolIssuedID ON Student
FOR EACH ROW EXECUTE PROCEDURE checkUniqueSchoolID();

COMMIT;
