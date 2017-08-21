README.md - Gradebook

Sean Murthy   
Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

(C) 2017- DASSL. ALL RIGHTS RESERVED.   
Licensed to others under CC 4.0 BY-SA-NC:   
https://creativecommons.org/licenses/by-nc-sa/4.0/

PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

---

This file describes the procedure to test the script `humanizeStudentData.sql`
which humanizes student data.

Steps to test `humanizeStudentData.sql`:
1. Run `addTestData.sql`: adds test rows
2. Run `humanizeStudentData.sql`: humanizes student rows (object of the test)
3. Run `testResults.sql`: tests result of each row and then deletes test rows

The scripts `addTestData.sql` and `testResults.sql` are present in the same
directory as this README file. The script `humanizeStudentData.sql` is present
in the directory `/src/db/`.

The scripts may be run using a PostgreSQL client such as `psql` and `pgAdmin`.
