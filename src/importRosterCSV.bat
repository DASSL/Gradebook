@ECHO OFF
REM importRosterCSV.bat - Gradebook

REM Kyle Bella, Andrew Figueroa, Sean Murthy

REM CC 4.0 BY-NC-SA
REM https://creativecommons.org/licenses/by-nc-sa/4.0/

REM Copyright (c) 2017- DASSL. ALL RIGHTS RESERVED.

REM ALL ARTIFACTS PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

REM Batch file to importFromRoster Data
REM USAGE: importRosterCSV.bat "filename" year season courseNumber sectionNumber username database server:port

IF "%1"=="" GOTO usage

IF "%4"=="" GOTO argError

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

REM Shifts parameters already set in variables out of scope
SHIFT /1
SHIFT /1
SHIFT /1
SHIFT /1
SHIFT /1
SHIFT /1
SHIFT /1
SHIFT /1

REM batch parameters are now extra and will be ignored
psql %1 %2 %3 %4 %5 %6 %7 %8 %9 -h %hostname% -p %port% -d %database% -U %username% -c "TRUNCATE rosterStaging;" -c "\COPY rosterStaging FROM %filename% WITH csv HEADER" -c "SELECT importFromRoster(%year%, '%season%', '%courseNumber%', '%sectionNumber%');"
goto end

:argError
ECHO You must supply at least Five arguments (filename year season courseNumber sectionNumber)

:usage
ECHO importRosterCSV.bat: Imports a CSV from student roster into Gradebook
ECHO Takes 5-8+ space separated arguments
ECHO Usage:
ECHO importRosterCSV.bat "filename" year season courseNumber sectionNumber username database server:port

:end
pause