README.md - Gradebook

Sean Murthy   
Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

(C) 2017- DASSL. ALL RIGHTS RESERVED.   
Licensed to others under CC 4.0 BY-SA-NC:   
https://creativecommons.org/licenses/by-nc-sa/4.0/

PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

---

## Overview

This file describes the process of installing the data layer of the Gradebook
application and verifying the installation.

## Installation

Installing the data layer involves three simple steps:
1. Prepare the database server
2. Create a database
3. Prepare the database

The installation process involves running SQL scripts (files with `.sql`
extension) and PSQL scripts (files with `.psql` extension). SQL scripts may be
run using any Postgres client such as [`psql`](https://www.postgresql.org/docs/9.6/static/app-psql.html),
but PSQL scripts must be run using `psql`.

__All scripts in the installation process hould be run by a user with superuser
privileges__.

The following alternative means are possible to run either kind of script using
`psql`:

1. Start `psql` with its usual parameters along with the `-f` command line switch
and the path to the script file. For example:

      `psql [usual psql parameters] -f [scriptFilePath]`

2. Start `psql` with its usual parameters and once inside the interactive shell,
use the `\i` meta-command to execute the script

### Prepare the server

Run the SQL script `prepareServer.sql` to prepare the server. This script should
be the first to run, before creating any database for use with Gradebook.

This script defines application-specific role `gradebook` and user `gb_webapp`.
The user is given a default initial password (see the script), and it is highly
recommended that the default password be changed (using a secure Postgres client
such as `psql`).


### Create a database

Create a new database using the `CREATE DATABASE` statement using any Postgres
client or using the [`createdb`](https://www.postgresql.org/docs/9.6/static/app-createdb.html)
client.

The database may be named anything and any number of databases may be created.
However, the role `gradebook` should be set as the owner of each database.

(Multiple Gradebook databases may be used on the same server for multi-tenancy,
that is one database per school. Also, multiple databases may be needed for
development and testing purposes.)

The following examples show alternative means to create a database named
`GB_Data`:

1. Run the following SQL query using any Postgres client:

      ```sql
      CREATE DATABASE GB_DATA WITH OWNER gradebook;
      ```

2. Run the following command at a terminal:

      `createdb [connection parameters] -O gradebook GB_Data`


### Prepare the database

Run the PSQL script `prepareDB.psql` in the context of each database where
Gradebook data is to be stored. This script should be run immediately after
creating the database while the database is still empty.

This script invokes the following SQL scripts to set permissions and to create
schema, table, function, and other kinds of objects the Gradebook application
uses.

- `initializeDB.sql`
- `createTables.sql`
- `addReferenceData.sql`
- `addSeasonMgmt.sql`
- `addSectionMgmt.sql`
- `addAttendanceMgmt.sql`
- `addInstructorMgmt.sql`

The PSQL script and the SQL scripts it invokes should all be in the same
directory. The PSQL script must be run using `psql` (due to the use of `psql`
meta-commands).

## Verifying installation

After the database is prepared, import some sample data to verify installation.
All sample data is located under the directory `/tests/data` and is described
in the README file located in that directory. Most of the scripts to import
data are under the directory `/src/db` and are described in the README files
located in those directories.

Perform the following verification steps by connecting to the database as
the user `gb_webapp`. It is sufficient to complete only the first step shown,
but it is recommended that all steps be performed in the sequence shown. A
verification step is considered successful if it completes without any error.

1. Import the course schedule in the file `/tests/data/OpenClose/2015SpringOpenClose.csv`

2. Assign e-mail addresses to instructors: run the script `/tests/data/InstructorEmail/addEmailByInstructorName.sql`

3. Import the roster in the file `/tests/data/Roster/2017SpringCS110-05Roster.csv`

4. Import attendance data: run the script `/tests/data/Attendance/importAttendance.psql`

5. Humanize student data: run the script `/src/db/humanizeStudentData.sql`

6. Run the following query to obtain a CSV version of the attendance data
imported:

```sql
SELECT * FROM Gradebook.getAttendance(2017, 'Spring', 'CS110', '5');
```
