--testAddInstructorMgmt.sql - Gradebook

--Sean Murthy
--Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

--(C) 2017- DASSL. ALL RIGHTS RESERVED.
--Licensed to others under CC 4.0 BY-SA-NC
--https://creativecommons.org/licenses/by-nc-sa/4.0/

--PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


--This script tests the functions in the script addInstructorMgmt.sql
-- proceeds in two steps: adds some test data; run some tests
-- abandons all test data added by explicitly rolling back the transaction


START TRANSACTION;

DO
$$

--variables to store IDs of particular rows created
DECLARE term2017Spring INTEGER;
DECLARE term2017Summer INTEGER;
DECLARE instructor1 INTEGER;
DECLARE instructor2 INTEGER;

BEGIN

--add test data

   --add two courses
   INSERT INTO Gradebook.Course
   VALUES
      ('AB101', 'Course AB 101'),
      ('CD201', 'Course CD 201')
   ON CONFLICT DO NOTHING;

   --add two seasons
   INSERT INTO Gradebook.Season
   VALUES
      (0, 'Spring', 'S'),
      (1, 'Summer', 'M')
   ON CONFLICT DO NOTHING;

   --add two terms: 2017 Spring, 2017 Summer
   INSERT INTO Gradebook.Term(Year, Season, StartDate, EndDate)
   VALUES
      (2017, 0, current_date, current_date+1),
      (2017, 1, current_date, current_date+1)
   ON CONFLICT DO NOTHING;

   --extract the IDs assigned to the two terms just added
   SELECT ID FROM Gradebook.Term
   WHERE Year = 2017 AND Season = 0
   INTO term2017Spring;

   SELECT ID FROM Gradebook.Term
   WHERE Year = 2017 AND Season = 1
   INTO term2017Summer;

   --add two instructors
   --the email addresses used are expected to be unique due to using example.com
   --however, because some tests are count-based, do not ignore conflicts as is
   --done with other tables; instead let the transaction fail so the test is
   --abandoned
   INSERT INTO Gradebook.Instructor(FName, LName, Email)
   VALUES
      ('F1', 'L1', 'f1.l1@example.com'),
      ('F2', 'L1', 'f2.l2@example.com');

   --extract IDs of the two instructors
   SELECT ID FROM Gradebook.Instructor
   WHERE Email = 'f1.l1@example.com'
   INTO instructor1;

   SELECT ID FROM Gradebook.Instructor
   WHERE Email = 'f2.l2@example.com'
   INTO instructor2;

   --add three sections: no insert conflict possible because instructors are new
   --instructor1 and instructor2 co-teach a section
   --i1 and i2 each teach their own section as well
   --i1 teaches two sections in just one term: 2017 Spring
   --i2 teaches one section in 2017 Spring; one in 2017 Summer
   INSERT INTO Gradebook.Section(Term, Course, SectionNumber, CRN,
                                 Instructor1, Instructor2
                                )
   VALUES
      (term2017Spring, 'AB101', '01', 'CRN01', instructor1, instructor2),
      (term2017Spring, 'CD201', '05', 'CRN02', instructor1, NULL),
      (term2017Summer, 'AB101', '02', 'CRN03', instructor2, NULL);

   ---------------------------------------------------------------------------

   --run tests

   --test if getInstructors returns same #rows as directly obtained from table
   RAISE INFO '%   getInstructors Count',
   (SELECT
      CASE ((SELECT COUNT(*) FROM Gradebook.getInstructors())
            =
            (SELECT COUNT(*) FROM Gradebook.Instructor)
           )
         WHEN true THEN 'PASS'
         ELSE 'FAIL: Code 1'
      END
   );


   --test if getInstructor finds instructor1 by e-mail address
   RAISE INFO '%   getInstructor Count',
   (SELECT
      CASE (SELECT COUNT(*) FROM Gradebook.getInstructor('f1.l1@example.com'))
         WHEN 1 THEN 'PASS'
         ELSE 'FAIL: Code 2'
      END
   );


   --test if getInstructor does not return rows for an invalid e-mail address
   --an invalid email address is used to simulate look-up falure
   RAISE INFO '%   getInstructor Count Negative',
   (SELECT
      CASE (SELECT COUNT(*) FROM Gradebook.getInstructor('not_a_mail_address'))
         WHEN 0 THEN 'PASS'
         ELSE 'FAIL: Code 3'
      END
   );


   --test if getInstructorYears returns one row for instructor1
   RAISE INFO '%   getInstructorYears Count',
   (SELECT
      CASE (SELECT COUNT(*) FROM Gradebook.getInstructorYears(instructor1))
         WHEN 1 THEN 'PASS'
         ELSE 'FAIL: Code 4'
      END
   );


   --test if getInstructorYears returns 2017 for instructor1
   RAISE INFO '%   getInstructorYears Value',
   (SELECT
      CASE (SELECT Year FROM Gradebook.getInstructorYears(instructor1) LIMIT 1)
         WHEN 2017 THEN 'PASS'
         ELSE 'FAIL: Code 5'
      END
   );


   --test if getInstructorSeasons returns one row for instructor1
   RAISE INFO '%   getInstructorSeasons(instructor1) Count',
   (SELECT
      CASE (SELECT COUNT(*)
            FROM Gradebook.getInstructorSeasons(instructor1, 2017)
           )
         WHEN 1 THEN 'PASS'
         ELSE 'FAIL: Code 6'
      END
   );


   --test if getInstructorSeasons returns 'Spring' for instructor1
   RAISE INFO '%   getInstructorSeasons(instructor1) Value',
   (SELECT
      CASE (SELECT SeasonName
            FROM Gradebook.getInstructorSeasons(instructor1, 2017)
            LIMIT 1
           )
         WHEN 'Spring' THEN 'PASS'
         ELSE 'FAIL: Code 7'
      END
   );


   --test if getInstructorSeasons returns two rows for instructor2
   RAISE INFO '%   getInstructorSeasons(instructor2) Count',
   (SELECT
      CASE (SELECT COUNT(*)
            FROM Gradebook.getInstructorSeasons(instructor2, 2017)
           )
         WHEN 2 THEN 'PASS'
         ELSE 'FAIL: Code 8'
      END
   );


   --test if getInstructorCourses returns two rows for instructor1
   RAISE INFO '%   getInstructorCourses(instructor1) Count',
   (SELECT
      CASE (SELECT COUNT(*)
            FROM Gradebook.getInstructorCourses(instructor1, 2017, 0)
           )
         WHEN 2 THEN 'PASS'
         ELSE 'FAIL: Code 9'
      END
   );


   --test if getInstructorCourses returns one row for instructor2
   RAISE INFO '%   getInstructorCourses(instructor2) Count',
   (SELECT
      CASE (SELECT COUNT(*)
            FROM Gradebook.getInstructorCourses(instructor2, 2017, 1)
           )
         WHEN 1 THEN 'PASS'
         ELSE 'FAIL: Code 10'
      END
   );


   --test if getInstructorCourses returns 'Ab101' for instructor2
   RAISE INFO '%   getInstructorCourses(instructor2) Value',
   (SELECT
      CASE (SELECT Course
            FROM Gradebook.getInstructorCourses(instructor2, 2017, 1)
            LIMIT 1
           )
         WHEN 'AB101' THEN 'PASS'
         ELSE 'FAIL: Code 11'
      END
   );


   --test if getInstructorCourses returns no rows for instructor1 for 2017 Summer
   RAISE INFO '%   getInstructorCourses(instructor1) Count Negative',
   (SELECT
      CASE (SELECT COUNT(*)
            FROM Gradebook.getInstructorCourses(instructor1, 2017, 1)
           )
         WHEN 0 THEN 'PASS'
         ELSE 'FAIL: Code 12'
      END
   );


   --test if getInstructorSections returns two rows for instructor1
   RAISE INFO '%   getInstructorSections(instructor1) Count',
   (SELECT
      CASE (SELECT COUNT(*)
            FROM Gradebook.getInstructorSections(instructor1, 2017, 0)
           )
         WHEN 2 THEN 'PASS'
         ELSE 'FAIL: Code 13'
      END
   );


   --test if getInstructorSections returns '02' for instructor2 for 2017 Summer
   RAISE INFO '%   getInstructorSections(instructor2) Value',
   (SELECT
      CASE (SELECT SectionNumber
            FROM Gradebook.getInstructorSections(instructor2, 2017, 1, 'AB101')
            LIMIT 1
           )
         WHEN '02' THEN 'PASS'
         ELSE 'FAIL: Code 14'
      END
   );

END
$$;

--throw away test data
ROLLBACK TRANSACTION;
