/*
Zaid Bhujwala, Sean Murthy
Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)


(C) 2017- DASSL. ALL RIGHTS RESERVED.
Licensed to others under CC 4.0 BY-SA-NC:
https://creativecommons.org/licenses/by-nc-sa/4.0/

PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

This file is used to convert MD5 hashed name values to readable human names. The
way it does this is by scanning the Student table, checking if the first,
middle, and last name fields individually contain a hashed value, then
randomly assigns a name to their respective name fields.

Name list recieved from:
    -https://www.census.gov/topics/population/genealogy/data/2010_surnames.html
    -https://www.ssa.gov/oact/babynames/
*/

--Create a temporary table for actual human names. Used for replacing hash
--values in the Student table.
--These are temporary tables and will be dropped after the session ends

CREATE TEMPORARY TABLE HumanFirstNames(
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);

CREATE TEMPORARY TABLE HumanMiddleNames(
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);

CREATE TEMPORARY TABLE HumanLastNames(
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);

--Insert 100 random first names into HumanFirstNames
INSERT INTO HumanFirstNames(Name) VALUES ('Jacob');
INSERT INTO HumanFirstNames(Name) VALUES ('Michael');
INSERT INTO HumanFirstNames(Name) VALUES ('Madison');
INSERT INTO HumanFirstNames(Name) VALUES ('Joshua');
INSERT INTO HumanFirstNames(Name) VALUES ('Sarah');
INSERT INTO HumanFirstNames(Name) VALUES ('Nicholas');
INSERT INTO HumanFirstNames(Name) VALUES ('Andrew');
INSERT INTO HumanFirstNames(Name) VALUES ('Joseph');
INSERT INTO HumanFirstNames(Name) VALUES ('Elizabeth');
INSERT INTO HumanFirstNames(Name) VALUES ('Tyler');
INSERT INTO HumanFirstNames(Name) VALUES ('William');
INSERT INTO HumanFirstNames(Name) VALUES ('Alyssa');
INSERT INTO HumanFirstNames(Name) VALUES ('Kayla');
INSERT INTO HumanFirstNames(Name) VALUES ('John');
INSERT INTO HumanFirstNames(Name) VALUES ('Brianna');
INSERT INTO HumanFirstNames(Name) VALUES ('David');
INSERT INTO HumanFirstNames(Name) VALUES ('Emma');
INSERT INTO HumanFirstNames(Name) VALUES ('James');
INSERT INTO HumanFirstNames(Name) VALUES ('Justin');
INSERT INTO HumanFirstNames(Name) VALUES ('Alexander');
INSERT INTO HumanFirstNames(Name) VALUES ('Jonathan');
INSERT INTO HumanFirstNames(Name) VALUES ('Christian');
INSERT INTO HumanFirstNames(Name) VALUES ('Sydney');
INSERT INTO HumanFirstNames(Name) VALUES ('Dylan');
INSERT INTO HumanFirstNames(Name) VALUES ('Morgan');
INSERT INTO HumanFirstNames(Name) VALUES ('Jennifer');
INSERT INTO HumanFirstNames(Name) VALUES ('Noah');
INSERT INTO HumanFirstNames(Name) VALUES ('Samuel');
INSERT INTO HumanFirstNames(Name) VALUES ('Julia');
INSERT INTO HumanFirstNames(Name) VALUES ('Nathan');
INSERT INTO HumanFirstNames(Name) VALUES ('Nicole');
INSERT INTO HumanFirstNames(Name) VALUES ('Amanda');
INSERT INTO HumanFirstNames(Name) VALUES ('Katherine');
INSERT INTO HumanFirstNames(Name) VALUES ('Jose');
INSERT INTO HumanFirstNames(Name) VALUES ('Hunter');
INSERT INTO HumanFirstNames(Name) VALUES ('Jordan');
INSERT INTO HumanFirstNames(Name) VALUES ('Savannah');
INSERT INTO HumanFirstNames(Name) VALUES ('Caleb');
INSERT INTO HumanFirstNames(Name) VALUES ('Jason');
INSERT INTO HumanFirstNames(Name) VALUES ('Logan');
INSERT INTO HumanFirstNames(Name) VALUES ('Maria');
INSERT INTO HumanFirstNames(Name) VALUES ('Eric');
INSERT INTO HumanFirstNames(Name) VALUES ('Mackenzie');
INSERT INTO HumanFirstNames(Name) VALUES ('Gabriel');
INSERT INTO HumanFirstNames(Name) VALUES ('Adam');
INSERT INTO HumanFirstNames(Name) VALUES ('Mary');
INSERT INTO HumanFirstNames(Name) VALUES ('Isaiah');
INSERT INTO HumanFirstNames(Name) VALUES ('Juan');
INSERT INTO HumanFirstNames(Name) VALUES ('Luis');
INSERT INTO HumanFirstNames(Name) VALUES ('Connor');
INSERT INTO HumanFirstNames(Name) VALUES ('Brooke');
INSERT INTO HumanFirstNames(Name) VALUES ('Elijah');
INSERT INTO HumanFirstNames(Name) VALUES ('Isaac');
INSERT INTO HumanFirstNames(Name) VALUES ('Steven');
INSERT INTO HumanFirstNames(Name) VALUES ('Evan');
INSERT INTO HumanFirstNames(Name) VALUES ('Madeline');
INSERT INTO HumanFirstNames(Name) VALUES ('Sean');
INSERT INTO HumanFirstNames(Name) VALUES ('Kimberly');
INSERT INTO HumanFirstNames(Name) VALUES ('Courtney');
INSERT INTO HumanFirstNames(Name) VALUES ('Cody');
INSERT INTO HumanFirstNames(Name) VALUES ('Nathaniel');
INSERT INTO HumanFirstNames(Name) VALUES ('Alex');
INSERT INTO HumanFirstNames(Name) VALUES ('Jenna');
INSERT INTO HumanFirstNames(Name) VALUES ('Mason');
INSERT INTO HumanFirstNames(Name) VALUES ('Caroline');
INSERT INTO HumanFirstNames(Name) VALUES ('Carlos');
INSERT INTO HumanFirstNames(Name) VALUES ('Angel');
INSERT INTO HumanFirstNames(Name) VALUES ('Bailey');
INSERT INTO HumanFirstNames(Name) VALUES ('Devin');
INSERT INTO HumanFirstNames(Name) VALUES ('Shelby');
INSERT INTO HumanFirstNames(Name) VALUES ('Cole');
INSERT INTO HumanFirstNames(Name) VALUES ('Jackson');
INSERT INTO HumanFirstNames(Name) VALUES ('Christina');
INSERT INTO HumanFirstNames(Name) VALUES ('Garrett');
INSERT INTO HumanFirstNames(Name) VALUES ('Trevor');
INSERT INTO HumanFirstNames(Name) VALUES ('Caitlin');
INSERT INTO HumanFirstNames(Name) VALUES ('Chase');
INSERT INTO HumanFirstNames(Name) VALUES ('Adrian');
INSERT INTO HumanFirstNames(Name) VALUES ('Mark');
INSERT INTO HumanFirstNames(Name) VALUES ('Blake');
INSERT INTO HumanFirstNames(Name) VALUES ('Sebastian');
INSERT INTO HumanFirstNames(Name) VALUES ('Antonio');
INSERT INTO HumanFirstNames(Name) VALUES ('Lucas');
INSERT INTO HumanFirstNames(Name) VALUES ('Jeremy');
INSERT INTO HumanFirstNames(Name) VALUES ('Gavin');
INSERT INTO HumanFirstNames(Name) VALUES ('Claire');
INSERT INTO HumanFirstNames(Name) VALUES ('Julian');
INSERT INTO HumanFirstNames(Name) VALUES ('Dakota');
INSERT INTO HumanFirstNames(Name) VALUES ('Kathryn');
INSERT INTO HumanFirstNames(Name) VALUES ('Jesse');
INSERT INTO HumanFirstNames(Name) VALUES ('Dalton');
INSERT INTO HumanFirstNames(Name) VALUES ('Bryce');
INSERT INTO HumanFirstNames(Name) VALUES ('Mia');
INSERT INTO HumanFirstNames(Name) VALUES ('Kenneth');
INSERT INTO HumanFirstNames(Name) VALUES ('Stephen');
INSERT INTO HumanFirstNames(Name) VALUES ('Jake');
INSERT INTO HumanFirstNames(Name) VALUES ('Katie');
INSERT INTO HumanFirstNames(Name) VALUES ('Spencer');
INSERT INTO HumanFirstNames(Name) VALUES ('Cheyenne');
INSERT INTO HumanFirstNames(Name) VALUES ('Paul');

