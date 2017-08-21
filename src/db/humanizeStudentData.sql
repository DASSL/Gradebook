/*
humanizeStudentData.sql - Gradebook

Zaid Bhujwala, Sean Murthy
Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)


(C) 2017- DASSL. ALL RIGHTS RESERVED.
Licensed to others under CC 4.0 BY-SA-NC:
https://creativecommons.org/licenses/by-nc-sa/4.0/

PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

This script replaces hash values that may be in the name columns of Student
table to readable human names: hashes might have been placed in name columns as
part of a process to anonymize student details.

The script detects an anonymized row by testing if all name columns in the row
contain only hexadecimal digits. It then replaces the value in each name column
of matching rows with random entries from an appropriate human-name table.

List of human names obtained from:
 https://www.census.gov/topics/population/genealogy/data/2010_surnames.html
 https://www.ssa.gov/oact/babynames/
*/

--create temporary tables for actual human names
-- these tables will be automatically dropped after the session ends;
-- no constraints are placed on the Name column in these tables for reasons of
-- performance: the tables are created, populated, and dropped in this script

--drop tables if they exist: they shouldn't exist, but belt and suspenders
DROP TABLE IF EXISTS
   pg_temp.HumanFirstNames, pg_temp.HumanMiddleNames, pg_temp.HumanLastNames;

CREATE TEMPORARY TABLE HumanFirstNames(
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(50) --NOT NULL UNIQUE is the expectation for this column
);

CREATE TEMPORARY TABLE HumanMiddleNames(
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(50) --NOT NULL UNIQUE is the expectation for this column
);

CREATE TEMPORARY TABLE HumanLastNames(
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(50) --NOT NULL UNIQUE is the expectation for this column
);


--insert 100 random first names into HumanFirstNames
INSERT INTO pg_temp.HumanFirstNames(Name)
VALUES
   ('Jacob'),     ('Michael'),   ('Madison'),   ('Joshua'),    ('Sarah'),
   ('Nicholas'),  ('Andrew'),    ('Joseph'),    ('Elizabeth'), ('Tyler'),
   ('William'),   ('Alyssa'),    ('Kayla'),     ('John'),      ('Brianna'),
   ('David'),     ('Emma'),      ('James'),     ('Justin'),    ('Alexander'),
   ('Jonathan'),  ('Christian'), ('Sydney'),    ('Dylan'),     ('Morgan'),
   ('Jennifer'),  ('Noah'),      ('Samuel'),    ('Julia'),     ('Nathan'),
   ('Nicole'),    ('Amanda'),    ('Katherine'), ('Jose'),      ('Hunter'),
   ('Jordan'),    ('Savannah'),  ('Caleb'),     ('Jason'),     ('Logan'),
   ('Maria'),     ('Eric'),      ('Mackenzie'), ('Gabriel'),   ('Adam'),
   ('Mary'),      ('Isaiah'),    ('Juan'),      ('Luis'),      ('Connor'),
   ('Brooke'),    ('Elijah'),    ('Isaac'),     ('Steven'),    ('Evan'),
   ('Madeline'),  ('Sean'),      ('Kimberly'),  ('Courtney'),  ('Cody'),
   ('Nathaniel'), ('Alex'),      ('Jenna'),     ('Mason'),     ('Caroline'),
   ('Carlos'),    ('Angel'),     ('Bailey'),    ('Devin'),     ('Shelby'),
   ('Cole'),      ('Jackson'),   ('Christina'), ('Garrett'),   ('Trevor'),
   ('Caitlin'),   ('Chase'),     ('Adrian'),    ('Mark'),      ('Blake'),
   ('Sebastian'), ('Antonio'),   ('Lucas'),     ('Jeremy'),    ('Gavin'),
   ('Claire'),    ('Julian'),    ('Dakota'),    ('Kathryn'),   ('Jesse'),
   ('Dalton'),    ('Bryce'),     ('Mia'),       ('Kenneth'),   ('Stephen'),
   ('Jake'),      ('Katie'),     ('Spencer'),   ('Cheyenne'),  ('Paul');


