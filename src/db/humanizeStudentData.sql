/*
Zaid Bhujwala, Andrew Figueroa, Sean Murthy
Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)


(C) 2017- DASSL. ALL RIGHTS RESERVED.
Licensed to others under CC 4.0 BY-SA-NC: https://creativecommons.org/licenses/by-nc-sa/4.0/

PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

This file is used to convert hashed name values to readable human names. The
way it does this is by scanning the Student table, checking if the name field
contains a number [0-9] to determine if the name field is hashed, and randomly
assigns a name to the respective name field.
This file works on a few assumptions:
    -Student table is populated with either hashed or non-hashed names in fName,
    mName, and lName

Name list recieved from:
    -https://www.census.gov/topics/population/genealogy/data/2010_surnames.html
    -https://www.ssa.gov/oact/babynames/
*/

--Creating a table for actual human names. Used for replacing hash values in the
--Student table
--These are temporary tables and will be dropped after the session ends

CREATE TEMPORARY TABLE HumanFirstNames(
    id INTEGER PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);

CREATE TEMPORARY TABLE HumanMiddleNames(
    id INTEGER PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);

CREATE TEMPORARY TABLE HumanLastNames(
    id INTEGER PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);

--Inserting 100 random first names in first names table
INSERT INTO HumanFirstNames VALUES (1, 'Jacob');
INSERT INTO HumanFirstNames VALUES (2, 'Michael');
INSERT INTO HumanFirstNames VALUES (3, 'Madison');
INSERT INTO HumanFirstNames VALUES (4, 'Joshua');
INSERT INTO HumanFirstNames VALUES (5, 'Sarah');
INSERT INTO HumanFirstNames VALUES (6, 'Nicholas');
INSERT INTO HumanFirstNames VALUES (7, 'Andrew');
INSERT INTO HumanFirstNames VALUES (8, 'Joseph');
INSERT INTO HumanFirstNames VALUES (9, 'Elizabeth');
INSERT INTO HumanFirstNames VALUES (10, 'Tyler');
INSERT INTO HumanFirstNames VALUES (11, 'William');
INSERT INTO HumanFirstNames VALUES (12, 'Alyssa');
INSERT INTO HumanFirstNames VALUES (13, 'Kayla');
INSERT INTO HumanFirstNames VALUES (14, 'John');
INSERT INTO HumanFirstNames VALUES (15, 'Brianna');
INSERT INTO HumanFirstNames VALUES (16, 'David');
INSERT INTO HumanFirstNames VALUES (17, 'Emma');
INSERT INTO HumanFirstNames VALUES (18, 'James');
INSERT INTO HumanFirstNames VALUES (19, 'Justin');
INSERT INTO HumanFirstNames VALUES (20, 'Alexander');
INSERT INTO HumanFirstNames VALUES (21, 'Jonathan');
INSERT INTO HumanFirstNames VALUES (22, 'Christian');
INSERT INTO HumanFirstNames VALUES (23, 'Sydney');
INSERT INTO HumanFirstNames VALUES (24, 'Dylan');
INSERT INTO HumanFirstNames VALUES (25, 'Morgan');
INSERT INTO HumanFirstNames VALUES (26, 'Jennifer');
INSERT INTO HumanFirstNames VALUES (27, 'Noah');
INSERT INTO HumanFirstNames VALUES (28, 'Samuel');
INSERT INTO HumanFirstNames VALUES (29, 'Julia');
INSERT INTO HumanFirstNames VALUES (30, 'Nathan');
INSERT INTO HumanFirstNames VALUES (31, 'Nicole');
INSERT INTO HumanFirstNames VALUES (32, 'Amanda');
INSERT INTO HumanFirstNames VALUES (33, 'Katherine');
INSERT INTO HumanFirstNames VALUES (34, 'Jose');
INSERT INTO HumanFirstNames VALUES (35, 'Hunter');
INSERT INTO HumanFirstNames VALUES (36, 'Jordan');
INSERT INTO HumanFirstNames VALUES (37, 'Savannah');
INSERT INTO HumanFirstNames VALUES (38, 'Caleb');
INSERT INTO HumanFirstNames VALUES (39, 'Jason');
INSERT INTO HumanFirstNames VALUES (40, 'Logan');
INSERT INTO HumanFirstNames VALUES (41, 'Maria');
INSERT INTO HumanFirstNames VALUES (42, 'Eric');
INSERT INTO HumanFirstNames VALUES (43, 'Mackenzie');
INSERT INTO HumanFirstNames VALUES (44, 'Gabriel');
INSERT INTO HumanFirstNames VALUES (45, 'Adam');
INSERT INTO HumanFirstNames VALUES (46, 'Mary');
INSERT INTO HumanFirstNames VALUES (47, 'Isaiah');
INSERT INTO HumanFirstNames VALUES (48, 'Juan');
INSERT INTO HumanFirstNames VALUES (49, 'Luis');
INSERT INTO HumanFirstNames VALUES (50, 'Connor');
INSERT INTO HumanFirstNames VALUES (51, 'Brooke');
INSERT INTO HumanFirstNames VALUES (52, 'Elijah');
INSERT INTO HumanFirstNames VALUES (53, 'Isaac');
INSERT INTO HumanFirstNames VALUES (54, 'Steven');
INSERT INTO HumanFirstNames VALUES (55, 'Evan');
INSERT INTO HumanFirstNames VALUES (56, 'Madeline');
INSERT INTO HumanFirstNames VALUES (57, 'Sean');
INSERT INTO HumanFirstNames VALUES (58, 'Kimberly');
INSERT INTO HumanFirstNames VALUES (59, 'Courtney');
INSERT INTO HumanFirstNames VALUES (60, 'Cody');
INSERT INTO HumanFirstNames VALUES (61, 'Nathaniel');
INSERT INTO HumanFirstNames VALUES (62, 'Alex');
INSERT INTO HumanFirstNames VALUES (63, 'Jenna');
INSERT INTO HumanFirstNames VALUES (64, 'Mason');
INSERT INTO HumanFirstNames VALUES (65, 'Caroline');
INSERT INTO HumanFirstNames VALUES (66, 'Carlos');
INSERT INTO HumanFirstNames VALUES (67, 'Angel');
INSERT INTO HumanFirstNames VALUES (68, 'Bailey');
INSERT INTO HumanFirstNames VALUES (69, 'Devin');
INSERT INTO HumanFirstNames VALUES (70, 'Shelby');
INSERT INTO HumanFirstNames VALUES (71, 'Cole');
INSERT INTO HumanFirstNames VALUES (72, 'Jackson');
INSERT INTO HumanFirstNames VALUES (73, 'Christina');
INSERT INTO HumanFirstNames VALUES (74, 'Garrett');
INSERT INTO HumanFirstNames VALUES (75, 'Trevor');
INSERT INTO HumanFirstNames VALUES (76, 'Caitlin');
INSERT INTO HumanFirstNames VALUES (77, 'Chase');
INSERT INTO HumanFirstNames VALUES (78, 'Adrian');
INSERT INTO HumanFirstNames VALUES (79, 'Mark');
INSERT INTO HumanFirstNames VALUES (80, 'Blake');
INSERT INTO HumanFirstNames VALUES (81, 'Sebastian');
INSERT INTO HumanFirstNames VALUES (82, 'Antonio');
INSERT INTO HumanFirstNames VALUES (83, 'Lucas');
INSERT INTO HumanFirstNames VALUES (84, 'Jeremy');
INSERT INTO HumanFirstNames VALUES (85, 'Gavin');
INSERT INTO HumanFirstNames VALUES (86, 'Claire');
INSERT INTO HumanFirstNames VALUES (87, 'Julian');
INSERT INTO HumanFirstNames VALUES (88, 'Dakota');
INSERT INTO HumanFirstNames VALUES (89, 'Kathryn');
INSERT INTO HumanFirstNames VALUES (90, 'Jesse');
INSERT INTO HumanFirstNames VALUES (91, 'Dalton');
INSERT INTO HumanFirstNames VALUES (92, 'Bryce');
INSERT INTO HumanFirstNames VALUES (93, 'Mia');
INSERT INTO HumanFirstNames VALUES (94, 'Kenneth');
INSERT INTO HumanFirstNames VALUES (95, 'Stephen');
INSERT INTO HumanFirstNames VALUES (96, 'Jake');
INSERT INTO HumanFirstNames VALUES (97, 'Katie');
INSERT INTO HumanFirstNames VALUES (98, 'Spencer');
INSERT INTO HumanFirstNames VALUES (99, 'Cheyenne');
INSERT INTO HumanFirstNames VALUES (100, 'Paul');

