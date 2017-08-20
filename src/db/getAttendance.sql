/*
getAttendance.sql - Gradebook

Kyle Bella, Steven Rollo, Zaid Bhujwala, Andrew Figueroa, Elly Griffin, Sean Murthy
Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

(C) 2017- DASSL. ALL RIGHTS RESERVED.
Licensed to others under CC 4.0 BY-SA-NC:
https://creativecommons.org/licenses/by-nc-sa/4.0/

PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

*/

--This file has some issues related to formatting, clarity, and efficiency
-- fix after milestone M1: delete this comment block after fixing the issues


--Function to generate a list of meeting dates from a class schedule
--(e.g., 'MWF' - meaning it meets Mondays, Wednesdays and Fridays)
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

CREATE OR REPLACE FUNCTION Gradebook.datesFromSchedule(startDate DATE, endDate DATE, schedule VARCHAR(7))
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


CREATE OR REPLACE FUNCTION getAttendance(sectionID INTEGER)
RETURNS TABLE(AttendanceCsvWithHeader TEXT) AS
$$
    -- Will give the start and end dates and the ID of the term
    WITH curSec AS
    (
        SELECT N.ID, N.Schedule s, COALESCE(N.StartDate, T.StartDate) sd, COALESCE(N.EndDate, T.EndDate) ed
        FROM Gradebook.Section N JOIN Gradebook.Term T ON N.Term=T.ID
        WHERE N.ID = $1
    -- Needed to make a more stable version of datesFromSchedule() output
    ), datesFromScheduleTable AS
    (
        -- this cross join will return the same amount of rows as the table that datesFromSchedule() outputs
        -- since curSec will have at most 1 row
        SELECT d.MeetingDate
        FROM curSec cs, Gradebook.datesFromSchedule(cs.sd, cs.ed, cs.s) d
    -- Needed to "create" a dates table
    ), dates AS
    (
        -- In the Summer DASSL version, dates acted as a relationship table of student and attendanceRecord
        -- Hence, a cross join is necessary here
        SELECT e.student id, ds.MeetingDate md
        FROM Gradebook.enrollee e, datesFromScheduleTable ds
    -- Will give the final table to format
    ), sdar AS
    (
        SELECT e.student i, da.md d, COALESCE(ar.Status, 'P') c
        FROM Gradebook.enrollee e JOIN dates da ON e.student=da.id
        LEFT OUTER JOIN Gradebook.attendanceRecord ar ON ar.student=e.student AND ar.Date=da.md
        WHERE e.section = $1
    )
    --format the final table to a user-friendly CSV format with headers
    -- the data portion of the result is ordered by student name
    -- function concat_ws is used to generate CSV strings
    SELECT concat_ws(',', 'Last', 'First', 'Middle',
                     string_agg(to_char(d, 'MM-DD-YYYY'), ',' ORDER BY d)
                    ) csv_header
    FROM (SELECT DISTINCT d FROM sdar) dd
    UNION ALL
    (SELECT concat_ws(',', st.LName, st.FName, COALESCE(st.MName, ''),
                      string_agg(c, ',' ORDER BY d)
                     )
     FROM sdar JOIN Gradebook.Student st ON sdar.i=st.id
     GROUP BY st.id
     ORDER BY st.LName, st.FName, COALESCE(st.MName, '')
    );

$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION getAttendance(year NUMERIC(4,0), season VARCHAR(20),
                                         course VARCHAR(8),
                                         sectionNumber VARCHAR(3)
                                        )
RETURNS TABLE(AttendanceCsvWithHeader TEXT) AS
$$
   -- after milestone M1, replace the CTE curTerm with call to getSeasonOrder
   WITH curTerm AS
   (
      SELECT T.ID
      FROM Gradebook.Season S JOIN Gradebook.Term T ON S."Order"=T.Season
      WHERE T.Year = $1 AND (S.Name = $2 OR S.Code = $2)
   )
   SELECT getAttendance(N.ID)
   FROM Gradebook.Section N JOIN curTerm C ON N.Term=C.ID
   WHERE N.Course = $3 AND N.SectionNumber = $4;

$$ LANGUAGE sql;
