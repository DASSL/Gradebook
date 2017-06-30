@ECHO OFF
REM Batch file to import openclose Data
REM USAGE: importOpenCloseCSV.bat "filename" year season username database server:port

IF "%1"=="" GOTO usage

IF "%3"=="" GOTO argError

IF "%4"=="" (
    SET username=postgres
) ELSE (
    SET username=%4
)

IF "%5"=="" (
    SET database=postgres
) ELSE (
    SET database=%5
)

IF "%6"=="" (
   SET hostname=localhost
) ELSE (
   FOR /f "tokens=1,2 delims=:" %%a in ("%6") DO SET hostname=%%a&SET port=%%b
)

IF "%port%"=="" SET port=5432

psql -h %hostname% -p %port% -d %database% -U %username% -c "TRUNCATE openCloseStaging;" -c "\COPY openCloseStaging FROM %1 WITH csv HEADER" -c "SELECT openCloseImport(%2, '%3');"
goto end

:argError
ECHO You must supply at least three arguments (filename year season)

:usage
ECHO importOpenCloseCSV.bat: Imports a CSV from OpenClose into Gradebook
ECHO Takes 3-6 space separated arguments
ECHO Usage:
ECHO importOpenCloseCSV.bat "filename" year season username database server:port

:end
pause