--insert 42 random middle names into HumanMiddleNames. Values of '' are used to
--represent no middle name; ~40% (17/42) of the entries are empty strings.
INSERT INTO pg_temp.HumanMiddleNames(Name)
VALUES
   ('James'),  (''),       ('Jerry'),  (''),       ('Mathew'), (''),
   ('G'),      (''),       ('E'),      (''),       ('Vinny'),  ('V'),
   (''),       ('B'),      ('Kevin'),  (''),       ('X'),      ('Jonathan'),
   (''),       ('Mark'),   (''),       ('Amanda'), (''),       ('Luis'),
   (''),       ('P'),      (''),       ('Frank'),  (''),       ('Rebecca'),
   (''),       ('L'),      (''),       ('Gary'),   (''),       ('Mary'),
   (''),       ('Donald'), ('T'),       ('Warren'), ('Pam'),    ('Eric');


--insert 100 random last names into HumanLastNames
INSERT INTO pg_temp.HumanLastNames(Name)
VALUES
   ('Smith'),     ('Johnson'),   ('Williams'),  ('Brown'),     ('Jones'),
   ('Garcia'),    ('Miller'),    ('Davis'),     ('Rodriguez'), ('Martinez'),
   ('Hernandez'), ('Lopez'),     ('Gonzalez'),  ('Wilson'),    ('Anderson'),
   ('Thomas'),    ('Taylor'),    ('Moore'),     ('Jackson'),   ('Martin'),
   ('Lee'),       ('Perez'),     ('Thompson'),  ('White'),     ('Harris'),
   ('Sanchez'),   ('Clark'),     ('Ramirez'),   ('Lewis'),     ('Robinson'),
   ('Walker'),    ('Young'),     ('Allen'),     ('King'),      ('Wright'),
   ('Scott'),     ('Torres'),    ('Nguyen'),    ('Hill'),      ('Flores'),
   ('Green'),     ('Adams'),     ('Nelson'),    ('Baker'),     ('Hall'),
   ('Rivera'),    ('Campbell'),  ('Mitchell'),  ('Carter'),    ('Roberts'),
   ('Gomez'),     ('Phillips'),  ('Evans'),     ('Turner'),    ('Diaz'),
   ('Parker'),    ('Cruz'),      ('Edwards'),   ('Collins'),   ('Reyes'),
   ('Stewart'),   ('Morris'),    ('Morales'),   ('Murphy'),    ('Cook'),
   ('Rogers'),    ('Gutierrez'), ('Ortiz'),     ('Morgan'),    ('Cooper'),
   ('Peterson'),  ('Bailey'),    ('Reed'),      ('Kelly'),     ('Howard'),
   ('Ramos'),     ('Kim'),       ('Cox'),       ('Ward'),      ('Richardson'),
   ('Watson'),    ('Brooks'),    ('Chavez'),    ('Wood'),      ('James'),
   ('Bennett'),   ('Gray'),      ('Mendoza'),   ('Ruiz'),      ('Hughes'),
   ('Price'),     ('Alvarez'),   ('Castillo'),  ('Sanders'),   ('Patel'),
   ('Myers'),     ('Long'),      ('Ross'),      ('Foster'),    ('Jimenez');


--create a temporary function to return a random first name
--parameter numFirstNames is expected to equal #rows in table HumanFirstNames
CREATE OR REPLACE FUNCTION pg_temp.GetHumanFirstName(numFirstNames INTEGER)
RETURNS VARCHAR(50)
AS
$$
   SELECT H.Name
   FROM pg_temp.HumanFirstNames H
        JOIN (SELECT FLOOR(random() * $1) + 1 AS ID) R ON H.ID = R.ID
   LIMIT 1;
$$ LANGUAGE SQL;


--create a temporary function to return a random middle name
--parameter numMiddleNames is expected to equal #rows in table HumanMiddleNames
CREATE OR REPLACE FUNCTION pg_temp.GetHumanMiddleName(numMiddleNames INTEGER)
RETURNS VARCHAR(50)
AS
$$
   SELECT H.Name
   FROM pg_temp.HumanMiddleNames H
        JOIN (SELECT FLOOR(random() * $1) + 1 AS ID) R ON H.ID = R.ID
   LIMIT 1;
$$ LANGUAGE SQL;