--Inserting 25 random middle names in middle names table
INSERT INTO HumanMiddleNames VALUES (1, 'James');
INSERT INTO HumanMiddleNames VALUES (2, 'Jerry');
INSERT INTO HumanMiddleNames VALUES (3, 'Mathew');
INSERT INTO HumanMiddleNames VALUES (4, 'G');
INSERT INTO HumanMiddleNames VALUES (5, 'O');
INSERT INTO HumanMiddleNames VALUES (6, 'Vinny');
INSERT INTO HumanMiddleNames VALUES (7, 'V');
INSERT INTO HumanMiddleNames VALUES (8, 'Jonathan');
INSERT INTO HumanMiddleNames VALUES (9, 'Kevin');
INSERT INTO HumanMiddleNames VALUES (10, 'B');
INSERT INTO HumanMiddleNames VALUES (11, 'Mark');
INSERT INTO HumanMiddleNames VALUES (12, 'Amanda');
INSERT INTO HumanMiddleNames VALUES (13, 'Luis');
INSERT INTO HumanMiddleNames VALUES (14, 'P');
INSERT INTO HumanMiddleNames VALUES (15, 'Frank');
INSERT INTO HumanMiddleNames VALUES (16, 'Rebecca');
INSERT INTO HumanMiddleNames VALUES (17, 'L');
INSERT INTO HumanMiddleNames VALUES (18, 'Gary');
INSERT INTO HumanMiddleNames VALUES (19, 'Mary');
INSERT INTO HumanMiddleNames VALUES (20, 'Donald');
INSERT INTO HumanMiddleNames VALUES (21, 'T');
INSERT INTO HumanMiddleNames VALUES (22, 'Warren');
INSERT INTO HumanMiddleNames VALUES (23, 'Pam');
INSERT INTO HumanMiddleNames VALUES (24, 'Eric');
INSERT INTO HumanMiddleNames VALUES (25, 'X');