--Insert 41 random middle names into HumanMiddleNames. Values of '' are used to
--represent no middle name. ~41% (17/41) of the entries are empty strings.
INSERT INTO HumanMiddleNames(Name) VALUES ('James');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('Jerry');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('Mathew');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('G');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('O');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('Vinny');
INSERT INTO HumanMiddleNames(Name) VALUES ('V');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('Jonathan');
INSERT INTO HumanMiddleNames(Name) VALUES ('Kevin');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('B');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('Mark');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('Amanda');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('Luis');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('P');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('Frank');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('Rebecca');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('L');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('Gary');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('Mary');
INSERT INTO HumanMiddleNames(Name) VALUES ('');
INSERT INTO HumanMiddleNames(Name) VALUES ('Donald');
INSERT INTO HumanMiddleNames(Name) VALUES ('T');
INSERT INTO HumanMiddleNames(Name) VALUES ('Warren');
INSERT INTO HumanMiddleNames(Name) VALUES ('Pam');
INSERT INTO HumanMiddleNames(Name) VALUES ('Eric');
INSERT INTO HumanMiddleNames(Name) VALUES ('X');

--Insert 100 random last names into HumanLastNames
INSERT INTO HumanLastNames(Name) VALUES ('Smith');
INSERT INTO HumanLastNames(Name) VALUES ('Johnson');
INSERT INTO HumanLastNames(Name) VALUES ('Williams');
INSERT INTO HumanLastNames(Name) VALUES ('Brown');
INSERT INTO HumanLastNames(Name) VALUES ('Jones');
INSERT INTO HumanLastNames(Name) VALUES ('Garcia');
INSERT INTO HumanLastNames(Name) VALUES ('Miller');
INSERT INTO HumanLastNames(Name) VALUES ('Davis');
INSERT INTO HumanLastNames(Name) VALUES ('Rodriguez');
INSERT INTO HumanLastNames(Name) VALUES ('Martinez');
INSERT INTO HumanLastNames(Name) VALUES ('Hernandez');
INSERT INTO HumanLastNames(Name) VALUES ('Lopez');
INSERT INTO HumanLastNames(Name) VALUES ('Gonzalez');
INSERT INTO HumanLastNames(Name) VALUES ('Wilson');
INSERT INTO HumanLastNames(Name) VALUES ('Anderson');
INSERT INTO HumanLastNames(Name) VALUES ('Thomas');
INSERT INTO HumanLastNames(Name) VALUES ('Taylor');
INSERT INTO HumanLastNames(Name) VALUES ('Moore');
INSERT INTO HumanLastNames(Name) VALUES ('Jackson');
INSERT INTO HumanLastNames(Name) VALUES ('Martin');
INSERT INTO HumanLastNames(Name) VALUES ('Lee');
INSERT INTO HumanLastNames(Name) VALUES ('Perez');
INSERT INTO HumanLastNames(Name) VALUES ('Thompson');
INSERT INTO HumanLastNames(Name) VALUES ('White');
INSERT INTO HumanLastNames(Name) VALUES ('Harris');
INSERT INTO HumanLastNames(Name) VALUES ('Sanchez');
INSERT INTO HumanLastNames(Name) VALUES ('Clark');
INSERT INTO HumanLastNames(Name) VALUES ('Ramirez');
INSERT INTO HumanLastNames(Name) VALUES ('Lewis');
INSERT INTO HumanLastNames(Name) VALUES ('Robinson');
INSERT INTO HumanLastNames(Name) VALUES ('Walker');
INSERT INTO HumanLastNames(Name) VALUES ('Young');
INSERT INTO HumanLastNames(Name) VALUES ('Allen');
INSERT INTO HumanLastNames(Name) VALUES ('King');
INSERT INTO HumanLastNames(Name) VALUES ('Wright');
INSERT INTO HumanLastNames(Name) VALUES ('Scott');
INSERT INTO HumanLastNames(Name) VALUES ('Torres');
INSERT INTO HumanLastNames(Name) VALUES ('Nguyen');
INSERT INTO HumanLastNames(Name) VALUES ('Hill');
INSERT INTO HumanLastNames(Name) VALUES ('Flores');
INSERT INTO HumanLastNames(Name) VALUES ('Green');
INSERT INTO HumanLastNames(Name) VALUES ('Adams');
INSERT INTO HumanLastNames(Name) VALUES ('Nelson');
INSERT INTO HumanLastNames(Name) VALUES ('Baker');
INSERT INTO HumanLastNames(Name) VALUES ('Hall');
INSERT INTO HumanLastNames(Name) VALUES ('Rivera');
INSERT INTO HumanLastNames(Name) VALUES ('Campbell');
INSERT INTO HumanLastNames(Name) VALUES ('Mitchell');
INSERT INTO HumanLastNames(Name) VALUES ('Carter');
INSERT INTO HumanLastNames(Name) VALUES ('Roberts');
INSERT INTO HumanLastNames(Name) VALUES ('Gomez');
INSERT INTO HumanLastNames(Name) VALUES ('Phillips');
INSERT INTO HumanLastNames(Name) VALUES ('Evans');
INSERT INTO HumanLastNames(Name) VALUES ('Turner');
INSERT INTO HumanLastNames(Name) VALUES ('Diaz');
INSERT INTO HumanLastNames(Name) VALUES ('Parker');
INSERT INTO HumanLastNames(Name) VALUES ('Cruz');
INSERT INTO HumanLastNames(Name) VALUES ('Edwards');
INSERT INTO HumanLastNames(Name) VALUES ('Collins');
INSERT INTO HumanLastNames(Name) VALUES ('Reyes');
INSERT INTO HumanLastNames(Name) VALUES ('Stewart');
INSERT INTO HumanLastNames(Name) VALUES ('Morris');
INSERT INTO HumanLastNames(Name) VALUES ('Morales');
INSERT INTO HumanLastNames(Name) VALUES ('Murphy');
INSERT INTO HumanLastNames(Name) VALUES ('Cook');
INSERT INTO HumanLastNames(Name) VALUES ('Rogers');
INSERT INTO HumanLastNames(Name) VALUES ('Gutierrez');
INSERT INTO HumanLastNames(Name) VALUES ('Ortiz');
INSERT INTO HumanLastNames(Name) VALUES ('Morgan');
INSERT INTO HumanLastNames(Name) VALUES ('Cooper');
INSERT INTO HumanLastNames(Name) VALUES ('Peterson');
INSERT INTO HumanLastNames(Name) VALUES ('Bailey');
INSERT INTO HumanLastNames(Name) VALUES ('Reed');
INSERT INTO HumanLastNames(Name) VALUES ('Kelly');
INSERT INTO HumanLastNames(Name) VALUES ('Howard');
INSERT INTO HumanLastNames(Name) VALUES ('Ramos');
INSERT INTO HumanLastNames(Name) VALUES ('Kim');
INSERT INTO HumanLastNames(Name) VALUES ('Cox');
INSERT INTO HumanLastNames(Name) VALUES ('Ward');
INSERT INTO HumanLastNames(Name) VALUES ('Richardson');
INSERT INTO HumanLastNames(Name) VALUES ('Watson');
INSERT INTO HumanLastNames(Name) VALUES ('Brooks');
INSERT INTO HumanLastNames(Name) VALUES ('Chavez');
INSERT INTO HumanLastNames(Name) VALUES ('Wood');
INSERT INTO HumanLastNames(Name) VALUES ('James');
INSERT INTO HumanLastNames(Name) VALUES ('Bennett');
INSERT INTO HumanLastNames(Name) VALUES ('Gray');
INSERT INTO HumanLastNames(Name) VALUES ('Mendoza');
INSERT INTO HumanLastNames(Name) VALUES ('Ruiz');
INSERT INTO HumanLastNames(Name) VALUES ('Hughes');
INSERT INTO HumanLastNames(Name) VALUES ('Price');
INSERT INTO HumanLastNames(Name) VALUES ('Alvarez');
INSERT INTO HumanLastNames(Name) VALUES ('Castillo');
INSERT INTO HumanLastNames(Name) VALUES ('Sanders');
INSERT INTO HumanLastNames(Name) VALUES ('Patel');
INSERT INTO HumanLastNames(Name) VALUES ('Myers');
INSERT INTO HumanLastNames(Name) VALUES ('Long');
INSERT INTO HumanLastNames(Name) VALUES ('Ross');
INSERT INTO HumanLastNames(Name) VALUES ('Foster');
INSERT INTO HumanLastNames(Name) VALUES ('Jimenez');

