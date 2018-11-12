--prepareServer.sql - Gradebook

--Edited by Bruno DaSilva, Andrew Figueroa, and Jonathan Middleton (Team Alpha)
-- in support of CS305 coursework at Western Connecticut State University.

--Licensed to others under CC 4.0 BY-SA-NC

--This work is a derivative of Gradebook, originally developed by:

--Andrew Figueroa, Steven Rollo, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script creates app-specific roles and users
-- roles created: Gradebook; users created: alpha_GB_WebApp;
-- makes alpha_GB_WebApp a member of the Gradebook role as a temporary measure until
-- roles and policies are finalized

--This script should be run once on the server where Gradebook data will be
--stored
-- it should be the first script to run in the Gradebook installation process;
-- it should be run before creating a database where Gradebook data is to be
-- stored

--This script should be run by a superuser

START TRANSACTION;

--Suppress messages below WARNING level for the duration of this script
SET LOCAL client_min_messages TO WARNING;

--Make sure current user is superuser
DO
$$
BEGIN
   IF NOT EXISTS (SELECT * FROM pg_catalog.pg_roles
                  WHERE rolname = current_user AND rolsuper = TRUE
                 ) THEN
      RAISE EXCEPTION 'Insufficient privileges: '
                      'script must be run by a superuser';
   END IF;
END
$$;


--Create a temporary function to test if a role with the given name exists
-- performs case-sensitive test for roleName;
-- role names are intentionally not case folded at this time
CREATE OR REPLACE FUNCTION pg_temp.existsRole(roleName VARCHAR(63))
RETURNS BOOLEAN AS
$$
   SELECT 1 = (SELECT COUNT(*) FROM pg_catalog.pg_roles WHERE rolname = $1);
$$ LANGUAGE sql;

--Create app-specific roles and users
-- also give the Gradebook role the ability to create roles and databases, as
-- well as the ability to manipulate backends: cancel query, terminate, etc.
DO
$$
BEGIN

   --create role alpha if necessary; give it the required rights
   IF NOT pg_temp.existsRole('alpha') THEN
      CREATE ROLE alpha;
   END IF;

   --create role alpha_GB_Instructor
   IF NOT pg_temp.existsRole('alpha_gb_instructor') THEN
      CREATE ROLE alpha_GB_Instructor;
   END IF;

   --create role alpha_GB_Registrar
   IF NOT pg_temp.existsRole('alpha_gb_registrar') THEN
      CREATE ROLE alpha_GB_Registrar;
   END IF;

   --create role alpha_GB_RegistrarAdmin
   IF NOT pg_temp.existsRole('alpha_gb_registraradmin') THEN
      CREATE ROLE alpha_GB_RegistrarAdmin;
   END IF;

   --create role alpha_GB_Admissions
   IF NOT pg_temp.existsRole('alpha_gb_admissions') THEN
      CREATE ROLE alpha_GB_Admissions;
   END IF;

   --create role alpha_GB_DBAdmin
   IF NOT pg_temp.existsRole('alpha_gb_dbadmin') THEN
      CREATE ROLE alpha_GB_DBAdmin;
   END IF;

   --create role alpha_GB_Student
   IF NOT pg_temp.existsRole('alpha_gb_student') THEN
      CREATE ROLE alpha_GB_Student;
   END IF;

   --CS305-Alpha - removed a line to grant CREATEDB to Gradebook

   --Grant all roles to gradebook role
   --CS305-Alpha - removed grant of pg_signal_backend
   GRANT alpha_GB_Instructor, alpha_GB_Registrar,
         alpha_GB_RegistrarAdmin, alpha_GB_Admissions, alpha_GB_DBAdmin,
         alpha_GB_Student
   TO alpha;


   --create user alpha_GB_WebApp if necessary and make sure the user is a member of
   --Gradebook role
   -- a default password is assigned to the user: user/admin should change it
   IF NOT pg_temp.existsRole('alpha_gb_webapp') THEN
      CREATE USER alpha_GB_WebApp WITH PASSWORD 'dassl2017';
   END IF;

   --make user alpha_GB_WebApp a member of role Gradebook
   -- a temporary solution until the role Gradebook is made owner of all
   -- functions, and the functions are made to execute in the context of their
   -- owner
   GRANT alpha TO alpha_GB_WebApp;

END
$$;


COMMIT;