--Inserting 100 random last names in last names table
INSERT INTO HumanLastNames VALUES (1, 'Smith');
INSERT INTO HumanLastNames VALUES (2, 'Johnson');
INSERT INTO HumanLastNames VALUES (3, 'Williams');
INSERT INTO HumanLastNames VALUES (4, 'Brown');
INSERT INTO HumanLastNames VALUES (5, 'Jones');
INSERT INTO HumanLastNames VALUES (6, 'Garcia');
INSERT INTO HumanLastNames VALUES (7, 'Miller');
INSERT INTO HumanLastNames VALUES (8, 'Davis');
INSERT INTO HumanLastNames VALUES (9, 'Rodriguez');
INSERT INTO HumanLastNames VALUES (10, 'Martinez');
INSERT INTO HumanLastNames VALUES (11, 'Hernandez');
INSERT INTO HumanLastNames VALUES (12, 'Lopez');
INSERT INTO HumanLastNames VALUES (13, 'Gonzalez');
INSERT INTO HumanLastNames VALUES (14, 'Wilson');
INSERT INTO HumanLastNames VALUES (15, 'Anderson');
INSERT INTO HumanLastNames VALUES (16, 'Thomas');
INSERT INTO HumanLastNames VALUES (17, 'Taylor');
INSERT INTO HumanLastNames VALUES (18, 'Moore');
INSERT INTO HumanLastNames VALUES (19, 'Jackson');
INSERT INTO HumanLastNames VALUES (20, 'Martin');
INSERT INTO HumanLastNames VALUES (21, 'Lee');
INSERT INTO HumanLastNames VALUES (22, 'Perez');
INSERT INTO HumanLastNames VALUES (23, 'Thompson');
INSERT INTO HumanLastNames VALUES (24, 'White');
INSERT INTO HumanLastNames VALUES (25, 'Harris');
INSERT INTO HumanLastNames VALUES (26, 'Sanchez');
INSERT INTO HumanLastNames VALUES (27, 'Clark');
INSERT INTO HumanLastNames VALUES (28, 'Ramirez');
INSERT INTO HumanLastNames VALUES (29, 'Lewis');
INSERT INTO HumanLastNames VALUES (30, 'Robinson');
INSERT INTO HumanLastNames VALUES (31, 'Walker');
INSERT INTO HumanLastNames VALUES (32, 'Young');
INSERT INTO HumanLastNames VALUES (33, 'Allen');
INSERT INTO HumanLastNames VALUES (34, 'King');
INSERT INTO HumanLastNames VALUES (35, 'Wright');
INSERT INTO HumanLastNames VALUES (36, 'Scott');
INSERT INTO HumanLastNames VALUES (37, 'Torres');
INSERT INTO HumanLastNames VALUES (38, 'Nguyen');
INSERT INTO HumanLastNames VALUES (39, 'Hill');
INSERT INTO HumanLastNames VALUES (40, 'Flores');
INSERT INTO HumanLastNames VALUES (41, 'Green');
INSERT INTO HumanLastNames VALUES (42, 'Adams');
INSERT INTO HumanLastNames VALUES (43, 'Nelson');
INSERT INTO HumanLastNames VALUES (44, 'Baker');
INSERT INTO HumanLastNames VALUES (45, 'Hall');
INSERT INTO HumanLastNames VALUES (46, 'Rivera');
INSERT INTO HumanLastNames VALUES (47, 'Campbell');
INSERT INTO HumanLastNames VALUES (48, 'Mitchell');
INSERT INTO HumanLastNames VALUES (49, 'Carter');
INSERT INTO HumanLastNames VALUES (50, 'Roberts');
INSERT INTO HumanLastNames VALUES (51, 'Gomez');
INSERT INTO HumanLastNames VALUES (52, 'Phillips');
INSERT INTO HumanLastNames VALUES (53, 'Evans');
INSERT INTO HumanLastNames VALUES (54, 'Turner');
INSERT INTO HumanLastNames VALUES (55, 'Diaz');
INSERT INTO HumanLastNames VALUES (56, 'Parker');
INSERT INTO HumanLastNames VALUES (57, 'Cruz');
INSERT INTO HumanLastNames VALUES (58, 'Edwards');
INSERT INTO HumanLastNames VALUES (59, 'Collins');
INSERT INTO HumanLastNames VALUES (60, 'Reyes');
INSERT INTO HumanLastNames VALUES (61, 'Stewart');
INSERT INTO HumanLastNames VALUES (62, 'Morris');
INSERT INTO HumanLastNames VALUES (63, 'Morales');
INSERT INTO HumanLastNames VALUES (64, 'Murphy');
INSERT INTO HumanLastNames VALUES (65, 'Cook');
INSERT INTO HumanLastNames VALUES (66, 'Rogers');
INSERT INTO HumanLastNames VALUES (67, 'Gutierrez');
INSERT INTO HumanLastNames VALUES (68, 'Ortiz');
INSERT INTO HumanLastNames VALUES (69, 'Morgan');
INSERT INTO HumanLastNames VALUES (70, 'Cooper');
INSERT INTO HumanLastNames VALUES (71, 'Peterson');
INSERT INTO HumanLastNames VALUES (72, 'Bailey');
INSERT INTO HumanLastNames VALUES (73, 'Reed');
INSERT INTO HumanLastNames VALUES (74, 'Kelly');
INSERT INTO HumanLastNames VALUES (75, 'Howard');
INSERT INTO HumanLastNames VALUES (76, 'Ramos');
INSERT INTO HumanLastNames VALUES (77, 'Kim');
INSERT INTO HumanLastNames VALUES (78, 'Cox');
INSERT INTO HumanLastNames VALUES (79, 'Ward');
INSERT INTO HumanLastNames VALUES (80, 'Richardson');
INSERT INTO HumanLastNames VALUES (81, 'Watson');
INSERT INTO HumanLastNames VALUES (82, 'Brooks');
INSERT INTO HumanLastNames VALUES (83, 'Chavez');
INSERT INTO HumanLastNames VALUES (84, 'Wood');
INSERT INTO HumanLastNames VALUES (85, 'James');
INSERT INTO HumanLastNames VALUES (86, 'Bennett');
INSERT INTO HumanLastNames VALUES (87, 'Gray');
INSERT INTO HumanLastNames VALUES (88, 'Mendoza');
INSERT INTO HumanLastNames VALUES (89, 'Ruiz');
INSERT INTO HumanLastNames VALUES (90, 'Hughes');
INSERT INTO HumanLastNames VALUES (91, 'Price');
INSERT INTO HumanLastNames VALUES (92, 'Alvarez');
INSERT INTO HumanLastNames VALUES (93, 'Castillo');
INSERT INTO HumanLastNames VALUES (94, 'Sanders');
INSERT INTO HumanLastNames VALUES (95, 'Patel');
INSERT INTO HumanLastNames VALUES (96, 'Myers');
INSERT INTO HumanLastNames VALUES (97, 'Long');
INSERT INTO HumanLastNames VALUES (98, 'Ross');
INSERT INTO HumanLastNames VALUES (99, 'Foster');
INSERT INTO HumanLastNames VALUES (100, 'Jimenez');

--Updating the fName, mName, and lName field if fName has a number anywhere in it
UPDATE Gradebook.Student
SET fName = (SELECT name
            FROM HumanFirstNames
            WHERE fName LIKE '%' AND HumanFirstNames.id = trunc(random() * 100) + 1  --Why fName LIKE '%' ? Subquery is non-volatile unless it is correlated to the outer query
            --ORDER BY random()       --Order the table randomly, pick the top row, use it's values. This is an alternate way to get a random name
            LIMIT 1),
    mName = CASE
        WHEN random() > .6 THEN (  --60% chance that a person gets a middle name
            SELECT name
            FROM HumanMiddleNames
            WHERE mName LIKE '%' AND HumanMiddleNames.id = trunc(random() * 25) + 1
            LIMIT 1)
        ELSE
            NULL
    END,
    lName = (SELECT name
            FROM HumanLastNames
            WHERE lName LIKE '%' AND HumanLastNames.id = trunc(random() * 100) + 1
            LIMIT 1)
WHERE fName ~ '[^0-9]';
