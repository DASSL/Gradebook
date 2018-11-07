/*
addAttendanceMgmt.sql - Gradebook

Kyle Bella, Steven Rollo, Zaid Bhujwala, Andrew Figueroa, Elly Griffin, Sean Murthy
Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

(C) 2017- DASSL. ALL RIGHTS RESERVED.
Licensed to others under CC 4.0 BY-SA-NC:
https://creativecommons.org/licenses/by-nc-sa/4.0/

PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

*/

--This file has some issues related to formatting, clarity, and efficiency
-- fix after milestone M1: delete this comment block after fixing the issues

--Suppress messages below WARNING level for the duration of this script
SET LOCAL client_min_messages TO WARNING;


--Drop function from M1 that has since been renamed or removed
-- remove the DROP statement after M2
DROP FUNCTION IF EXISTS datesFromSchedule(DATE, DATE, VARCHAR(7));


--Function to generate a list of dates for a class schedule, within a date range
-- startDate should not be past endDate
-- schedule is a string such as 'MWF' which means Mondays, Wednesdays, Fridays

--The following day codes are recognized:
--N = Sunday
--M = Monday
--T = Tuesday
--W = Wednesday
--R = Thursday
--F = Friday
--S = Saturday

--Example usage: get dates of Tuesdays and Thursdays b/w 2017-01-01 and 2017-05-01:
-- SELECT * FROM getScheduleDates('2017-01-01', '2017-05-01', 'TR');

DROP FUNCTION IF EXISTS getScheduleDates(DATE, DATE, VARCHAR(7));

CREATE FUNCTION getScheduleDates(startDate DATE, endDate DATE,
                                           schedule VARCHAR(7)
                                          )
RETURNS TABLE (ScheduleDate DATE)
AS $$
   --enumerate all dates between startDate and endDate using a recursive CTE
   -- CTE can be eliminated by using the following call in the outer FROM clause
   -- generate_series(startDate, endDate, '1 day')
   WITH RECURSIVE EnumeratedDate AS
   (
      SELECT $1 sd --Start with startDate as long as it is not past the end date
      WHERE $1 <= $2
      UNION ALL
      SELECT sd + 1 --Increment by one day for each row
      FROM EnumeratedDate
      WHERE sd < $2 --End at endDate
   )
   SELECT sd
   FROM EnumeratedDate
   WHERE CASE --test match to schedule by extracting the day-of-week for the date
      WHEN EXTRACT(DOW FROM sd) = 0 THEN $3 LIKE '%N%'
      WHEN EXTRACT(DOW FROM sd) = 1 THEN $3 LIKE '%M%'
      WHEN EXTRACT(DOW FROM sd) = 2 THEN $3 LIKE '%T%'
      WHEN EXTRACT(DOW FROM sd) = 3 THEN $3 LIKE '%W%'
      WHEN EXTRACT(DOW FROM sd) = 4 THEN $3 LIKE '%R%'
      WHEN EXTRACT(DOW FROM sd) = 5 THEN $3 LIKE '%F%'
      WHEN EXTRACT(DOW FROM sd) = 6 THEN $3 LIKE '%S%'
   END;
$$ LANGUAGE sql
            IMMUTABLE
            RETURNS NULL ON NULL INPUT;


--Function to get attendance for a section ID
DROP FUNCTION IF EXISTS getAttendance(INT);

CREATE FUNCTION getAttendance(sectionID INT)
RETURNS TABLE(AttendanceCsvWithHeader TEXT) AS
$$

   WITH
   --get all dates the section meets: each date will be unique
   SectionDate AS
   (
      SELECT ScheduleDate
      FROM Section,
           getScheduleDates(StartDate, EndDate, Schedule)
      WHERE ID = $1
   ),
   --combine every student enrolled in section w/ each meeting date of section
   Enrollee_Date AS
   (
      SELECT Student, ScheduleDate
      FROM Enrollee, SectionDate
      WHERE Section = $1
   ),
   --get the recorded attendance for each enrollee, marking as "Present" if
   --attendance is not recorded for an enrollee-date combo
   sdar AS
   (
      SELECT ed.Student, ScheduleDate, COALESCE(ar.Status, 'P') c
      FROM Enrollee_Date ed
           LEFT OUTER JOIN AttendanceRecord ar
           ON ed.Student = ar.Student
              AND ed.ScheduleDate = ar.Date
              AND ar.Section = $1 --can't move test on section to WHERE clause
   )
   --generate attendance data as CSV data with headers
   -- order columns in each row by meeting date;
   -- order rows in the data portion by student name;
   -- function concat_ws is used to easily generate CSV strings
   SELECT concat_ws(',', 'Last', 'First', 'Middle',
                     string_agg(to_char(ScheduleDate, 'MM-DD-YYYY'), ','
                                ORDER BY ScheduleDate
                               )
                    ) csv_header
   FROM SectionDate
   UNION ALL
   (
      SELECT concat_ws(',', st.LName, st.FName, COALESCE(st.MName, ''),
                      string_agg(c, ',' ORDER BY ScheduleDate)
                     )
      FROM sdar JOIN Student st ON sdar.Student = st.ID
      GROUP BY st.ID
      ORDER BY st.LName, st.FName, COALESCE(st.MName, '')
   );

$$ LANGUAGE sql;


--Function to get attendance for a year-season-course-section# combo
DROP FUNCTION IF EXISTS getAttendance(NUMERIC(4,0), VARCHAR(20),
                                                VARCHAR(8), VARCHAR(3)
                                               );

CREATE FUNCTION getAttendance(year NUMERIC(4,0),
                                                   seasonIdentification VARCHAR(20),
                                                   course VARCHAR(8),
                                                   sectionNumber VARCHAR(3)
                                                  )
RETURNS TABLE(AttendanceCsvWithHeader TEXT) AS
$$
   SELECT getAttendance(getSectionID($1, $2, $3, $4));
$$ LANGUAGE sql;
