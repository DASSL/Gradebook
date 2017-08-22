/*
addTestData.sql - Gradebook

Sean Murthy
Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)


(C) 2017- DASSL. ALL RIGHTS RESERVED.
Licensed to others under CC 4.0 BY-SA-NC:
https://creativecommons.org/licenses/by-nc-sa/4.0/

PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

This script adds some test rows to the Student table as part of testing the
script humanizeStudentData.sql

Steps to test humanizeStudentData.sql:
1. Run this script: adds test rows
2. Run humanizeStudentData.sql: humanizes student rows (object of the test)
3. Run testResults.sql: tests result of each row and then deletes test rows

This script adds eight Student rows:
- the md5 expressions mimic data that anonymization adds to the table;
- uses e-mail addresses of the form 'n@example.com' where 'n' is a digit;
- assumes the e-mail addresses added are not already in the table;
- comments before each inserted row describe the test case the row represents

The domain 'example.com' is intended by W3C for testing purposes: that domain
cannot actually be registered and is therefore guaranteed not to appear in any
actual email address

*/

INSERT INTO Gradebook.Student(FName, MName, LName, SchoolIssuedID, Email)
VALUES

   --rows that should be altered by humanization

   --anon FName and MName; empty LName; LName should remain empty
   (md5(random()::text || clock_timestamp()::text),
    md5(random()::text || clock_timestamp()::text),
    '',
    md5(random()::text || clock_timestamp()::text),
    '1@example.com'
   ),

   --anonymized FName and MName; NULL LName; LName should remain NULL
   (md5(random()::text || clock_timestamp()::text),
    md5(random()::text || clock_timestamp()::text),
    NULL,
    md5(random()::text || clock_timestamp()::text),
    '2@example.com'
   ),

   --anon FName and LName; empty MName; MName should remain empty
   (md5(random()::text || clock_timestamp()::text),
    '',
    md5(random()::text || clock_timestamp()::text),
    md5(random()::text || clock_timestamp()::text),
    '3@example.com'
   ),

   --anon FName and LName; NULL MName; MName should remain NULL
   (md5(random()::text || clock_timestamp()::text),
    NULL,
    md5(random()::text || clock_timestamp()::text),
    md5(random()::text || clock_timestamp()::text),
    '4@example.com'
   ),

   --anon MName and LName; NULL FName; FName should remain NULL
   (NULL,
    md5(random()::text || clock_timestamp()::text),
    md5(random()::text || clock_timestamp()::text),
    md5(random()::text || clock_timestamp()::text),
    '5@example.com'
   ),

   --anon LName; NULL FName, empty MName; FName should stay NULL and MName empty
   (NULL,
    '',
    md5(random()::text || clock_timestamp()::text),
    md5(random()::text || clock_timestamp()::text),
    '6@example.com'
   ),

   --rows that should not be altered by humanization

   --actual FName and LName; NULL MName
   ('Mary',
    NULL,
    'Jane',
    md5(random()::text || clock_timestamp()::text),
    '7@example.com'
   ),

   --actual LName; empty FName and MName
   ('',
    '',
    'Henry',
    md5(random()::text || clock_timestamp()::text),
    '8@example.com'
   );
