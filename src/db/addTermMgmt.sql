--addTermMgmt.sql - Gradebook

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script creates functions related to terms
-- the script should be run as part of application installation

START TRANSACTION;

--Suppress messages below WARNING level for the duration of this script
SET LOCAL client_min_messages TO WARNING;

--Set schema to reference in functions and tables, pg_temp is specified
-- last for security purposes
SET LOCAL search_path TO 'alpha', 'pg_temp';


--Adds a date for a holiday, closure, or other notable event. Term references
--the PK of a Term entity. Date is the date of the event. Name is the name of
--the event (such as “Memorial Day” or “Snow Day”), classesHeld represents a
--boolean value that indicates whether classes will be in session on that day.
--Reason represents a short description of a reason for the significant date
--(such as “Holiday”, or “Weather). The school can use reason to form categories
--for significant dates.
CREATE OR REPLACE FUNCTION addSignificantDate(term INT,
                                              date DATE,
                                              name VARCHAR(30),
                                              classesHeld BOOLEAN,
                                              reason VARCHAR(30)
                                             )
   RETURNS VOID AS
$$
BEGIN
   IF ($2 < getTermStart(term) OR $2 > getTermEnd(term)) THEN
      RAISE EXCEPTION 'Significant date does not occur within given term';
   END IF;

   IF EXISTS(SELECT * FROM SignificantDate SD WHERE SD.Term = $1
               AND SD.Date = $2 AND SD.Name ILIKE $3) THEN
      RAISE EXCEPTION 'A matching significant date already exists';
   END IF;

   INSERT INTO SignificantDate VALUES ($1, $2, $3, $4, $5);
END
$$ LANGUAGE plpgsql
   SECURITY DEFINER
   SET search_path FROM CURRENT;

