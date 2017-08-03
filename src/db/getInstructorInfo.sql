--getInstructorInfo.sql - Gradebook

--Zaid Bhujwala, Elly Griffin, Steven Rollo, Andrew Figueroa, Sean Murthy

--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--Function to get details of the instructor with the given e-mail address
-- performs a case-insensitive match of email address
-- the return type RECORD guarantees 0 or 1 row (Instructor.Email is unique)
-- DROP FUNCTION does not care about OUT arguments: so OK to omit them
DROP FUNCTION IF EXISTS Gradebook.getInstructor(Gradebook.Instructor.Email%TYPE);
CREATE FUNCTION
   Gradebook.getInstructor(email Gradebook.Instructor.Email%TYPE,
                           OUT ID Gradebook.Instructor.ID%TYPE,
                           OUT FName Gradebook.Instructor.FName%TYPE,
                           OUT MName Gradebook.Instructor.MName%TYPE,
                           OUT LName Gradebook.Instructor.LName%TYPE,
                           OUT Department Gradebook.Instructor.Department%TYPE
                          )
RETURNS RECORD
AS
$$

   SELECT ID, FName, MName, LName, Department
   FROM Gradebook.Instructor
   WHERE lower(Email) = lower($1);

$$ LANGUAGE sql
   STABLE --result remains the same for a given input within a transaction
   RETURNS NULL ON NULL INPUT; --No sense in looking up a NULL value

--Function to get all the years that an instructor has taught in

DROP FUNCTION IF EXISTS Gradebook.getYears(instructorID INT);
CREATE FUNCTION Gradebook.getYears(instructorID INT)
RETURNS TABLE(Year NUMERIC(4,0)) AS
$$
   SELECT DISTINCT Year
   FROM Gradebook.Term JOIN Gradebook.Section ON Term.ID  = Section.Term
   WHERE Section.Instructor1 = instructorID
        OR Section.Instructor2 = instructorID
        OR Section.Instructor3 = instructorID

$$ LANGUAGE sql;


--Function to get all seasons in a specfied year that an instructor has taught in

DROP FUNCTION IF EXISTS Gradebook.getSeasons(instructorID INT, year NUMERIC(4,0));
CREATE FUNCTION getSeasons(instructorID INT, year NUMERIC(4,0))
RETURNS TABLE(SeasonOrder NUMERIC(1,0), SeasonName VARCHAR(20)) AS
$$

SELECT DISTINCT Season."Order", Season.Name
FROM Gradebook.Season, Gradebook.Term JOIN Gradebook.Section ON Term.ID  = Section.Term
WHERE Section.Instructor1 = instructorID
    OR Section.Instructor2 = instructorID
    OR Section.Instructor3 = instructorID
    AND Term.Year = year
ORDER BY Season."Order"

$$ LANGUAGE sql;


--Function to get all courses in a specfied season,year pair
--that the instructor has taught

DROP FUNCTION IF EXISTS Gradebook.getCourses( instructorID INT, year NUMERIC(4,0), seasonOrder NUMERIC(1,0));
CREATE FUNCTION Gradebook.getCourses( instructorID INT, year NUMERIC(4,0), seasonOrder NUMERIC(1,0))
RETURNS TABLE(Course VARCHAR(8)) AS
$$

SELECT DISTINCT Course
FROM Gradebook.Course, Gradebook.Season, Gradebook.TERM JOIN Gradebook.Section ON Term.ID = Section.Term
WHERE Section.Instructor1 = instructorID
    OR Section.Instructor2 = instructorID
    OR Section.Instructor3 = instructorID
    AND Term.Year = year
    AND Season."Order" = seasonOrder
ORDER BY Course

$$ LANGUAGE sql;

--Function to get the section number(s) of a course that an instructor teaches

DROP FUNCTION IF EXISTS
   Gradebook.getSections(instructorID INT, year NUMERIC(4,0), seasonOrder NUMERIC(1,0), courseNumber VARCHAR(8));
CREATE FUNCTION
   Gradebook.getSections(instructorID INT, year NUMERIC(4,0), seasonOrder NUMERIC(1,0), courseNumber VARCHAR(8))
RETURNS TABLE(SectionID INTEGER, SectionNumber VARCHAR(3)) AS
$$

SELECT DISTINCT Section.ID, SectionNumber
FROM Gradebook.Season, Gradebook.TERM JOIN Gradebook.Section ON Term.ID = Section.Term
WHERE Section.Instructor1 = instructorID
    OR Section.Instructor2 = instructorID
    OR Section.Instructor3 = instructorID
    AND Term.Year = year
    AND Season."Order" = seasonOrder
    AND Section.Course = courseNumber
ORDER BY Section.ID

$$ LANGUAGE sql;
