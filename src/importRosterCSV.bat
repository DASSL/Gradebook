@ECHO OFF
REM Batch file to import roster data
REM USAGE: importRosterCSV.bat host port database username "filename" year season course section

REM year and season match the term that the roster belongs to: e.g. 2017 Spring

REM course is the courseNumber of a course e.g. CS110

REM section is the section that the roster belongs to e.g. 5 

psql -h %1 -p %2 -d %3 -U %4 -c "TRUNCATE rosterStaging;" -c "\COPY rosterStaging FROM %5 WITH csv HEADER" -c "SELECT importFromRoster(%6, '%7', '%8', '%9');"
