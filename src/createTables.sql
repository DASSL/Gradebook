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


CREATE SCHEMA IF NOT EXISTS Gradebook;


CREATE TABLE Gradebook.Course
(
   --Wonder if this table will eventually need a separate ID field
   Number VARCHAR(8) NOT NULL PRIMARY KEY, --e.g., 'CS170'
   Title VARCHAR(100) NOT NULL --e.g., 'C++ Programming'
);


CREATE TABLE Gradebook.Season
(
   "Order" NUMERIC(1,0) PRIMARY KEY CHECK ("Order" >= 0), --sequence of seasons within a year
   Name VARCHAR(20) NOT NULL UNIQUE,
   Code CHAR(1) NOT NULL UNIQUE --reference for the season: 'S', 'M', 'F', 'I', etc.
);

--Populate the Season table
--Values based on Term information found in OpenClose
INSERT INTO Gradebook.Season VALUES('0','Spring','S');
INSERT INTO Gradebook.Season VALUES('1','Spring_Break','B');
INSERT INTO Gradebook.Season VALUES('2','Summer','M');
INSERT INTO Gradebook.Season VALUES('3','Fall','F');
INSERT INTO Gradebook.Season VALUES('4','Intersession','I');


CREATE TABLE Gradebook.Term
(
   ID SERIAL NOT NULL PRIMARY KEY,
   Year NUMERIC(4,0) NOT NULL CHECK (Year > 0), --'2017'
   Season NUMERIC(1,0) NOT NULL REFERENCES Gradebook.Season,
   StartDate DATE NOT NULL, --date the term begins
   EndDate DATE NOT NULL, --date the term ends (last day of  "finals" week)
   UNIQUE(Year, Season)
);


CREATE TABLE Gradebook.Instructor
(
   ID SERIAL PRIMARY KEY,
   FName VARCHAR(50) NOT NULL,
   MName VARCHAR(50),
   LName VARCHAR(50) NOT NULL,
   Department VARCHAR(30)
);


CREATE TABLE Gradebook.Section
(
   ID SERIAL PRIMARY KEY,
   Term INTEGER NOT NULL REFERENCES Gradebook.Term,
   Course VARCHAR(8) NOT NULL REFERENCES Gradebook.Course,
   SectionNumber VARCHAR(3) NOT NULL, --'01', '72', etc.
   CRN VARCHAR(5) NOT NULL, --store this info for the registrar's benefit?
   Schedule VARCHAR(7),  --days the class meets: 'MW', 'TR', 'MWF', etc.
   Location VARCHAR(25), --likely a classroom
   StartDate DATE, --first date the section meets
   EndDate DATE, --last date the section meets
   MidtermDate DATE, --date of the "middle" of term: used to compute mid-term grade
   Instructor1 INTEGER NOT NULL REFERENCES Gradebook.Instructor, --primary instructor
   Instructor2 INTEGER REFERENCES Gradebook.Instructor, --optional 2nd instructor
   Instructor3 INTEGER REFERENCES Gradebook.Instructor, --optional 3rd instructor
   UNIQUE(Term, Course, SectionNumber),
   CONSTRAINT DistinctSectionInstructors --make sure instructors are distinct
        CHECK (Instructor1 <> Instructor2
            AND Instructor1 <> Instructor3
            AND Instructor2 <> Instructor3
        )
);


--Removed Section_Instructor by accommodating 3 instructors in Section table
--CREATE TABLE Gradebook.Section_Instructor();


--Table to store all possible letter grades
--some universities permit A+
CREATE TABLE Gradebook.Grade
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


--Values used by most US universities: move to a different file
INSERT INTO Gradebook.Grade VALUES('A+', 4.333);
INSERT INTO Gradebook.Grade VALUES('A', 4);
INSERT INTO Gradebook.Grade VALUES('A-', 3.667);
INSERT INTO Gradebook.Grade VALUES('B+', 3.333);
INSERT INTO Gradebook.Grade VALUES('B', 3);
INSERT INTO Gradebook.Grade VALUES('B-', 2.667);
INSERT INTO Gradebook.Grade VALUES('C+', 2.333);
INSERT INTO Gradebook.Grade VALUES('C', 2);
INSERT INTO Gradebook.Grade VALUES('C-', 1.667);
INSERT INTO Gradebook.Grade VALUES('D+', 1.333);
INSERT INTO Gradebook.Grade VALUES('D', 1);
INSERT INTO Gradebook.Grade VALUES('D-', 0.667);
INSERT INTO Gradebook.Grade VALUES('F', 0);
INSERT INTO Gradebook.Grade VALUES('W', 0);
INSERT INTO Gradebook.Grade VALUES('SA', 0);


--Table to store mapping of percentage score to a letter grade: varies by section
CREATE TABLE Gradebook.Section_GradeTier
(
   Section INTEGER REFERENCES Gradebook.Section,
   LetterGrade VARCHAR(2) NOT NULL REFERENCES Gradebook.Grade,
   LowPercentage NUMERIC(4,2) NOT NULL CHECK (LowPercentage > 0),
   HighPercentage NUMERIC(5,2) NOT NULL CHECK (HighPercentage > 0),
   PRIMARY KEY(Section, LetterGrade),
   UNIQUE(Section, LowPercentage, HighPercentage)
);