DO $$
DECLARE
    --Declare integers that will be used for the upper bounds of the random
    --generator
    numOfFirstNames INTEGER;
    numOfMiddleNames INTEGER;
    numOfLastNames INTEGER;
BEGIN
    SELECT COUNT(*)
        INTO numOfFirstNames
    FROM HumanFirstNames;

    SELECT COUNT(*)
        INTO numOfMiddleNames
    FROM HumanMiddleNames;

    SELECT COUNT(*)
        INTO numOfLastNames
    FROM HumanLastNames;

    --Update Student.FName, Student.MName, and Student.LName field if the
    --fields individually match the regular expression [0-9A-F]{32} (case insensitive)
    --or if they are null.
    --The WHERE clauses with `length(Name) * 0 + 1` is used to make the
    --subqueries volatile by making a dependency on the outer query thus
    --ensuring random() is called the appropriate amount of times.
    UPDATE Gradebook.Student
    SET FName = (SELECT Name
                FROM HumanFirstNames
                WHERE HumanFirstNames.ID = (
                    SELECT DISTINCT trunc(random() * numOfFirstNames + 1)
                        * (length(FName) * 0 + 1)
                )
            ),
        MName = (SELECT Name
                FROM HumanMiddleNames
                WHERE HumanMiddleNames.ID = (
                    SELECT DISTINCT trunc(random() * numOfMiddleNames + 1)
                        * (length(MName) * 0 + 1)
                )
            ),
        LName = (SELECT Name
                FROM HumanLastNames
                WHERE HumanLastNames.ID = (
                    SELECT DISTINCT trunc(random() * numOfLastNames + 1)
                        * (length(LName) * 0 + 1 )
                )
            )
    WHERE (FName ~* '[0-9a-f]{32}')
        OR (MName ~* '[0-9a-f]{32}')
        OR(LName ~* '[0-9a-f]{32}');

END $$;
