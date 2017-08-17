/*
testResults.sql - Gradebook

Sean Murthy
Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)


(C) 2017- DASSL. ALL RIGHTS RESERVED.
Licensed to others under CC 4.0 BY-SA-NC:
https://creativecommons.org/licenses/by-nc-sa/4.0/

PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

This script tests the result of running the script humanizeStudentData.sql

Steps to test humanizeStudentData.sql:
1. Run addTestData.sql: adds test rows
2. Run humanizeStudentData.sql: humanizes student rows (object of the test)
3. Run this script: tests result of each row and then deletes test rows

This script tests if humanization has impacted each test row as expected:
- comment before each test describes the test case
- uses the Email column to locate specific test rows

*/

DO
$$
BEGIN

   --test existence of test rows: there should be 8 test rows

   RAISE INFO '%   Row count',
   (SELECT
      CASE (SELECT COUNT(*) FROM Gradebook.Student
            WHERE Email ~ '[1-8]@example\.com'
           )
         WHEN 8 THEN 'PASS'
         ELSE 'FAIL: Code 9'
      END
   );

   --test rows that should be altered by humanization

   --anonymized FName and MName; empty LName; LName should remain empty
   RAISE INFO '%   1@example.com',
   (SELECT
      CASE CONCAT(FName, MName) ~* '^[0-9a-f]+$' OR LName <> ''
         WHEN true THEN 'FAIL: Code 1'
         ELSE 'PASS'
      END
    FROM Gradebook.Student
    WHERE Email = '1@example.com'
   );

   --anon FName and MName; NULL LName; LName should remain NULL
   RAISE INFO '%   2@example.com',
   (SELECT
      CASE CONCAT(FName, MName) ~* '^[0-9a-f]+$' OR LName IS NOT NULL
         WHEN true THEN 'FAIL: Code 2'
         ELSE 'PASS'
      END
    FROM Gradebook.Student
    WHERE Email = '2@example.com'
   );

   --anon FName and LName; empty MName; MName should remain empty
   RAISE INFO '%   3@example.com',
   (SELECT
      CASE CONCAT(FName, LName) ~* '^[0-9a-f]+$' OR MName <> ''
         WHEN true THEN 'FAIL: Code 3'
         ELSE 'PASS'
      END
    FROM Gradebook.Student
    WHERE Email = '3@example.com'
   );

   --anon FName and LName; NULL MName; MName should remain NULL
   RAISE INFO '%   4@example.com',
   (SELECT
      CASE CONCAT(FName, LName) ~* '^[0-9a-f]+$' OR MName IS NOT NULL
         WHEN true THEN 'FAIL: Code 4'
         ELSE 'PASS'
      END
    FROM Gradebook.Student
    WHERE Email = '4@example.com'
   );

   --anon MName and LName; NULL FName; FName should remain NULL
   RAISE INFO '%   5@example.com',
   (SELECT
      CASE CONCAT(MName, LName) ~* '^[0-9a-f]+$' OR FName IS NOT NULL
         WHEN true THEN 'FAIL: Code 5'
         ELSE 'PASS'
      END
    FROM Gradebook.Student
    WHERE Email = '5@example.com'
   );

   --anon LName; NULL FName, empty MName; FName should stay NULL and MName empty
   RAISE INFO '%   6@example.com',
   (SELECT
      CASE LName ~* '^[0-9a-f]+$' OR FName IS NOT NULL OR MName <> ''
         WHEN true THEN 'FAIL: Code 6'
         ELSE 'PASS'
      END
    FROM Gradebook.Student
    WHERE Email = '6@example.com'
   );

   --test rows that should not be altered by humanization

   --actual FName and LName; NULL mname
   RAISE INFO '%   7@example.com',
   (SELECT
      CASE FName <> 'Mary' OR MName IS NOT NULL OR LName <> 'Jane'
         WHEN true THEN 'FAIL: Code 7'
         ELSE 'PASS'
      END
    FROM Gradebook.Student
    WHERE Email = '7@example.com'
   );

   --actual LName; empty FName and MName
   RAISE INFO '%   8@example.com',
   (SELECT
      CASE FName <> '' OR MName <> '' OR LName <> 'Henry'
         WHEN true THEN 'FAIL: Code 8'
         ELSE 'PASS'
      END
    FROM Gradebook.Student
    WHERE Email = '8@example.com'
   );


   --remove test rows
   DELETE FROM Gradebook.Student
   WHERE Email ~ '[1-8]@example\.com';

END
$$;
