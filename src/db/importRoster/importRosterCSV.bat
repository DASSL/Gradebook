@ECHO OFF
REM importRosterCSV.bat - Gradebook

REM Kyle Bella, Andrew Figueroa, Steven Rollo, Sean Murthy

REM CC 4.0 BY-NC-SA
REM https://creativecommons.org/licenses/by-nc-sa/4.0/

REM Copyright (c) 2017- DASSL. ALL RIGHTS RESERVED.

REM ALL ARTIFACTS PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


REM Batch file to importFromRoster data
REM USAGE: importRosterCSV.bat "filename" year 'season' 'courseNumber' 'sectionNumber' username database server:port optional-psql-commands
REM year like 2017
REM season is the order, name, or code of a season as used in the Season table
REM courseNumber like 'CS110'
REM sectionNumber like '01'
REM Up to 9 additional args can be provided following the required ones


IF "%1"=="" GOTO usage

IF "%5"=="" GOTO argError

SET filename=%1
SET year=%2
SET season=%3
SET courseNumber=%4
SET sectionNumber=%5

IF "%6"=="" (
    SET username=postgres
) ELSE (
    SET username=%6
)

IF "%7"=="" (
    SET database=postgres
) ELSE (
    SET database=%7
)

IF "%8"=="" (
    SET hostname=localhost
) ELSE (
    FOR /f "tokens=1,2 delims=:" %%a in ("%8") DO SET hostname=%%a&SET port=%%b
)

IF "%port%"=="" SET port=5432


REM SHIFT /1 moves parameters down by 1, making %1 out of scope, and allowing a new parameter to be referenced
SHIFT /1
SHIFT /1
SHIFT /1
SHIFT /1
SHIFT /1
SHIFT /1
SHIFT /1
SHIFT /1


REM Empty parameters will be ignored
REM Using ^ allows a command to continue onto the next line
REM psql's single-transaction flag results in all of the statements provided through the
REM  -c and -f options to be run as a single transaction
REM This allows the use of a temporary table without it being automatically dropped
REM  due to the session being closed between statements

psql %1 %2 %3 %4 %5 %6 %7 %8 %9 -h %hostname% -p %port% -d %database% -U %username%^
 --single-transaction -f "prepareRosterImport.sql"^
 -c "\COPY rosterStaging FROM %filename% WITH csv HEADER"^
 -c "SELECT pg_temp.importRoster(%year%, '%season%', '%courseNumber%', '%sectionNumber%');"
goto end


:argError
ECHO You must supply at least five arguments (filename year season courseNumber sectionNumber)

:usage
ECHO importRosterCSV.bat: Imports a CSV from a student roster into the Gradebook schema
ECHO Takes 5+ space separated arguments
ECHO Usage:
ECHO importRosterCSV.bat "filename" year 'season' 'courseNumber' 'sectionNumber' username database server:port optional-psql-commands

:end
pause
