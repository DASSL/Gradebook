--addSeasonMgmt.sql - Gradebook

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script creates functions related to seasons
-- the script should be run as part of application installation

START TRANSACTION;

--Suppress messages below WARNING level for the duration of this script
SET LOCAL client_min_messages TO WARNING;

--Set schema to reference in functions and tables, pg_temp is specified
-- last for security purposes
SET LOCAL search_path TO 'alpha', 'pg_temp';


--Function to get the details of the season matching a "season identification"
-- a season identification is season order, season code, or season name
-- performs case-insensitive match of season name and code
-- this function makes it easier for users to indicate a season by any of the
-- three possible identifiers for seasons
DROP FUNCTION IF EXISTS getSeason(VARCHAR(20));

CREATE FUNCTION getSeason(seasonIdentification VARCHAR(20))
RETURNS TABLE
(
   "Order" NUMERIC(1,0),
   Name VARCHAR(20),
   Code CHAR(1)
)
AS
$$
   SELECT "Order", Name, Code
   FROM Season
   WHERE CASE
            WHEN $1 ~ '^[0-9]$' THEN "Order" = to_number($1,'9')
            WHEN LENGTH($1) = 1 THEN Code = UPPER($1)
            ELSE LOWER(TRIM(Name)) = LOWER(TRIM($1))
         END;
$$ LANGUAGE sql
   SECURITY DEFINER
SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT
   ROWS 1;

REVOKE ALL ON FUNCTION getSeason(VARCHAR(20)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getSeason(VARCHAR(20))
   TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar, 
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;

--Function to get the details of the season matching a season order
-- this function exists to support clients that pass season order as a number
DROP FUNCTION IF EXISTS getSeason(NUMERIC(1,0));

CREATE FUNCTION getSeason(seasonOrder NUMERIC(1,0))
RETURNS TABLE
(
   "Order" NUMERIC(1,0),
   Name VARCHAR(20),
   Code CHAR(1)
)
AS
$$
   SELECT "Order", Name, Code
   FROM Season
   WHERE "Order" = $1;
$$ LANGUAGE sql
   SECURITY DEFINER
SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT
   ROWS 1;

REVOKE ALL ON FUNCTION getSeason(NUMERIC(1,0)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getSeason(NUMERIC(1,0)) 
   TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar, 
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;


--Function to get the "order" of the season matching a "season identification"
DROP FUNCTION IF EXISTS getSeasonOrder(VARCHAR(20));

CREATE FUNCTION getSeasonOrder(seasonIdentification VARCHAR(20))
RETURNS NUMERIC(1,0)
AS
$$
   SELECT "Order"
   FROM getSeason($1);
$$ LANGUAGE sql
   SECURITY DEFINER
SET search_path FROM CURRENT
   STABLE
   RETURNS NULL ON NULL INPUT;

REVOKE ALL ON FUNCTION getSeasonOrder(VARCHAR(20)) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION getSeasonOrder(VARCHAR(20)) 
   TO alpha_GB_Webapp, alpha_GB_Instructor, alpha_GB_Student, alpha_GB_Registrar, 
   alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin;

--Returns a table listing season names and codes from the Season table.
CREATE OR REPLACE FUNCTION listSeasons()
   RETURNS TABLE ("Order" NUMERIC(1,0),
                  Name VARCHAR(20),
                  Code CHAR(1)
                ) AS
$$
   SELECT "Order", s.name, s.code
   FROM season s;
$$ LANGUAGE sql
   SECURITY DEFINER
   SET search_path FROM CURRENT
   STABLE;

ALTER FUNCTION listSeasons() OWNER TO CURRENT_USER;


COMMIT;
