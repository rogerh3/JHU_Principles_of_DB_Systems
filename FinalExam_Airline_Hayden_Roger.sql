USE jhu_principlesofdb_finalexam;

CREATE TABLE AIRPORT (
	Airport_code VARCHAR(4) NOT NULL,
	Airport_name VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State CHAR(25) NOT NULL,
    CONSTRAINT AIRPORT_PK PRIMARY KEY (Airport_code)
);

-- Check constraint for max seats between 0 and 600
CREATE TABLE AIRPLANE_TYPE (
	Airplane_type_name VARCHAR(50) NOT NULL,
    Max_seats INT NOT NULL,
    Company VARCHAR(50) NOT NULL,
    CONSTRAINT AIRPLANE_TYPE_PK PRIMARY KEY (Airplane_type_name),
    CONSTRAINT CHK_AIRPLANE_TYPE CHECK (Max_seats >=0 AND Max_seats <= 600)
);

CREATE TABLE CAN_LAND (
	Airplane_type_name VARCHAR(50) NOT NULL,
    Airport_code VARCHAR(4) NOT NULL,
    CONSTRAINT CAN_LAND_PK PRIMARY KEY (Airplane_type_name, Airport_code),
    CONSTRAINT CAN_LAND_FK FOREIGN KEY (Airplane_type_name) REFERENCES 
		AIRPLANE_TYPE (Airplane_type_name) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT CAN_LAND_FK2 FOREIGN KEY (Airport_code) REFERENCES AIRPORT (Airport_code)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Flight_number will be required to be unique here since it is the Primary Key
CREATE TABLE FLIGHT (
	Flight_number VARCHAR(6) NOT NULL,
    Airline VARCHAR(50) NOT NULL,
    Weekdays VARCHAR(10) NOT NULL,
    CONSTRAINT FLIGHT_PK PRIMARY KEY (Flight_number)
);

-- Check constraint for Leg number to be between 0 and 4
CREATE TABLE FLIGHT_LEG (
	Flight_number VARCHAR(6) NOT NULL,
    Leg_number INT NOT NULL,
    Departure_airport_code VARCHAR(4) NOT NULL,
    Scheduled_departure_time VARCHAR(8),
    Arrival_airport_code VARCHAR(4) NOT NULL,
    Scheduled_arrival_time VARCHAR(8),
    CONSTRAINT FLIGHT_LEG_PK PRIMARY KEY (Flight_number, Leg_number),
    CONSTRAINT FLIGHT_LEG_FK FOREIGN KEY (Flight_number) REFERENCES FLIGHT (Flight_number)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FLIGHT_LEG_FK2 FOREIGN KEY (Departure_airport_code)
		REFERENCES AIRPORT (Airport_code)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FLIGHT_LEG_FK3 FOREIGN KEY (Arrival_airport_code)
		REFERENCES AIRPORT (Airport_code)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT CHK_FLIGHT_LEG CHECK (Leg_number >= 1 AND Leg_number <= 4)
); 

CREATE TABLE AIRPLANE (
	Airplane_id VARCHAR(6) NOT NULL,
    Total_number_of_seats VARCHAR(4) NOT NULL,
    Airplane_type VARCHAR(25) NOT NULL,
    CONSTRAINT AIRPLANE_PK PRIMARY KEY (Airplane_id),
    CONSTRAINT AIRPLANE_FK FOREIGN KEY (Airplane_type) REFERENCES AIRPLANE_TYPE (Airplane_type_name)
		ON DELETE CASCADE ON UPDATE CASCADE
);

## NEED TO ADD TRIGGER TO CHECK LEG NUMBER HERE ##
## NEED TO ADD TRIGGER TO CHECK LEG DATE HERE ##
CREATE TABLE LEG_INSTANCE (
	Flight_number VARCHAR(6) NOT NULL,
    Leg_number INT NOT NULL,
    Leg_date DATE NOT NULL,
    Number_of_available_seats INT NOT NULL,
    Airplane_id VARCHAR(6) NOT NULL,
    Departure_airport_code VARCHAR(4) NOT NULL,
    Departure_time VARCHAR(8),
    Arrival_airport_code VARCHAR(4) NOT NULL,
    Scheduled_arrival_time VARCHAR(8),
    CONSTRAINT LEG_INSTANCE_PK PRIMARY KEY (Flight_number, Leg_number, Leg_date),
    CONSTRAINT LEG_INSTANCE_FK FOREIGN KEY (Flight_number, Leg_number) 
		REFERENCES FLIGHT_LEG (Flight_number, Leg_number)
		ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT LEG_INSTANCE_FK2 FOREIGN KEY (Airplane_id) REFERENCES AIRPLANE (Airplane_id)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- Added a CHECK CONSTRAINT for Fare Amount to be between 0 and 10000
CREATE TABLE FARE (
	Flight_number VARCHAR(6) NOT NULL,
    Fare_code CHAR(5) NOT NULL,
    Amount INT NOT NULL,
    Restrictions VARCHAR(25) NOT NULL,
    CONSTRAINT FARE_PK PRIMARY KEY (Flight_number, Fare_code),
    CONSTRAINT FARE_RK FOREIGN KEY (Flight_number) REFERENCES FLIGHT (Flight_number)
		ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT CHK_FARE CHECK (Amount >= 0 AND Amount <= 10000)
);

## NEED TO ADD TRIGGER TO CHECK LEG DATE HERE ##
## NEED TO ADD TRIGGER TO CHECK LEG NUMBER HERE ##
CREATE TABLE SEAT_RESERVATION (
	Flight_number VARCHAR(6) NOT NULL,
    Leg_number INT NOT NULL,
    Leg_date DATE NOT NULL,
    Seat_number VARCHAR(4) NOT NULL,
    Customer_name VARCHAR(50),
    Customer_phone CHAR(12),
    CONSTRAINT SEAT_RESERVATION_PK PRIMARY KEY(Flight_number, Leg_number, Leg_date, Seat_number),
    CONSTRAINT SEAT_RESERVATION_FK FOREIGN KEY (Flight_number, Leg_number, Leg_date) 
		REFERENCES LEG_INSTANCE (Flight_number, Leg_number, Leg_date)
		ON DELETE CASCADE ON UPDATE CASCADE
);
##############################
## TRIGGERS FOR SOME CHECKS ##
##############################

DROP TRIGGER IF EXISTS tr_Leg_instance_legno;

-- Trigger to check that Leg_number in LEG_INSTANCE is in the range 0-4
DELIMITER $$

CREATE TRIGGER tr_Leg_instance_legno
BEFORE INSERT ON LEG_INSTANCE
FOR EACH ROW
BEGIN
IF (NEW.Leg_number > 4 OR NEW.Leg_number < 1) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Enter an acceptable Leg_Number: 0-4';
END IF;
END$$

DELIMITER ;

DROP TRIGGER IF EXISTS tr_Seat_reservation_legno;

-- Trigger to check that Leg_number in LEG_INSTANCE is in the range 0-4
DELIMITER $$

CREATE TRIGGER tr_Seat_reservation_legno
BEFORE INSERT ON SEAT_RESERVATION
FOR EACH ROW
BEGIN
IF (NEW.Leg_number > 4 OR NEW.Leg_number < 1) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Enter an acceptable Leg_Number: 0-4';
END IF;
END; $$


DROP TRIGGER IF EXISTS tr_Leg_instance_legdate;

-- Trigger to check that Leg_date is equal to or after the current date
DELIMITER $$

CREATE TRIGGER tr_Leg_instance_legdate
BEFORE INSERT ON LEG_INSTANCE
FOR EACH ROW
IF (NEW.Leg_date < CURDATE()) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Enter an acceptable Leg_date: Equal to, or after the current date';
END IF;
END; $$


DROP TRIGGER IF EXISTS tr_Seat_reservation_legdate;

-- Trigger to check that Leg_date is equal to or after the current date
DELIMITER $$

CREATE TRIGGER tr_Seat_reservation_legdate
BEFORE INSERT ON LEG_INSTANCE
FOR EACH ROW
BEGIN
IF (NEW.Leg_date < CURDATE()) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Enter an acceptable Leg_date: Equal to, or after the current date';
END IF;
END; $$

SHOW TRIGGERS;

###############################
## DMLs to Enter Sample Data ##
###############################

-- AIRPORT Insert Statements
INSERT INTO AIRPORT(Airport_code, Airport_name, City, State) VALUES 
('IAD','Dulles International Airport','Dulles', 'Virginia'); 
INSERT INTO AIRPORT(Airport_code, Airport_name, City, State) VALUES 
('BWI','Baltimore/Washington International Thurdgood Marshall Airport','Baltimore', 'Maryland'); 
INSERT INTO AIRPORT(Airport_code, Airport_name, City, State) VALUES 
('SFO','San Francisco International Airport','San Francisco', 'California'); 
INSERT INTO AIRPORT(Airport_code, Airport_name, City, State) VALUES 
('LAX','Los Angeles International Airport','Los Angeles', 'California'); 
INSERT INTO AIRPORT(Airport_code, Airport_name, City, State) VALUES 
('JFK','John F. Kennedy International Airport','Queens', 'New York'); 

SELECT * FROM AIRPORT;

-- AIRPLANE_TYPE Insert Statements
INSERT INTO AIRPLANE_TYPE(Airplane_type_name, Max_seats, Company) VALUES
('Boeing 737', '470', 'United');
INSERT INTO AIRPLANE_TYPE(Airplane_type_name, Max_seats, Company) VALUES
('Boeing 787', '600', 'United');
INSERT INTO AIRPLANE_TYPE(Airplane_type_name, Max_seats, Company) VALUES
('Airbus A330', '490', 'American Airlines');
INSERT INTO AIRPLANE_TYPE(Airplane_type_name, Max_seats, Company) VALUES
('Airbus A320', '350', 'American Airlines');
INSERT INTO AIRPLANE_TYPE(Airplane_type_name, Max_seats, Company) VALUES
('Boeing 767', '500', 'Spirit');

SELECT * FROM AIRPLANE_TYPE;

-- FLIGHT Insert Statements
INSERT INTO FLIGHT(Flight_number, Airline, Weekdays) VALUES
('UA1147', 'United', 'MWF');
INSERT INTO FLIGHT(Flight_number, Airline, Weekdays) VALUES
('UA1558', 'United', 'MWF');
INSERT INTO FLIGHT(Flight_number, Airline, Weekdays) VALUES
('AA2786', 'American Airlines', 'TR');
INSERT INTO FLIGHT(Flight_number, Airline, Weekdays) VALUES
('AA4000', 'American Airlines', 'F');
INSERT INTO FLIGHT(Flight_number, Airline, Weekdays) VALUES
('SP3222', 'Spirit', 'MWF');

SELECT * FROM FLIGHT;

-- FLIGHT_LEG Insert Statements
INSERT INTO FLIGHT_LEG(Flight_number, Leg_number, Departure_airport_code, 
Scheduled_departure_time, Arrival_airport_code, Scheduled_arrival_time) VALUES
('UA1147', '1', 'BWI', '10:00am', 'SFO', '5:00pm');
INSERT INTO FLIGHT_LEG(Flight_number, Leg_number, Departure_airport_code, 
Scheduled_departure_time, Arrival_airport_code, Scheduled_arrival_time) VALUES
('UA1558', '1', 'SFO', '10:00am', 'BWI', '8:00pm');
INSERT INTO FLIGHT_LEG(Flight_number, Leg_number, Departure_airport_code, 
Scheduled_departure_time, Arrival_airport_code, Scheduled_arrival_time) VALUES
('AA2786', '1', 'SFO', '10:00am', 'BWI', '8:00pm');
INSERT INTO FLIGHT_LEG(Flight_number, Leg_number, Departure_airport_code, 
Scheduled_departure_time, Arrival_airport_code, Scheduled_arrival_time) VALUES
('AA4000', '1', 'BWI', '10:00am', 'SFO', '5:00pm');
INSERT INTO FLIGHT_LEG(Flight_number, Leg_number, Departure_airport_code, 
Scheduled_departure_time, Arrival_airport_code, Scheduled_arrival_time) VALUES
('SP3222', '1', 'BWI', '10:00am', 'SFO', '6:00pm');

SELECT * FROM FLIGHT_LEG;

-- AIRPLANE Insert Statements
INSERT INTO AIRPLANE(Airplane_id, Total_number_of_seats, Airplane_type) VALUES
('U12586', '450', 'Boeing 737');
INSERT INTO AIRPLANE(Airplane_id, Total_number_of_seats, Airplane_type) VALUES
('U13689', '580', 'Boeing 787');
INSERT INTO AIRPLANE(Airplane_id, Total_number_of_seats, Airplane_type) VALUES
('A15684', '470', 'Airbus A330');
INSERT INTO AIRPLANE(Airplane_id, Total_number_of_seats, Airplane_type) VALUES
('A11845', '330', 'Airbus A320');
INSERT INTO AIRPLANE(Airplane_id, Total_number_of_seats, Airplane_type) VALUES
('S11111', '470', 'Boeing 767');

SELECT * FROM AIRPLANE;

-- LEG_INSTANCE Insert Statements
INSERT INTO LEG_INSTANCE(Flight_number, Leg_number, Leg_date, Number_of_available_seats, Airplane_id,
Departure_airport_code, Departure_time, Arrival_airport_code, Scheduled_arrival_time) VALUES
('UA1147', '1', '2023-05-15', '10', 'U12586', 'BWI', '10:00am', 'SFO', '5:00pm');
INSERT INTO LEG_INSTANCE(Flight_number, Leg_number, Leg_date, Number_of_available_seats, Airplane_id,
Departure_airport_code, Departure_time, Arrival_airport_code, Scheduled_arrival_time) VALUES
('UA1558', '1', '2023-05-22', '5', 'U13689', 'SFO', '10:00am', 'BWI', '8:00pm');
INSERT INTO LEG_INSTANCE(Flight_number, Leg_number, Leg_date, Number_of_available_seats, Airplane_id,
Departure_airport_code, Departure_time, Arrival_airport_code, Scheduled_arrival_time) VALUES
('AA2786', '1', '2023-05-22', '3', 'A15684', 'SFO', '10:00am', 'BWI', '8:00pm');
INSERT INTO LEG_INSTANCE(Flight_number, Leg_number, Leg_date, Number_of_available_seats, Airplane_id,
Departure_airport_code, Departure_time, Arrival_airport_code, Scheduled_arrival_time) VALUES
('AA4000', '1', '2023-05-15', '4', 'A11845', 'BWI', '10:00am', 'SFO', '5:00pm');
INSERT INTO LEG_INSTANCE(Flight_number, Leg_number, Leg_date, Number_of_available_seats, Airplane_id,
Departure_airport_code, Departure_time, Arrival_airport_code, Scheduled_arrival_time) VALUES
('SP3222', '1', '2023-05-15', '12', 'S11111', 'BWI', '10:00am', 'SFO', '6:00pm');

SELECT * FROM LEG_INSTANCE;

-- FARE Insert Statements
INSERT INTO FARE(Flight_number, Fare_code, Amount, Restrictions) VALUES
('UA1147', 'UF123', '400', 'Economy Only');
INSERT INTO FARE(Flight_number, Fare_code, Amount, Restrictions) VALUES
('UA1558', 'UF256', '200', 'No Handicap Access');
INSERT INTO FARE(Flight_number, Fare_code, Amount, Restrictions) VALUES
('AA2786', 'AF286', '700', 'Business class level 1');
INSERT INTO FARE(Flight_number, Fare_code, Amount, Restrictions) VALUES
('AA4000', 'AF300', '100', 'Last Minute Window Seat');
INSERT INTO FARE(Flight_number, Fare_code, Amount, Restrictions) VALUES
('SP3222', 'SF500', '150', 'No Services');

SELECT * FROM FARE;

-- CAN_LAND Insert Statements
INSERT INTO CAN_LAND(Airplane_type_name, Airport_code) VALUES
('Boeing 737', 'SFO');
INSERT INTO CAN_LAND(Airplane_type_name, Airport_code) VALUES
('Boeing 787', 'BWI');
INSERT INTO CAN_LAND(Airplane_type_name, Airport_code) VALUES
('Airbus A330', 'BWI');
INSERT INTO CAN_LAND(Airplane_type_name, Airport_code) VALUES
('Airbus A320', 'SFO');
INSERT INTO CAN_LAND(Airplane_type_name, Airport_code) VALUES
('Boeing 767', 'SFO');

SELECT * FROM CAN_LAND;

-- SEAT_RESERVATION Insert Statements
INSERT INTO SEAT_RESERVATION(Flight_number, Leg_number, Leg_date, 
Seat_number, Customer_name, Customer_phone) VALUES
('UA1147', '1', '2023-05-15', '25', 'Roy Rogers', '777-777-7777');
INSERT INTO SEAT_RESERVATION(Flight_number, Leg_number, Leg_date, 
Seat_number, Customer_name, Customer_phone) VALUES
('UA1558', '1', '2023-05-22', '37', 'Richie Johnson', '123-456-7891');
INSERT INTO SEAT_RESERVATION(Flight_number, Leg_number, Leg_date, 
Seat_number, Customer_name, Customer_phone) VALUES
('AA2786', '1', '2023-05-22', '48', 'Elton John', '111-222-3333');
INSERT INTO SEAT_RESERVATION(Flight_number, Leg_number, Leg_date, 
Seat_number, Customer_name, Customer_phone) VALUES
('AA4000', '1', '2023-05-15', '78', 'Lebron James', '888-888-7895');
INSERT INTO SEAT_RESERVATION(Flight_number, Leg_number, Leg_date, 
Seat_number, Customer_name, Customer_phone) VALUES
('SP3222', '1', '2023-05-15', '1', 'Taylor Swift', '187-849-9856');

SELECT * FROM SEAT_RESERVATION;

#####################
## Queries on Data ##
#####################

-- All direct flights from BWI to SFO on 05/15/2023 with more that 2 open seats
SELECT FL.Flight_number, FL.Departure_airport_code, LI.Departure_time, FL.Arrival_airport_code,
	LI.Scheduled_arrival_time, LI.Number_of_available_seats
FROM FLIGHT_LEG FL
JOIN LEG_INSTANCE LI ON LI.Flight_number = FL.Flight_number
WHERE FL.Departure_airport_code = 'BWI' 
AND FL.Arrival_airport_code = 'SFO'
AND FL.Leg_number = '1'
AND LI.Leg_date = '2023-05-15'
AND Number_of_available_seats > '2';

-- All direct flights from SFO to BWI on 05/22/2023
SELECT FL.Flight_number, FL.Departure_airport_code, LI.Departure_time, FL.Arrival_airport_code,
	LI.Scheduled_arrival_time, LI.Number_of_available_seats
FROM FLIGHT_LEG FL
JOIN LEG_INSTANCE LI ON LI.Flight_number = FL.Flight_number
WHERE FL.Departure_airport_code = 'SFO' 
AND FL.Arrival_airport_code = 'BWI'
AND FL.Leg_number = '1'
AND LI.Leg_date = '2023-05-22';


