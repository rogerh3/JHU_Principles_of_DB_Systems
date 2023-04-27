USE jhu_principlesofdb_finalproject;

-- Every Minor is distinguished by a MinorID and must have a MinorName
CREATE TABLE MINOR (
	MinorID CHAR(10) NOT NULL,
	MinorName VARCHAR(50) NOT NULL,
    CONSTRAINT MINOR_PK PRIMARY KEY (MinorID)
);

-- Every entry must have an account ID and a Tuition Amount.
-- Tuition paid and due will be updated as it goes, defaults as 0
CREATE TABLE TUITION (
	AccountID CHAR(12) NOT NULL,
    TuitionAmount INT NOT NULL DEFAULT '0',
    TuitionPaid INT NOT NULL DEFAULT '0',
    TuitionDue INT NOT NULL DEFAULT '0',
    CONSTRAINT TUITION_PK PRIMARY KEY (AccountID)
);

-- Every school of study has a school name
-- An address is not required as a school of study could be a 'global campus'
CREATE TABLE SCHOOL_OF_STUDY (
	SchoolName VARCHAR(50) NOT NULL,
    Address VARCHAR(100),
    CONSTRAINT SCHOOL_OF_STUDY_PK PRIMARY KEY (SchoolName)
);

-- Each entry must have a MajorID and a MajorName
-- School name is a FK
CREATE TABLE MAJOR (
	MajorID CHAR(10) NOT NULL,
    MajorName VARCHAR(25) NOT NULL,
    SchoolName VARCHAR(50),
    CONSTRAINT MAJOR_PK PRIMARY KEY (MajorID),
    CONSTRAINT MAJOR_FK
		FOREIGN KEY (SchoolName) REFERENCES SCHOOL_OF_STUDY (SchoolName)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Student is required to have email and phone contact information
-- SSSN left as the option to have a NULL if a student does not have a US SSN
-- MajorID, MinorID, and StudentID are FKs
CREATE TABLE STUDENT (
	StudentID CHAR(15) NOT NULL,
    MajorID CHAR(10),
    MinorID CHAR(10),
    AccountID CHAR(12),
    SFirstName VARCHAR(25) NOT NULL,
    SLastName VARCHAR(25) NOT NULL,
    SEmail VARCHAR(50) NOT NULL,
    SPhone CHAR(10) NOT NULL,
    SSSN CHAR(9),
    CONSTRAINT STUDENT_PK PRIMARY KEY (StudentID),
    CONSTRAINT STUDENT_FK
		FOREIGN KEY (MajorID) REFERENCES MAJOR (MajorID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT STUDENT_FK2
		FOREIGN KEY (MinorID) REFERENCES MINOR (MinorID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT STUDENT_FK3
		FOREIGN KEY (AccountID) REFERENCES TUITION (AccountID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- COURSES_OFFERED represents the courses that are being offered
CREATE TABLE COURSES_OFFERED (
	CourseID CHAR(10) NOT NULL,
    CourseName VARCHAR(50) NOT NULL,
    CourseSection VARCHAR(2) NOT NULL,
        StartDate DATE NOT NULL,
		EndDate DATE NOT NULL,
    CONSTRAINT COURSES_OFFERED_PK PRIMARY KEY (CourseID)
);

-- Professors are required to have SSN and all contact info
CREATE TABLE PROFESSOR (
	ProfessorID CHAR(10) NOT NULL,
    SchoolName VARCHAR(50) NOT NULL,
    ProfFirstName VARCHAR(25) NOT NULL,
    ProfLastName VARCHAR(25) NOT NULL,
    ProfEmail VARCHAR(50) NOT NULL,
    ProfPhone CHAR(10),
    ProfSSN CHAR(9) NOT NULL,
    CONSTRAINT PROFESSOR_PK PRIMARY KEY (ProfessorID),
    CONSTRAINT PROFESSOR_FK
		FOREIGN KEY (SchoolName) REFERENCES SCHOOL_OF_STUDY (SchoolName)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Each accountpayable will have a corresponding ProfessorID
-- It is possible to have a professor with no listed salary at times
CREATE TABLE SALARY (
	AccountPayable CHAR(12) NOT NULL,
    ProfessorID CHAR(10) NOT NULL,
    Salary INT, 
    CONSTRAINT SALARY_PK PRIMARY KEY (AccountPayable),
    CONSTRAINT SALARY_FK
		FOREIGN KEY (ProfessorID) REFERENCES PROFESSOR (ProfessorID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- StudentID and ProfessorID cannot be null, each student must have a professor who is their advisor
CREATE TABLE ADVISOR (
	AdvisorID CHAR(10) NOT NULL,
	StudentID CHAR(15) NOT NULL,
    ProfessorID CHAR(10) NOT NULL,
    CONSTRAINT ADVISOR_PK PRIMARY KEY (AdvisorID),
    CONSTRAINT ADVISOR_FK
		FOREIGN KEY (StudentID) REFERENCES STUDENT (StudentID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT ADVISOR_FK2
		FOREIGN KEY (ProfessorID) REFERENCES PROFESSOR (ProfessorID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- This table is a little awkward since it will have a unique enrollment id for each course a student and professor is in
CREATE TABLE COURSE_ENROLLMENT (
	EnrollmentID CHAR(12) NOT NULL,
    CourseID CHAR(10) NOT NULL,
    StudentID CHAR(15) NOT NULL,
    ProfessorID CHAR(10) NOT NULL,
    CONSTRAINT COURSE_ENROLLMENT_PK PRIMARY KEY (EnrollmentID),
    CONSTRAINT COURSE_ENROLLMENT_FK
		FOREIGN KEY (CourseID) REFERENCES COURSES_OFFERED (CourseID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT COURSE_ENROLLMENT_FK2
		FOREIGN KEY (StudentID) REFERENCES STUDENT (StudentID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT COURSE_ENROLLMENT_FK3
		FOREIGN KEY (ProfessorID) REFERENCES PROFESSOR (ProfessorID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- This table creates a relationship between courses and what location they are held in
CREATE TABLE BUILDING (
	BuildingName VARCHAR(25) NOT NULL,
    BuildingAddress VARCHAR(50) NOT NULL,
    CONSTRAINT BUILDING_PK PRIMARY KEY (BuildingName)
);

-- A RoomID will be the unique identifier for combinations of rooms in buildings
-- each room will have a room name and associated building as well as descriptive characteristics
CREATE TABLE ROOM (
	RoomID CHAR(8) NOT NULL,
    RoomNumber VARCHAR(5) NOT NULL,
    BuildingName VARCHAR(25) NOT NULL,
    CourseID CHAR(12) NOT NULL, 
    RoomSize VARCHAR(4) NOT NULL,
    NumberofSeats VARCHAR(4) NOT NULL,
    OpenSeats VARCHAR(4) NOT NULL,
    CONSTRAINT ROOM_PK PRIMARY KEY (RoomID),
    CONSTRAINT ROOM_FK
		FOREIGN KEY (BuildingName) REFERENCES BUILDING (BuildingName)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT ROOM_FK2
		FOREIGN KEY (CourseID) REFERENCES COURSES_OFFERED (CourseID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

#################################################
## Reviewing the Description of the database   ##
## In other words, getting the data dictionary ##
#################################################

DESCRIBE advisor;
DESCRIBE building;
DESCRIBE courses_offered;
DESCRIBE course_enrollment;
DESCRIBE major;
DESCRIBE minor;
DESCRIBE professor;
DESCRIBE room;
DESCRIBE salary;
DESCRIBE school_of_study;
DESCRIBE student;
DESCRIBE tuition;

#########################
## DMLs to INSERT Data ##
#########################

INSERT INTO MINOR (MINORID, MINORNAME) VALUES ('MATH000001', 'Statistics'); ##Need to drop Math
INSERT INTO MINOR (MINORID, MINORNAME) VALUES ('SCI0000001', 'Physical Sciences');
INSERT INTO MINOR (MINORID, MINORNAME) VALUES ('ENG0000001', 'Journalism');
INSERT INTO MINOR (MINORID, MINORNAME) VALUES ('MATH000001', 'Mathematics');

SELECT * FROM MINOR;

INSERT INTO SCHOOL_OF_STUDY (SCHOOLNAME, ADDRESS) VALUES ('Rogers School of Mathematics', '1065 Cherry Blossom Road');
INSERT INTO SCHOOL_OF_STUDY (SCHOOLNAME, ADDRESS) VALUES ('Warner School of English', '1027 Grape Lane');
INSERT INTO SCHOOL_OF_STUDY (SCHOOLNAME, ADDRESS) VALUES ('Paul Memorial Science Center', '1165 Regional Avenue');

SELECT * FROM SCHOOL_OF_STUDY;

INSERT INTO MAJOR (MAJORID, MAJORNAME, SCHOOLNAME) VALUES ('MATHDS0001', 'Data Science', 'Rogers School of Mathematics');
INSERT INTO MAJOR (MAJORID, MAJORNAME, SCHOOLNAME) VALUES ('MATHCS0001', 'Cyber Security', 'Rogers School of Mathematics');
INSERT INTO MAJOR (MAJORID, MAJORNAME, SCHOOLNAME) VALUES ('SCIBIO0001', 'Biology', 'Paul Memorial Science Center');
INSERT INTO MAJOR (MAJORID, MAJORNAME, SCHOOLNAME) VALUES ('SCIPHS0001', 'Physics', 'Paul Memorial Science Center');
INSERT INTO MAJOR (MAJORID, MAJORNAME, SCHOOLNAME) VALUES ('SCICHE0001', 'Chemistry', 'Paul Memorial Science Center');
INSERT INTO MAJOR (MAJORID, MAJORNAME, SCHOOLNAME) VALUES ('ENGENG0001', 'English', 'Warner School of English');

SELECT * FROM MAJOR;

INSERT INTO TUITION (ACCOUNTID, TUITIONAMOUNT, TUITIONPAID, TUITIONDUE) VALUES ('ACCT10000000', '10000', '400', '9600');
INSERT INTO TUITION (ACCOUNTID, TUITIONAMOUNT, TUITIONPAID, TUITIONDUE) VALUES ('ACCT20000000', '18000', '10000', '8000');
INSERT INTO TUITION (ACCOUNTID, TUITIONAMOUNT, TUITIONPAID, TUITIONDUE) VALUES ('ACCT30000000', '20000', '20000', '0');
INSERT INTO TUITION (ACCOUNTID, TUITIONAMOUNT, TUITIONPAID, TUITIONDUE) VALUES ('ACCT40000000', '23000', '20000', '3000');

SELECT * FROM TUITION;

INSERT INTO STUDENT (STUDENTID, MAJORID, MINORID, ACCOUNTID, SFIRSTNAME, SLASTNAME, SEMAIL, SPHONE, SSSN) VALUES ('S00000000000001', 'SCICHE0001', NULL, 'ACCT10000000', 'Fred', 'Red', 'Fred.Red@univ.com', '1112223456', '135485529');
INSERT INTO STUDENT (STUDENTID, MAJORID, MINORID, ACCOUNTID, SFIRSTNAME, SLASTNAME, SEMAIL, SPHONE, SSSN) VALUES ('S00000000000002', 'SCIBIO0001', 'MATH000001', 'ACCT20000000', 'George', 'Reggie', 'George.Reggie@univ.com', '1132453489', '111235294');
INSERT INTO STUDENT (STUDENTID, MAJORID, MINORID, ACCOUNTID, SFIRSTNAME, SLASTNAME, SEMAIL, SPHONE, SSSN) VALUES ('S00000000000003', 'ENGENG0001', 'MATH000001', 'ACCT30000000', 'Reese', 'Greg', 'Reese.Greg@univ.com', '3332658888', '150748468');
INSERT INTO STUDENT (STUDENTID, MAJORID, MINORID, ACCOUNTID, SFIRSTNAME, SLASTNAME, SEMAIL, SPHONE, SSSN) VALUES ('S00000000000004', 'MATHDS0001', 'SCI0000001', 'ACCT40000000', 'Buck', 'Henry', 'Buck.Henry@univ.com', '2409998888', '998659999');

SELECT * FROM STUDENT;

INSERT INTO PROFESSOR (PROFESSORID, SCHOOLNAME, PROFFIRSTNAME, PROFLASTNAME, PROFEMAIL, PROFPHONE, PROFSSN) VALUES ('PROF000001', 'Rogers School of Mathematics', 'Josh', 'Ray', 'Josh.Ray@univ.com', '7233355555', '195349999');
INSERT INTO PROFESSOR (PROFESSORID, SCHOOLNAME, PROFFIRSTNAME, PROFLASTNAME, PROFEMAIL, PROFPHONE, PROFSSN) VALUES ('PROF000002', 'Rogers School of Mathematics', 'Freddie', 'Crush', 'Freddie.Crush@univ.com', '5557895555', '195349999');
INSERT INTO PROFESSOR (PROFESSORID, SCHOOLNAME, PROFFIRSTNAME, PROFLASTNAME, PROFEMAIL, PROFPHONE, PROFSSN) VALUES ('PROF000003', 'Paul Memorial Science Center', 'Roy', 'Rubus', 'Roy.Rubus@univ.com', '7778578989', '111335555');
INSERT INTO PROFESSOR (PROFESSORID, SCHOOLNAME, PROFFIRSTNAME, PROFLASTNAME, PROFEMAIL, PROFPHONE, PROFSSN) VALUES ('PROF000004', 'Warner School of English', 'Paula', 'Fresh', 'Paula.Fresh@univ.com', '8569878965', '888889958');

SELECT * FROM PROFESSOR;

INSERT INTO SALARY (ACCOUNTPAYABLE, PROFESSORID, SALARY) VALUES ('ACCTPAY00001', 'PROF000001', '65000');
INSERT INTO SALARY (ACCOUNTPAYABLE, PROFESSORID, SALARY) VALUES ('ACCTPAY00002', 'PROF000002', '45000');
INSERT INTO SALARY (ACCOUNTPAYABLE, PROFESSORID, SALARY) VALUES ('ACCTPAY00003', 'PROF000003', '75000');
INSERT INTO SALARY (ACCOUNTPAYABLE, PROFESSORID, SALARY) VALUES ('ACCTPAY00004', 'PROF000004', '70000');

SELECT * FROM SALARY;

INSERT INTO ADVISOR (ADVISORID, STUDENTID, PROFESSORID) VALUES ('ADV0000001', 'S00000000000001', 'PROF000003');
INSERT INTO ADVISOR (ADVISORID, STUDENTID, PROFESSORID) VALUES ('ADV0000002', 'S00000000000002', 'PROF000003');
INSERT INTO ADVISOR (ADVISORID, STUDENTID, PROFESSORID) VALUES ('ADV0000003', 'S00000000000003', 'PROF000004');
INSERT INTO ADVISOR (ADVISORID, STUDENTID, PROFESSORID) VALUES ('ADV0000004', 'S00000000000004', 'PROF000001');

SELECT * FROM ADVISOR;

INSERT INTO COURSES_OFFERED (COURSEID, COURSENAME, COURSESECTION, STARTDATE, ENDDATE) VALUES ('MATHCRS001', 'Calculus 3', '01', '2023-01-21', '2023-05-07');
INSERT INTO COURSES_OFFERED (COURSEID, COURSENAME, COURSESECTION, STARTDATE, ENDDATE) VALUES ('SCICRS0001', 'Physics 2', '01', '2023-01-21', '2023-05-07');
INSERT INTO COURSES_OFFERED (COURSEID, COURSENAME, COURSESECTION, STARTDATE, ENDDATE) VALUES ('ENGCRS0001', 'Journalism', '01', '2023-01-21', '2023-05-07');

SELECT * FROM COURSES_OFFERED;

INSERT INTO COURSE_ENROLLMENT (ENROLLMENTID, COURSEID, STUDENTID, PROFESSORID) VALUES ('ENROLL000001', 'MATHCRS001',  'S00000000000001', 'PROF000001');
INSERT INTO COURSE_ENROLLMENT (ENROLLMENTID, COURSEID, STUDENTID, PROFESSORID) VALUES ('ENROLL000002', 'MATHCRS001',  'S00000000000002', 'PROF000001');
INSERT INTO COURSE_ENROLLMENT (ENROLLMENTID, COURSEID, STUDENTID, PROFESSORID) VALUES ('ENROLL000003', 'MATHCRS001',  'S00000000000003', 'PROF000001');
INSERT INTO COURSE_ENROLLMENT (ENROLLMENTID, COURSEID, STUDENTID, PROFESSORID) VALUES ('ENROLL000004', 'SCICRS0001',  'S00000000000004', 'PROF000003');
INSERT INTO COURSE_ENROLLMENT (ENROLLMENTID, COURSEID, STUDENTID, PROFESSORID) VALUES ('ENROLL000005', 'SCICRS0001',  'S00000000000001', 'PROF000003');
INSERT INTO COURSE_ENROLLMENT (ENROLLMENTID, COURSEID, STUDENTID, PROFESSORID) VALUES ('ENROLL000006', 'ENGCRS0001',  'S00000000000003', 'PROF000004');

SELECT * FROM COURSE_ENROLLMENT;

INSERT INTO BUILDING (BUILDINGNAME, BUILDINGADDRESS) VALUES ('Whitworth Math Center', '1065 Cherry Blossom Road');
INSERT INTO BUILDING (BUILDINGNAME, BUILDINGADDRESS) VALUES ('Ray’s Science Center',  '1165 Regional Avenue');
INSERT INTO BUILDING (BUILDINGNAME, BUILDINGADDRESS) VALUES ('Paula’s English Center',  '1027 Grape Lane');

SELECT * FROM BUILDING;

INSERT INTO ROOM (ROOMID, ROOMNUMBER, BUILDINGNAME, COURSEID, ROOMSIZE, NUMBEROFSEATS, OPENSEATS) VALUES ('WHIT1230', '01230', 'Whitworth Math Center', 'MATHCRS001' , '3500', '100', '97');
INSERT INTO ROOM (ROOMID, ROOMNUMBER, BUILDINGNAME, COURSEID, ROOMSIZE, NUMBEROFSEATS, OPENSEATS) VALUES ('RAYS2354', '02354', 'Ray’s Science Center', 'SCICRS0001' , '3000', '80', '78');
INSERT INTO ROOM (ROOMID, ROOMNUMBER, BUILDINGNAME, COURSEID, ROOMSIZE, NUMBEROFSEATS, OPENSEATS) VALUES ('PALA1354', '01354', 'Paula’s English Center', 'ENGCRS0001' , '2000', '50', '49');

SELECT * FROM ROOM;

####################
## Query Examples ##
####################

-- Searching for all Student Names and their Tuition
SELECT S.StudentID, S.SFirstName, S.SLastName, S.SSSN, S.AccountID, T.TuitionAmount, T.TuitionPaid, T.TuitionDue
FROM STUDENT S
JOIN TUITION T ON T.AccountID = S.AccountID;

-- Searching for all Professors and their Salaries
SELECT P.ProfessorID, P.ProfFirstName, P.ProfLastName, P.ProfSSN, S.AccountPayable, S.Salary
FROM PROFESSOR P
JOIN SALARY S ON S.ProfessorID = P.ProfessorID;

-- Searching for all Advisor combinations (with names)
SELECT A.AdvisorID, S.StudentID, S.SFirstName, S.SLastName, S.SEmail, P.ProfessorID, P.ProfFirstName,
	P.ProfLastName, P.ProfEmail
FROM ADVISOR A
JOIN STUDENT S ON S.StudentID = A.StudentID
JOIN PROFESSOR P ON P.ProfessorID = A.ProfessorID;

-- Finding the student names that are enrolled in each course (Course ID and Course Name)
SELECT C.EnrollmentID, C.CourseID, CO.CourseName, C.StudentID, S.SFirstName, S.SLastName
FROM COURSE_ENROLLMENT C
JOIN STUDENT S ON S.StudentID = C.StudentID
JOIN COURSES_OFFERED CO ON CO.CourseID = C.CourseID;

-- Finding how many students are enrolled in each course
SELECT CourseID, COUNT(StudentID) AS Class_Size
FROM COURSE_ENROLLMENT
GROUP BY CourseID;

-- Finding the RoomNumber, BuildingName, and Building Address for each course
SELECT R.CourseID, R.RoomID, R.RoomNumber, R.BuildingName, B.BuildingAddress
FROM ROOM R
JOIN BUILDING B ON B.Buildingname = R.BuildingName;

-- Finding the number of courses each professor is teaching
-- Can be done other ways, but I chose to do it this way to practice querying in different ways
SELECT P.ProfessorID, P.ProfFirstName, ProfLastName, COUNT(DISTINCT(CO.CourseID)) AS Courses_Teaching
FROM PROFESSOR P
JOIN COURSE_ENROLLMENT CE ON CE.ProfessorID = P.ProfessorID
JOIN COURSES_OFFERED CO ON CO.CourseID = CE.CourseID
GROUP BY P.ProfessorID, CO.CourseID;

-- Professor Bi-weekly paycheck amount
SELECT P.ProfessorID, P.ProfFirstName, P.ProfLastName, (S.Salary/26) AS Paycheck
FROM PROFESSOR P
JOIN SALARY S ON S.ProfessorID = P.ProfessorID;


################################
## Running Stored Procedures ##
################################
-- Stored Procedure for Course Offerings and Enrollment Summary
CALL course_openings();

/*
CREATE DEFINER=`root`@`localhost` PROCEDURE `course_openings`()
BEGIN
-- Finding all courses and how many seats are open
SELECT C.CourseID, C.CourseName, C.CourseSection, R.OpenSeats, 
	(R.NumberOfSeats - R.OpenSeats) AS Students_Enrolled
FROM COURSES_OFFERED C
JOIN ROOM R ON R.CourseID = C.CourseID;
END
*/

-- Non-cleared student information
CALL nonsensitive_student();

/*
CREATE DEFINER=`root`@`localhost` PROCEDURE `nonsensitive_student`()
BEGIN
SELECT StudentID, MajorID, MinorID, AccountID, 
	SFirstName, SLastName, SEmail, SPhone
FROM STUDENT;
END
*/

-- Count of Students enrolled in each major 
CALL major_breakout();

/*
CREATE DEFINER=`root`@`localhost` PROCEDURE `major_breakout`()
BEGIN
-- Count of Students enrolled in each major 
SELECT M.SchoolName, M.MajorID, M.MajorName, 
	COUNT(S.StudentID) AS StudentCount
FROM MAJOR M
JOIN STUDENT S ON S.MajorID = M.MajorID
GROUP BY M.SchoolName, M.MajorID, M.MajorName
ORDER BY M.SchoolName;
END
*/

#######################
## Running Functions ##
#######################
SHOW FUNCTION STATUS 
WHERE db = 'jhu_principlesofdb_finalproject';

SELECT AccountID, TuitionDue, is_tuition_owed(TuitionDue)
FROM TUITION;

/*
CREATE DEFINER=`root`@`localhost` FUNCTION `is_tuition_owed`(
	TuitionDue INT
) RETURNS varchar(20) CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE TuitionOwed VARCHAR(20);

IF TuitionDue > 1 THEN
	SET TuitionOwed = "Yes";
ELSE 
	SET TuitionOwed = "No";
END IF;
RETURN (TuitionOwed);
END
*/

SELECT ProfessorID, Salary, salary_level(Salary)
FROM SALARY;

/*
CREATE DEFINER=`root`@`localhost` FUNCTION `salary_level`(
Salary INT
) RETURNS varchar(20) CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE salary_level VARCHAR(20);

IF Salary > 60000 THEN
	SET salary_level = "High";
ELSE
	SET  salary_level = "Low";
END IF;
RETURN (salary_level);
END
*/

SELECT CourseID, CourseName, StartDate, registration_passed(StartDate)
FROM COURSES_OFFERED;

/*
CREATE DEFINER=`root`@`localhost` FUNCTION `registration_passed`(
StartDate DATE
) RETURNS varchar(20) CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE registration_passed VARCHAR(20);

IF StartDate > CURDATE() THEN
	SET registration_passed = "OPEN";
ELSE
	SET  registration_passed = "CLOSED";
END IF;
RETURN (registration_passed);
END
*/

#######################
## Creating Triggers ##
#######################
DROP TRIGGER IF EXISTS tr_tuition;

-- Trigger to make the "acct" portion in AccountID Uppercase
CREATE TRIGGER tr_tuition
BEFORE INSERT ON TUITION
FOR EACH ROW
SET NEW.AccountID = UPPER(NEW.AccountID);

INSERT INTO TUITION (ACCOUNTID, TUITIONAMOUNT, TUITIONPAID, TUITIONDUE) 
	VALUES ('acct50000000', '0', '0', '0');

SELECT * FROM TUITION;
--
DROP TRIGGER IF EXISTS tr_school_address;

-- Trigger to make the addresses in School_of_study Lowercase
CREATE TRIGGER tr_school_address
BEFORE INSERT ON SCHOOL_OF_STUDY
FOR EACH ROW
SET NEW.Address = LOWER(NEW.Address);

INSERT INTO SCHOOL_OF_STUDY (SCHOOLNAME, ADDRESS) VALUES 
	('Joes Cooking School', '1065 FRANKLIN LANE');
    
SELECT * FROM SCHOOL_OF_STUDY;
--
DROP TRIGGER IF EXISTS tr_tuition_due;

-- Trigger to calculate Tuition Due
CREATE TRIGGER tr_tuition_due
BEFORE INSERT ON TUITION
FOR EACH ROW
SET NEW.TuitionDue = (NEW.TuitionAmount - NEW.TuitionPaid);

INSERT INTO TUITION (ACCOUNTID, TuitionAmount, TUITIONPAID, TUITIONDUE) 
	VALUES ('ACCT60000000', '15000', '9875', '0');
    
SELECT * FROM TUITION;