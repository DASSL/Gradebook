@ECHO OFF
REM Batch file to import openclose Data
REM USAGE: importOpenCloseCSV.bat host port database username "filename" year 'term'

psql -h %1 -p %2 -d %3 -U %4 -c "TRUNCATE openCloseStaging;" -c "\COPY openCloseStaging FROM %5 WITH csv HEADER" -c "SELECT openCloseImport(%6, '%7');"
pause