ALTER FUNCTION addSignificantDate(term INT, date DATE, name VARCHAR(30),
   classesHeld BOOLEAN, reason VARCHAR(30)) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION addSignificantDate(term INT, date DATE, name VARCHAR(30),
   classesHeld BOOLEAN, reason VARCHAR(30)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION addSignificantDate(term INT, date DATE,
   name VARCHAR(30), classesHeld BOOLEAN, reason VARCHAR(30))
   TO alpha_GB_RegistrarAdmin, alpha_GB_DBAdmin;


--Returns the ID of a term from a row in the Term table where the year and
--season attributes match the arguments year and season. Year is the actual
--calendar year (such as 2018), and season is the season code (‘F' for fall,
--‘S' for spring, and so on). Returns NULL if such a term does not exist.
CREATE OR REPLACE FUNCTION getTermID(year NUMERIC(4,0),
                                     season CHAR(1)
                                    )
   RETURNS INT AS
$$
   SELECT ID 
   FROM Term
   WHERE Year = $1
   AND Season = (SELECT "Order" FROM getSeason($2));
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getTermID(year NUMERIC(4,0), season CHAR(1))
   OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getTermID(year NUMERIC(4,0), season CHAR(1)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getTermID(year NUMERIC(4,0), season CHAR(1))
   TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns the start date of a row from the Term table which matches the given
--termID. Returns NULL if termID does not refer to a known Term.
CREATE OR REPLACE FUNCTION getTermStart(termID INT)
   RETURNS DATE AS
$$
   SELECT StartDate 
   FROM Term
   WHERE ID = $1;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getTermStart(termID INT) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getTermStart(termID INT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getTermStart(termID INT) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns the end date of a row from the Term table which matches the given
--termID. Returns NULL if termID does not refer to a known Term.
CREATE OR REPLACE FUNCTION getTermEnd(termID INT) RETURNS DATE AS
$$
   SELECT EndDate 
   FROM Term
   WHERE ID = $1;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getTermEnd(termID INT) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getTermEnd(termID INT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getTermEnd(termID INT) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns rows from the SignificantDate table which have a matching TermID.
--Returns no rows of no significant dates are defined for the term and NULL if
--termID does not refer to a known Term.
CREATE OR REPLACE FUNCTION getSignificantDates(termID INT)
RETURNS TABLE (Date DATE,
               Name VARCHAR(30),
               ClassesHeld BOOLEAN,
               Reason VARCHAR(30)
              ) AS
$$
   SELECT Date, Name, ClassesHeld, Reason
   FROM SignificantDate
   WHERE Term = $1;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getSignificantDates(termID INT) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getSignificantDates(termID INT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getSignificantDates(termID INT) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns the total count of courses which occur in a given term. Returns a
--count of rows in the Section table where the row's Term attribute matches the
--argument termID, and where Course is distinct. Returns 0 if no courses are
--offered in the Term and NULL if termID does not refer to a known Term.
CREATE OR REPLACE FUNCTION getTermCourseCount(termID INT) RETURNS INT AS
$$
   SELECT COUNT(DISTINCT Course)::INT --safe to assume < 2^31 courses
   FROM Section
   WHERE Term = $1;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getTermCourseCount(termID INT) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getTermCourseCount(termID INT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getTermCourseCount(termID INT) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns the total count of sections which occur during a given term. Counts
--the number of rows in the Section table where the row's Term attribute matches
--the argument termID, and where Section is distinct. Returns 0 if no sections
--are offered in the Term and NULL if termID does not refer to a known Term.
CREATE OR REPLACE FUNCTION getTermSectionCount(termID INT) RETURNS INT AS
$$
   SELECT COUNT(Section)::INT --safe to assume < 2^31 sections
   FROM Section
   WHERE Term = $1;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getTermSectionCount(termID INT) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getTermSectionCount(termID INT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getTermSectionCount(termID INT) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns the total count of instructors teaching during a given term. Returns 0
--if no instructors are teaching in the term and NULL if termID does not refer
--to a known Term.
CREATE OR REPLACE FUNCTION getTermInstructorCount(termID INT) RETURNS INT AS
$$
   SELECT COUNT(*)::INT --safe to assume < 2^31 instructors
   FROM (
      SELECT Instructor1 FROM Section WHERE Term = $1
      UNION
      SELECT Instructor2 FROM Section WHERE TERM = $1
      UNION
      SELECT Instructor3 FROM Section WHERE Term = $1 ) AS TermInstructors
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getTermInstructorCount(termID INT) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getTermInstructorCount(termID INT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getTermInstructorCount(termID INT) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns a table matching rows in the Section table, which has a schema similar
--to the Section table, but lacks SectionID and TermID columns, and includes a
--comma separated list of full instructor names rather than InstructorIDs.
--Returns no rows if no sections are offered in the term, and NULL if termID
--does not refer to a known Term.
CREATE OR REPLACE FUNCTION getTermSectionsReport(termID INT)
RETURNS TABLE (Course VARCHAR(8),
               SectionNumber VARCHAR(3),
               Title VARCHAR(100),
               CRN VARCHAR(5),
               Schedule VARCHAR(7),
               Location VARCHAR(25),
               StartDate DATE,
               EndDate DATE,
               MidtermDate DATE,
               Instructors VARCHAR
              ) AS
$$
   SELECT course, sectionnumber, title, crn, schedule, location, startdate, enddate,
   midtermdate, COALESCE(getInstructorName(instructor1),'') ||
                COALESCE('; ' || getInstructorName(instructor2),'') ||
                COALESCE('; ' || getInstructorName(instructor3), '') instructors
   FROM section WHERE term = $1;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getTermSectionsReport(termID INT) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getTermSectionsReport(termID INT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getTermSectionsReport(termID INT) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns a table matching the schema of a Section table, containing rows which
--have a matching termID. Returns no rows if no sections are offered in the
--term, and NULL if termID does not refer to a known Term.
CREATE OR REPLACE FUNCTION getTermSections(termID INT)
RETURNS TABLE (ID INT,
               Term INT,
               Course VARCHAR(8),
               SectionNumber VARCHAR(3),
               CRN VARCHAR(5),
               Title VARCHAR(100),
               Schedule VARCHAR(7),
               Location VARCHAR(25),
               StartDate DATE,
               EndDate DATE,
               MidtermDate DATE,
               Instructor1 VARCHAR,
               Instructor2 VARCHAR,
               Instructor3 VARCHAR
              ) AS
$$
   SELECT id, term, course, sectionnumber, CRN, title, schedule, location,
      startdate, enddate, midtermdate, getInstructorName(instructor1), 
      getInstructorName(instructor2), getInstructorName(instructor3)
   FROM section
   WHERE term = $1;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getTermSections(termID INT) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getTermSections(termID INT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getTermSections(termID INT) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns the total count of students which are taking a class in a given term.
--Returns 0 if no students are enrolled in the term and NULL if termID does not
--refer to a known Term.
CREATE OR REPLACE FUNCTION getTermStudentCount(termID INT) RETURNS INT AS
$$
   SELECT COUNT(DISTINCT e.student)::INT --safe to assume < 2^31 students
   FROM enrollee e JOIN section s ON e.section = s.id
   WHERE s.term = $1;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION getTermStudentCount(termID INT) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION getTermStudentCount(termID INT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getTermStudentCount(termID INT) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns a table of rows from the Course table. Without arguments, returns all
--courses. Returns courses held during the specified year. Returns no rows if a
--match is not made.
CREATE OR REPLACE FUNCTION showCoursesByYear()
RETURNS TABLE(Number VARCHAR(8),
              Title VARCHAR(100),
              InstructorFullName VARCHAR(100),
              StartDate DATE,
              EndDate DATE
             ) AS
$$
   SELECT number, title, COALESCE(getInstructorName(instructor1),'') ||
                         COALESCE('; ' || getInstructorName(instructor2),'') ||
                         COALESCE('; ' || getInstructorName(instructor3),''),
                         s.startdate, s.endDate
   FROM term t JOIN section s ON t.id = s.id JOIN course c ON s.course LIKE c.number
   ORDER BY t.year;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION showCoursesByYear() OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION showCoursesByYear() FROM PUBLIC;

GRANT EXECUTE ON FUNCTION showCoursesByYear() TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns a table of rows from the Course table. Without arguments, returns all
--courses. Returns courses held during the specified year. Returns no rows if a
--match is not made.
CREATE OR REPLACE FUNCTION showCoursesByYear(year NUMERIC(4,0))
RETURNS TABLE(Number VARCHAR(8),
              Title VARCHAR(100),
              InstructorFullName VARCHAR(100),
              StartDate DATE,
              EndDate DATE
             ) AS
$$
   SELECT number, title, COALESCE(getInstructorName(instructor1),'') ||
                         COALESCE('; ' || getInstructorName(instructor2),'') ||
                         COALESCE('; ' || getInstructorName(instructor3),''),
                         s.startdate, s.endDate
   FROM term t JOIN section s ON t.id = s.id JOIN course c ON s.course LIKE c.number
   WHERE t.year = $1;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION showCoursesByYear(year NUMERIC(4,0)) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION showCoursesByYear(year NUMERIC(4,0)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION showCoursesByYear(year NUMERIC(4,0)) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Returns a table of rows from the Course table. Without arguments, returns all
--courses. Returns courses held during the specified term. Returns no rows if a
--match is not made.
CREATE OR REPLACE FUNCTION showCoursesByTerm(termID INT)
RETURNS TABLE(Number VARCHAR(8),
              Title VARCHAR(100),
              InstructorFullName VARCHAR(100),
              StartDate DATE,
              EndDate DATE
             ) AS
$$
   SELECT number, title, COALESCE(getInstructorName(instructor1),'') ||
                         COALESCE('; ' || getInstructorName(instructor2),'') ||
                         COALESCE('; ' || getInstructorName(instructor3),''),
                         s.startdate, s.endDate
   FROM term t JOIN section s ON t.id = s.id JOIN course c ON s.course LIKE c.number
   WHERE t.id = $1;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

ALTER FUNCTION showCoursesByTerm(termID INT) OWNER TO CURRENT_USER;

REVOKE ALL ON FUNCTION showCoursesByTerm(termID INT) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION showCoursesByTerm(termID INT) TO alpha_GB_Webapp,
   alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar,
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


COMMIT;