--create a temporary function to return a random last name
--parameter numLastNames is expected to equal #rows in table HumanLastNames
CREATE OR REPLACE FUNCTION pg_temp.GetHumanLastName(numLastNames INTEGER)
RETURNS VARCHAR(50)
AS
$$
   SELECT H.Name
   FROM pg_temp.HumanLastNames H
        JOIN (SELECT FLOOR(random() * $1) + 1 AS ID) R ON H.ID = R.ID
   LIMIT 1;
$$ LANGUAGE SQL;

--create a temporary function to return a random name part: first/middle/last
--parameters:
-- currentName: value presently in Student table for the name part
-- resultNameKind: '0'/'1'/x to denote name part desired
--  '0' returns first name; '1' returns middle name; others return last name
-- humanTableRows: #rows in the appropriate Human* table
--return value:
-- same as currentName if that param is NULL or empty, else a randomly generated
-- name for the kind of name requested
--if a Get*Name function returns NULL (which happens occasionally), that
-- function is retried up to two more times; if all 3 attempts to generate a
-- name part return NULL, currentName is returned as the function's value;
-- so far at most one retry has been necessary to return a non-NULL name part
CREATE OR REPLACE FUNCTION pg_temp.GetHumanNamePart(currentName VARCHAR(50),
                                                    resultNameKind CHAR(1),
                                                    humanTableRows INTEGER)
RETURNS VARCHAR(50)
AS
$$
DECLARE result VARCHAR(50);
BEGIN
   IF (currentName IS NULL OR TRIM(currentName) = '') THEN
      RETURN currentName;
   ELSE
      --call appropriate name-part function: try upto three times to see if a
      --non-NULL value can be generated
      CASE
         WHEN (resultNameKind = '0') THEN
            result = COALESCE(pg_temp.GetHumanFirstName(humanTableRows),
                              pg_temp.GetHumanFirstName(humanTableRows),
                              pg_temp.GetHumanFirstName(humanTableRows)
                             );
         WHEN (resultNameKind = '1') THEN
            result = COALESCE(pg_temp.GetHumanMiddleName(humanTableRows),
                              pg_temp.GetHumanMiddleName(humanTableRows),
                              pg_temp.GetHumanMiddleName(humanTableRows)
                             );
         ELSE
            result = COALESCE(pg_temp.GetHumanLastName(humanTableRows),
                              pg_temp.GetHumanLastName(humanTableRows),
                              pg_temp.GetHumanLastName(humanTableRows)
                             );
      END CASE;

      --return currentName if result is NULL after three tries
      RETURN COALESCE(result, currentName);
   END IF;
END
$$ LANGUAGE plpgsql;

/*
the following dynamic SQL can be used instead of using a different function for
each name part; yet name-part specific functions are intentionally used to
improve maintainability;
in the code below, humanTableName is a variable whose value depends on parameter
resultNameKind

EXECUTE 'SELECT H.Name '
        'FROM pg_temp.' || humanTableName || ' H '
        'JOIN (SELECT FLOOR(random() * ' || humanTableRows || ') + 1 AS ID) R '
        'ON H.ID = R.ID '
        'LIMIT 1;'
INTO result;
*/


--perform humanization
DO
$$
DECLARE
    numOfFirstNames INTEGER;
    numOfMiddleNames INTEGER;
    numOfLastNames INTEGER;
BEGIN

    --determine the number of names in each Human* table
    -- the counts are used to limit the range of random numbers generated
    SELECT COUNT(*) INTO numOfFirstNames FROM HumanFirstNames;
    SELECT COUNT(*) INTO numOfMiddleNames FROM HumanMiddleNames;
    SELECT COUNT(*) INTO numOfLastNames FROM HumanLastNames;

    --update the name columns in Student table in rows containing hash values
    -- a name column contains hash value if it contains only hexadecimal digits;
    -- test a concatenation of all name columns to prevent falsely identifying
    -- a row as needing update: unlikely a real human name has all name parts
    -- made of only hex digits. "Ada E Cadefa"? "Abe Bead"?
    UPDATE Gradebook.Student
    SET FName = pg_temp.GetHumanNamePart(FName, '0', numOfFirstNames),
        MName = pg_temp.GetHumanNamePart(MName, '1', numOfMiddleNames),
        LName = pg_temp.GetHumanNamePart(LName, '2', numOfLastNames)
    WHERE CONCAT(TRIM(FName), TRIM(MName), TRIM(LName)) ~* '^[0-9a-f]+$';

END
$$;
