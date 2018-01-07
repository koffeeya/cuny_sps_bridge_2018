-- loadflights.sql

DROP TABLE IF EXISTS airlines;
DROP TABLE IF EXISTS airports;
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS planes;
DROP TABLE IF EXISTS weather;

CREATE TABLE airlines (
  carrier varchar(2) PRIMARY KEY,
  name varchar(30) NOT NULL
  );
  
LOAD DATA LOCAL INFILE 'C:/Users/Kavya/Desktop/Education/MS Data Science/Bridge Workshop - SQL/flights/airlines.csv' 
INTO TABLE airlines 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE airports (
  faa char(3),
  name varchar(100),
  lat double precision,
  lon double precision,
  alt integer,
  tz integer,
  dst char(1)
  );
  
LOAD DATA LOCAL INFILE 'C:/Users/Kavya/Desktop/Education/MS Data Science/Bridge Workshop - SQL/flights/airports.csv' 
INTO TABLE airports
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE flights (
year integer,
month integer,
day integer,
dep_time integer,
dep_delay integer,
arr_time integer,
arr_delay integer,
carrier char(2),
tailnum char(6),
flight integer,
origin char(3),
dest char(3),
air_time integer,
distance integer,
hour integer,
minute integer
);

LOAD DATA LOCAL INFILE 'C:/Users/Kavya/Desktop/Education/MS Data Science/Bridge Workshop - SQL/flights/flights.csv' 
INTO TABLE flights
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(year, month, day, @dep_time, @dep_delay, @arr_time, @arr_delay,
 @carrier, @tailnum, @flight, origin, dest, @air_time, @distance, @hour, @minute)
SET
dep_time = nullif(@dep_time,''),
dep_delay = nullif(@dep_delay,''),
arr_time = nullif(@arr_time,''),
arr_delay = nullif(@arr_delay,''),
carrier = nullif(@carrier,''),
tailnum = nullif(@tailnum,''),
flight = nullif(@flight,''),
air_time = nullif(@air_time,''),
distance = nullif(@distance,''),
hour = dep_time / 100,
minute = dep_time % 100
;

CREATE TABLE planes (
tailnum char(6),
year integer,
type varchar(50),
manufacturer varchar(50),
model varchar(50),
engines integer,
seats integer,
speed integer,
engine varchar(50)
);

LOAD DATA LOCAL INFILE 'C:/Users/Kavya/Desktop/Education/MS Data Science/Bridge Workshop - SQL/flights/planes.csv' 
INTO TABLE planes
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(tailnum, @year, type, manufacturer, model, engines, seats, @speed, engine)
SET
year = nullif(@year,''),
speed = nullif(@speed,'')
;

CREATE TABLE weather (
origin char(3),
year integer,
month integer,
day integer,
hour integer,
temp double precision,
dewp double precision,
humid double precision,
wind_dir integer,
wind_speed double precision,
wind_gust double precision,
precip double precision,
pressure double precision,
visib double precision
);

LOAD DATA LOCAL INFILE 'C:/Users/Kavya/Desktop/Education/MS Data Science/Bridge Workshop - SQL/flights/weather.csv' 
INTO TABLE weather
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(origin, @year, @month, @day, @hour, @temp, @dewp, @humid, @wind_dir,
@wind_speed, @wind_gust, @precip, @pressure, @visib)
SET
year = nullif(@year,''),
month = nullif(@month,''),
day = nullif(@day,''),
hour = nullif(@hour,''),
temp = nullif(@temp,''),
dewp = nullif(@dewp,''),
humid = nullif(@humid,''),
wind_dir = FORMAT(@wind_dir, 0),
wind_speed = nullif(@wind_speed,''),
wind_gust = nullif(@wind_gust,''),
precip = nullif(@precip,''),
pressure = nullif(@pressure,''),
visib = FORMAT(@visib,0)
;

SET SQL_SAFE_UPDATES = 0;
UPDATE planes SET engine = SUBSTRING(engine, 1, CHAR_LENGTH(engine)-1);

SELECT 'airlines', COUNT(*) FROM airlines
  UNION
SELECT 'airports', COUNT(*) FROM airports
  UNION
SELECT 'flights', COUNT(*) FROM flights
  UNION
SELECT 'planes', COUNT(*) FROM planes
  UNION
SELECT 'weather', COUNT(*) FROM weather;


-- HANDS ON LAB: SQL SELECTS

-- #1
SELECT * FROM planes;

-- #2
SELECT CONCAT(month, "/", day, "/", year) FROM weather;

