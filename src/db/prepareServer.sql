--prepareServer.sql - Gradebook

--Steven Rollo, Andrew Figueroa, Jonathan Middleton, Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU).
-- With contributions from Bruno DaSilva

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

--This script creates app-specific roles and users
-- roles created: Gradebook; users created: GB_WebApp;
-- makes GB_WebApp a member of the Gradebook role as a temporary measure until
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

   --create role gradebook if necessary; give it the required rights
   IF NOT pg_temp.existsRole('gradebook') THEN
      CREATE ROLE gradebook;
   END IF;

   --create role GB_Instructor
   IF NOT pg_temp.existsRole('gb_instructor') THEN
      CREATE ROLE GB_Instructor;
   END IF;

   --create role GB_Registrar
   IF NOT pg_temp.existsRole('gb_registrar') THEN
      CREATE ROLE GB_Registrar;
   END IF;

   --create role GB_RegistrarAdmin
   IF NOT pg_temp.existsRole('gb_registraradmin') THEN
      CREATE ROLE GB_RegistrarAdmin;
   END IF;

   --create role GB_Admissions
   IF NOT pg_temp.existsRole('gb_admissions') THEN
      CREATE ROLE GB_Admissions;
   END IF;

   --create role GB_DBAdmin
   IF NOT pg_temp.existsRole('gb_dbadmin') THEN
      CREATE ROLE GB_DBAdmin;
   END IF;

   --create role GB_Student
   IF NOT pg_temp.existsRole('gb_student') THEN
      CREATE ROLE GB_Student;
   END IF;

   --Grant necessary rights to gradebook
   ALTER ROLE gradebook CREATEROLE CREATEDB;
   GRANT pg_signal_backend TO gradebook;

   --Grant all roles to gradebook role
   GRANT GB_Instructor, GB_Registrar,
         GB_RegistrarAdmin, GB_Admissions, GB_DBAdmin,
         GB_Student
   TO gradebook;


   --create user GB_WebApp if necessary and make sure the user is a member of
   --Gradebook role
   -- a default password is assigned to the user: user/admin should change it
   IF NOT pg_temp.existsRole('gb_webapp') THEN
      CREATE USER GB_WebApp WITH PASSWORD 'dassl2017';
   END IF;

   --make user GB_WebApp a member of role Gradebook
   -- a temporary solution until the role Gradebook is made owner of all
   -- functions, and the functions are made to execute in the context of their
   -- owner
   GRANT gradebook TO GB_WebApp;

END
$$;


COMMIT;
