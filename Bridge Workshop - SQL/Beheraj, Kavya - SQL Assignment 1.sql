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