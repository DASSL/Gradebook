--addSeasonMgmt.sql - Gradebook

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script creates functions related to seasons
-- the script should be run as part of application installation

--Function to get the details of the season matching a season order
DROP FUNCTION IF EXISTS Gradebook.getSeason(NUMERIC(1,0));

CREATE FUNCTION Gradebook.getSeason(seasonOrder NUMERIC(1,0))
RETURNS TABLE
(
   "Order" NUMERIC(1,0),
   Name VARCHAR(20),
   Code CHAR(1)
)
AS
$$

   SELECT "Order", Name, Code
   FROM Gradebook.Season
   WHERE "Order" = $1;

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT
   ROWS 1;


--Function to get the details of the season matching a "season identification"
-- a season identification is season order, season code, or season name
-- performs case-insensitive match of season name and code
-- this function makes it easier for users to indicate a season by any of the
-- three possible identifiers for seasons
DROP FUNCTION IF EXISTS Gradebook.getSeason(VARCHAR(20));

CREATE FUNCTION Gradebook.getSeason(seasonIdentification VARCHAR(20))
RETURNS TABLE
(
   "Order" NUMERIC(1,0),
   Name VARCHAR(20),
   Code CHAR(1)
)
AS
$$

   SELECT "Order", Name, Code
   FROM Gradebook.Season
   WHERE CASE
            WHEN $1 ~ '^[0-9]$' THEN "Order" = to_number($1,'9')
            WHEN LENGTH($1) = 1 THEN LOWER(Code) = LOWER($1)
            ELSE LOWER(TRIM(Name)) = LOWER(TRIM($1))
         END;

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT
   ROWS 1;

--Function to get the "order" of the season matching a "season identification"
DROP FUNCTION IF EXISTS Gradebook.getSeasonOrder(VARCHAR(20));

CREATE FUNCTION Gradebook.getSeasonOrder(seasonIdentification VARCHAR(20))
RETURNS NUMERIC(1,0)
AS
$$

   SELECT "Order"
   FROM Gradebook.getSeason($1);

$$ LANGUAGE sql
   STABLE
   RETURNS NULL ON NULL INPUT;


--Checks if the supplied year and season belong to the next term in sequence.
-- Returns true if the supplied term is the next term, otherwise false.
-- This is accomplished using the expression:
-- currentYear * COUNT(Seasons) + Season + 1 =
-- newYear * COUNT(Seasons) + Season
-- Essentially, each year is mapped to a scale counting for the number of
-- seasons that are in Gradebook.  This allows a simple equality check to see
-- if the supplied term is in sequence
DROP FUNCTION IF EXISTS Gradebook.checkTermSequence(Year INT, Season VARCHAR(10));

CREATE OR REPLACE FUNCTION Gradebook.checkTermSequence(Year INT, Season VARCHAR(10))
RETURNS BOOLEAN AS
$$
   --Get each term from the latest year
   WITH latestYear AS
   (
      SELECT Year, Season
      FROM Gradebook.Term
      WHERE Year = (SELECT MAX(Year) FROM Gradebook.Term)
   )
   SELECT CASE --Check for the case when there are no terms, as we can't check
               --the sequence if it hasn't been started yet
      WHEN (SELECT COUNT(*) FROM Gradebook.Term) > 0 THEN
         (
            MAX(LY.Year) * (SELECT COUNT(*) FROM Gradebook.Season) +
            MAX(LY.Season) + 1
         ) =
         (
            $1 * (SELECT COUNT(*) FROM Gradebook.Season) +
            (SELECT "Order" FROM Gradebook.Season WHERE name = $2 OR code = $2)
         )
      ELSE
         TRUE
      END
   FROM latestYear LY
$$ LANGUAGE sql;