-- #3
SELECT * FROM planes GROUP BY seats DESC;

-- #4
SELECT * FROM planes WHERE engine = "Reciprocating";

-- #5
SELECT * FROM flights LIMIT 5;

-- #5
SELECT MAX(air_time) FROM flights WHERE air_time != 0;

-- #5
SELECT MIN(air_time) FROM flights WHERE air_time != 0;

-- #8
SELECT * FROM flights WHERE CONCAT (year, month, day) BETWEEN 201361 AND 201363 AND carrier = "AA";

-- #9
SELECT * FROM airlines WHERE name LIKE "%America%";

-- #10
SELECT COUNT(*) FROM flights WHERE dest = "MIA"; -- 11728 flights to Miami

-- #11
SELECT COUNT(*) FROM flights WHERE CONCAT (year, month, day) BETWEEN 201311 AND 2013131 AND dest = "MIA"; -- 4146 flights to Miami in Jan. 2013
SELECT COUNT(*) FROM flights WHERE CONCAT (year, month, day) BETWEEN 201371 AND 2013731 AND dest = "MIA"; -- 6503 flights to Miami in Jul. 2013
-- There were more flights to Miami in July 2013 than January 2013.

-- #12
SELECT avg(alt) FROM airports; -- 1005.9170 average altitude



-- HANDS ON LAB: SQL AGGREGATIONS

-- #1
SELECT AVG(alt) FROM airports WHERE name = "Newark Liberty Intl" OR name = "La Guardia" OR name = "John F Kennedy Intl";
-- 17.667 average altitude

-- #2
SELECT tz, AVG(alt) FROM airports GROUP BY tz ORDER BY AVG(alt) DESC;
-- Timezone -7 has the highest average altitude at 3,848 ft.

-- #3
SELECT tailnum, COUNT(*) FROM flights 
WHERE tailnum = "N123UW" OR 
tailnum = "N848MQ" OR 
tailnum = "N328AA" OR 
tailnum = "N247JB"
GROUP BY tailnum ORDER BY COUNT(*);
-- N328AA made the most flights (393).

-- #4
SELECT * FROM planes 
WHERE tailnum = "N123UW" OR 
tailnum = "N848MQ" OR 
tailnum = "N328AA" OR 
tailnum = "N247JB";
-- N247JB has the second-highest number of flights, despite being the smallest and newest plane.
-- This may be due to its smaller size, which could make more flights possible.

-- #5
SELECT tailnum, year, month, day, dep_delay, arr_delay, dest FROM flights
WHERE
	(year = 2013 AND
    month = 2 AND
    day BETWEEN 14 AND 17) AND
    (tailnum = "N123UW" OR 
	tailnum = "N848MQ" OR 
	tailnum = "N328AA" OR 
	tailnum = "N247JB");


-- ASSIGNMENT: SQL SELECT AND AGGREGATIONS

-- #1
SELECT * FROM flights WHERE distance = (SELECT MAX(distance) FROM flights);
-- The destination that is farthest away is Honolulu, which is 4,983 mi away from JFK. 

-- #2
SELECT engines, MAX(seats) FROM planes GROUP BY engines;
/* The table contains planes with 1, 2, 3, and 4 engines. 
For planes with 1 engine, the max number of seats is 16.
For planes with 2 engines, the max number of seats is 400.
For planes with 3 engines, the max number of seats is 379.
For planes with 4 engines, the max number of seats is 450.
*/

-- #3
SELECT * FROM flights;
SELECT COUNT(*) FROM flights;
-- The total number of flights in the database is 336,776.alter

-- #4
SELECT carrier, COUNT(*) FROM flights GROUP BY carrier;

-- #5
SELECT carrier, COUNT(*) FROM flights GROUP BY carrier ORDER BY COUNT(*) DESC;

-- #6
SELECT carrier, COUNT(*) FROM flights GROUP BY carrier ORDER BY COUNT(*) DESC LIMIT 5;

-- #7
SELECT carrier, COUNT(*) FROM flights WHERE distance > 1000 GROUP BY carrier ORDER BY COUNT(*) DESC LIMIT 5;

-- #8: Which airline has the highest average arrival and departure delay?
SELECT carrier, AVG(arr_delay), AVG(dep_delay) FROM flights GROUP BY carrier ORDER BY AVG(arr_delay) DESC;
-- The carrier F9, or Frontier Airlines, has the highest average arrival delay at 22 minutes, and the highest departure delay at 20 minutes.