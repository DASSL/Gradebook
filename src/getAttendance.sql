-- getAttendance.sql

-- Kyle Bella, Steven Rollo, Zaid Bhujwala, Andrew Figueroa, Elly Griffin, Sean Murthy

-- CC 4.0 BY-NC-SA
-- https://creativecommons.org/licenses/by-nc-sa/4.0/

-- Copyright (c) 2017- DASSL. ALL RIGHTS RESERVED.

-- ALL ARTIFACTS PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

-- Adaptation of the Summer DASSL 2017 csvPivotExample.sql to the Gradebook schema
-- ONLY RUN THE QUERY AFTER IMPORTING ROSTER AND OPENCLOSE CSVS

--Function to generate a list of meeting dates from a class schedule (ex. 'MWF' - meaning it meets Mondays, Wednesdays and Fridays)
--as well as a start date and end date to bound the dates.
--The following day codes are recognized:
--M = Monday
--T = Tuesday
--W = Wednesday
--R = Thursday
--F = Friday
--S = Saturday
--Sunday is not handled
--Example usage; returns the date of all Tuesdays and Thursdays between '2017-01-01' and '2017-05-01'
--SELECT * FROM datesFromSchedule(to_date('2017-01-01', 'YYYY-MM-DD'),
--   to_date('2017-05-01', 'YYYY-MM-DD'), 'TR');

START TRANSACTION;

SET LOCAL SCHEMA 'gradebook';

CREATE OR REPLACE FUNCTION datesFromSchedule(startDate DATE, endDate DATE, schedule VARCHAR(7))
RETURNS TABLE (MeetingDate DATE)
AS $$
   --Create a list of all dates between startDate and endDate using a recursive CTE
   WITH RECURSIVE Date_Range AS
   (
      SELECT $1 sd --Start with startDate
      UNION ALL
      SELECT sd + 1 --Increment by one day for each row
      FROM Date_Range
      WHERE sd < $2 --End at endDate
   )
   SELECT sd MeetingDate
   FROM Date_Range --Select each date from Date_Range
   WHERE CASE --Conditional statement: For each day number (WHEN EXTRACT(DOW FROM sd) = <daynum>)
              --check if the schedule string contains the matching day code (M,T,W,R,F, or S)
              --using LIKE (LIKE '%<somechar>%' effectively checks if <somechar> is in a string)
              --If the day code is in schedule, we include that date in the output
      WHEN EXTRACT(DOW FROM sd) = 1 THEN $3 LIKE '%M%'
      WHEN EXTRACT(DOW FROM sd) = 2 THEN $3 LIKE '%T%'
      WHEN EXTRACT(DOW FROM sd) = 3 THEN $3 LIKE '%W%'
      WHEN EXTRACT(DOW FROM sd) = 4 THEN $3 LIKE '%R%'
      WHEN EXTRACT(DOW FROM sd) = 5 THEN $3 LIKE '%F%'
      WHEN EXTRACT(DOW FROM sd) = 6 THEN $3 LIKE '%S%'
   END;
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION getAttendance(SectionID INTEGER)
RETURNS TABLE(dataStr TEXT) AS
$$
    SET LOCAL SCHEMA 'gradebook';
    -- Will give the start and end dates and the ID of the term
    WITH curSec AS
    (
        SELECT N.ID, N.Schedule s, COALESCE(N.StartDate, T.StartDate) sd, COALESCE(N.EndDate, T.EndDate) ed
        FROM Section N JOIN Term T ON N.Term=T.ID
        WHERE N.ID = $1
    -- Needed to "create" a dates table
    ), dates AS
    (
        -- In the Summer DASSL version, dates acted as a relationship table of student and attendanceRecord
        -- Hence, a cross join is necessary here
        SELECT e.student id, ds.MeetingDate md
        FROM enrollee e, datesFromSchedule((SELECT sd FROM curSec), (SELECT ed FROM curSec), (SELECT s FROM curSec)) ds
    -- Will give the final table to format
    ), sdar AS
    (
        SELECT e.student i, da.md d, COALESCE(ar.Status, 'P') c
        FROM enrollee e JOIN dates da ON e.student=da.id
        LEFT OUTER JOIN attendanceRecord ar ON ar.student=e.student AND ar.Date=da.md
        WHERE e.section = (SELECT ID FROM curSec)
    )
    -- This will format the final table to a user-friendly format
    SELECT 'Last' || ',' || 'First' || ',' || 'Middle' || ',' || string_agg(to_char(d, 'MM-DD-YYYY'), ',' ORDER BY d) csv_data
    FROM (SELECT DISTINCT d FROM sdar) dd
    UNION ALL
    SELECT st.LName || ',' || st.FName || ',' || COALESCE(st.MName, '') || ',' || string_agg(c, ',' ORDER BY d)
    FROM sdar JOIN Student st ON sdar.i=st.id
    GROUP BY sdar.i, st.LName, st.FName, st.MName;

$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION getSectionID(Year NUMERIC(4,0), SeasonName VARCHAR(20), Course VARCHAR(8), SectionNumber VARCHAR(3))
RETURNS INTEGER AS
$$
    SET LOCAL SCHEMA 'gradebook';
    WITH curTerm AS
    (
      SELECT T.ID
      FROM Season S JOIN Term T ON S."Order"=T.Season
      WHERE T.Year = $1 AND (S.Name = $2 OR S.Code = $2)
    )
    SELECT N.ID
    FROM Section N JOIN curTerm C ON N.Term=C.ID
    WHERE N.Course = $3 AND N.SectionNumber = $4;
$$ LANGUAGE sql;
COMMIT;

-- stub
START TRANSACTION;
SET LOCAL SCHEMA 'gradebook';
SELECT getAttendance(getSectionID(2017, 'Spring', 'CS110', '05'));
SELECT getAttendance(getSectionID(2017, 'Spring', 'CS110', '72'));
SELECT getAttendance(getSectionID(2017, 'Spring', 'CS110', '74'));
ROLLBACK;
