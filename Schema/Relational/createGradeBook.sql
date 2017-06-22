--createGradeBook.sql - GradeBook

--Zaid Bhujwala, Zach Boylan, Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC: https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

CREATE TABLE Student
(
   ID SERIAL PRIMARY KEY, --Changed to SERIAL
   FName VARCHAR(30) NOT NULL, 
   MName VARCHAR(30), 
   LName VARCHAR(30) NOT NULL,
   Email VARCHAR(50) NOT NULL,
   Major VARCHAR(15) NOT NULL,
   Standing VARCHAR(10) NOT NULL
);

CREATE TABLE Course
(
   "Number" VARCHAR(8) PRIMARY KEY, --Changed to Number from Name
   Title VARCHAR(100) NOT NULL --Made longer
);

CREATE TABLE Term
(
   ID SERIAL PRIMARY KEY,
   "Year" INTEGER NOT NULL, 
   Season VARCHAR(10) NOT NULL, 
   Start_Date DATE NOT NULL, 
   End_Date DATE NOT NULL,
   UNIQUE("Year", Season)
);

CREATE TABLE Instructor
(
   ID SERIAL PRIMARY KEY, --IDs should use SERIAL
   "Name" VARCHAR(100) NOT NULL UNIQUE, --Changing to one Name field only for now
   Department VARCHAR(30)
);

CREATE TABLE Course_Section
(
   ID SERIAL PRIMARY KEY,
   CRN VARCHAR(5) NOT NULL, 
   Course VARCHAR(8) NOT NULL REFERENCES Course,
   Section_Number VARCHAR(3) NOT NULL,
   --Instructor_ID INTEGER NOT NULL REFERENCES Instructor,  --Should not exists becacuse of Section_Instructor
   Term INTEGER NOT NULL REFERENCES Term, 
   Schedule VARCHAR(5),  --example: MW, TR, MWF (Some of these are NULL)
   --Midterm_Date date NOT NULL, --Commenting this out for now, until we have a way to get MidtermDate
   Start_Date DATE,
   End_Date DATE,
   Location_Taught VARCHAR(25) --Way 2 short
);

CREATE TABLE Section_Instructor
(
   Instructor INTEGER NOT NULL REFERENCES Instructor,
   Course_Section INTEGER NOT NULL REFERENCES Course_Section,
   Term INTEGER NOT NULL REFERENCES Term,
   PRIMARY KEY(Instructor, Course_Section, Term) --Needs year + season in PK too
);

CREATE TABLE Grade
(
   LetterGrade char(1) PRIMARY KEY --+/-?
);

CREATE TABLE Section_Grade_Tier
(  
   Course_Section INTEGER REFERENCES Course_Section, 
   Letter_Grade character(1) NOT NULL REFERENCES Grade, -- references must come after create table statement
   Low_Percentage NUMERIC(4,2),
   High_Percentage NUMERIC(5,2), 
   PRIMARY KEY(Course_Section, Letter_Grade)
);

CREATE TABLE Attendance_Record
(
   "Date" DATE NOT NULL, 
   Student INTEGER NOT NULL REFERENCES Student, 
   Course_Section INTEGER REFERENCES Course_Section,
   Status_Code character(1) NOT NULL, 
   PRIMARY KEY("Date", Student, Course_Section)
);

CREATE TABLE Assessment_Component
(
   "Name" VARCHAR(20) NOT NULL,
   Course_Section INTEGER REFERENCES Course_Section, 
   Weight NUMERIC(2,2) NOT NULL,
   Num_Assignments INTEGER NOT NULL,  
   PRIMARY KEY("Name", Course_Section)
);

CREATE TABLE Assessment_Item
(
   Component_Name VARCHAR(20) NOT NULL,
   Assessment_Num INTEGER NOT NULL,
   Course_Section INTEGER NOT NULL, 
   Base_Points INTEGER NOT NULL,
   ExtraCredit_Points INTEGER NOT NULL,
   PRIMARY KEY(Component_Name, Assessment_Num, Course_Section),
   FOREIGN KEY (Component_Name, Course_Section) REFERENCES Assessment_Component
);

CREATE TABLE Enrollee
(
   Student_ID INTEGER NOT NULL REFERENCES Student, 
   Course_Section INTEGER REFERENCES Course_Section,
   Enrollment_Date date NOT NULL,
   Midterm_Grade_Computed Numeric(5,2),  -- NOT NULL? Computation?
   Midterm_Grade_Awarded character(1),  -- NOT NULL?
   Final_Grade_Computed Numeric(5,2),  -- NOT NULL? Computation?
   Final_Grade_Awarded character(1),  -- NOT NULL?
   FOREIGN KEY (Course_Section, Midterm_Grade_Awarded) REFERENCES Section_Grade_Tier,
   FOREIGN KEY (Course_Section, Final_Grade_Awarded) REFERENCES Section_Grade_Tier,
   PRIMARY KEY(Student_ID, Course_Section)
);

CREATE TABLE Submission
(
   Student_ID INTEGER NOT NULL, 
   Course_Section INTEGER NOT NULL,
   Component_Name VARCHAR(20) NOT NULL,
   Assessment_Num integer NOT NULL,
   Base_Points_Earned Numeric(5,2),
   ExtraCredit_Points_Earned Numeric(5,2),
   Handout_Date date,
   Submission_Date date,
   Penalty Numeric(5,2),
   PRIMARY KEY(Student_ID, Course_Section, Component_Name, Assessment_Num), 
   FOREIGN KEY (Student_ID, Course_Section) REFERENCES Enrollee,
   FOREIGN KEY (Component_Name, Assessment_Num, Course_Section) REFERENCES Assessment_Item
);