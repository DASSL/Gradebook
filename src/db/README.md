README.md - Gradebook

Sean Murthy   
Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

(C) 2017- DASSL. ALL RIGHTS RESERVED.   
Licensed to others under CC 4.0 BY-SA-NC:   
https://creativecommons.org/licenses/by-nc-sa/4.0/

PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

---

This file describes the procedure to prepare the database for an installation
of Gradebook.

Steps to prepare the database:
1. Create a new database using a Postgres client such as [psql](https://www.postgresql.org/docs/9.6/static/app-psql.html)
or [createdb](https://www.postgresql.org/docs/9.6/static/app-createdb.html)
2. Run the script `prepareDB.psql` in the context of the newly created database

The script `prepareDB.psql` must be run using psql because it uses psql
meta-commands. Use one of the following methods to run the script:
1. Start `psql` with its usual parameters along with the `-f` command line switch
and the path to the script file. For example:   

      `psql [usual psql parameters] -f prepareDB.psql`

2. Start `psql` with its usual parameters and once inside the interactive shell,
use the `\i` meta-command to execute the script