CREATE TABLE Gradebook.Student
(
   ID SERIAL PRIMARY KEY,
   FName VARCHAR(50), --at least one of the name fields must be used: see below
   MName VARCHAR(50), --permit NULL in all 3 fields because some people have only one name: not sure which field will be used
   LName VARCHAR(50), --use a CONSTRAINT on names instead of NOT NULL until we understand the data
   SchoolIssuedID VARCHAR(50) NOT NULL UNIQUE,
   Email VARCHAR(100) NOT NULL UNIQUE,
   Major VARCHAR(50), --non-matriculated students are not required to have a major
   Year VARCHAR(30), --represents the student year. Ex: Freshman, Sophomore, Junior, Senior
   CONSTRAINT StudentNameRequired --ensure at least one of the name fields is used
      CHECK (FName IS NOT NULL OR MName IS NOT NULL OR LName IS NOT NULL)
);


CREATE TABLE Gradebook.Enrollee
(
   Student INTEGER NOT NULL REFERENCES Gradebook.Student,
   Section INTEGER REFERENCES Gradebook.Section,
   DateEnrolled DATE NULL, --used to figure out which assessment components to include/exclude
   YearEnrolled VARCHAR(30) NOT NULL,
   MajorEnrolled VARCHAR(50) NOT NULL,
   MidtermWeightedAggregate NUMERIC(5,2), --weighted aggregate computed at mid-term
   MidtermGradeComputed VARCHAR(2), --will eventually move to a view
   MidtermGradeAwarded VARCHAR(2), --actual grade assigned, if any
   FinalWeightedAggregate NUMERIC(5,2), --weighted aggregate computed at end
   FinalGradeComputed VARCHAR(2),  --will eventually move to a view
   FinalGradeAwarded VARCHAR(2), --actual grade assigned
   PRIMARY KEY (Student, Section),
   FOREIGN KEY (Section, MidtermGradeAwarded) REFERENCES Gradebook.Section_GradeTier,
   FOREIGN KEY (Section, FinalGradeAwarded) REFERENCES Gradebook.Section_GradeTier
);


--Table to store all possible attendance statuses
CREATE TABLE Gradebook.AttendanceStatus
(
   Status CHAR(1) NOT NULL PRIMARY KEY, --'P', 'A', E', ...
   Description VARCHAR(20) NOT NULL UNIQUE --'Present', 'Absent', 'Explained', ...
);


CREATE TABLE Gradebook.AttendanceRecord
(
   Student INTEGER NOT NULL,
   Section INTEGER NOT NULL,
   Date DATE NOT NULL,
   Status CHAR(1) NOT NULL REFERENCES Gradebook.AttendanceStatus,
   PRIMARY KEY (Student, Section, Date),
   FOREIGN KEY (Student, Section) REFERENCES Gradebook.Enrollee
);


CREATE TABLE Gradebook.Section_AssessmentComponent
(
   Section INTEGER NOT NULL REFERENCES Gradebook.Section,
   Type VARCHAR(20) NOT NULL, --"Assignment", "Quiz", "Exam",...
   Weight NUMERIC(3,2) NOT NULL CHECK (Weight >= 0), --a percentage value: 0.25, 0.5,...
   NumItems INTEGER NOT NULL DEFAULT 1,
   PRIMARY KEY (Section, Type)
);


CREATE TABLE Gradebook.Section_AssessmentItem
(
   Section INTEGER NOT NULL,
   Component VARCHAR(20) NOT NULL,
   SequenceInComponent INTEGER NOT NULL  NOT NULL CHECK (SequenceInComponent > 0),
   BasePoints NUMERIC(5,2) NOT NULL CHECK (BasePoints >= 0),
   ExtraCreditPoints NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (ExtraCreditPoints >= 0),
   AssignedDate Date,
   DueDate Date,
   PRIMARY KEY(Section, Component, SequenceInComponent),
   FOREIGN KEY (Section, Component) REFERENCES Gradebook.Section_AssessmentComponent
);


CREATE TABLE Gradebook.Enrollee_AssessmentItem
(
   Student INTEGER NOT NULL,
   Section INTEGER NOT NULL,
   Component VARCHAR(20) NOT NULL,
   SequenceInComponent INTEGER NOT NULL,
   BasePointsEarned NUMERIC(5,2) CHECK (BasePointsEarned >= 0),
   ExtraCreditPointsEarned NUMERIC(5,2) CHECK (ExtraCreditPointsEarned >= 0),
   SubmissionDate DATE,
   Penalty NUMERIC(5,2) CHECK (Penalty >= 0),
   PRIMARY KEY(Student, Section, Component, SequenceInComponent),
   FOREIGN KEY (Student, Section) REFERENCES Gradebook.Enrollee,
   FOREIGN KEY (Section, Component, SequenceInComponent) REFERENCES Gradebook.Section_AssessmentItem
);
