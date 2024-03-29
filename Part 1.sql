-- MSc in DMDS - 2023-24
-- 7CPSQL / EMLYON Business School
-- FINAL GROUP PROJECT


-- For the FINAL PROJECT you will use the 'Divvy' database. 
-- It is part of a dataset derived from a bycicle sharing service in the city of Chicago, IL (USA) 
-- The service is similar to Lyon's "Velo'v". 
-- The database has two tables: 
-- (i) Trips, containing all the trips from the year 2018
-- (ii) Stations, which contains some data on each of the stations.

-- The data has been made available by Motivate International Inc. under this license:
-- https://ride.divvybikes.com/data-license-agreement and the full dataset as originally provided can be found here:
-- https://divvy-tripdata.s3.amazonaws.com/index.html
-- To give you a feeling for the data, we plotted the stations from the Stations table here:
-- https://www.google.com/maps/d/edit?mid=1o8GHKNl2UdNlCEVGWqzjTWxOoyB-EEg&usp=sharing
-- More about Divvy here: https://divvybikes.com/system-data

-- When completing this project as a group, remember to make your SQL code clear and comment on all queries.
-- Marks are provided for attempts made, so it's better to make an attempt than to completly leave a question out.

-- Marking scheme:
-- Part1 /4 ; Part2 /5 ; Part3 /7 (4+3) ; Quality of comments and presentations /4

USE Divvy;

-- PART 1 [4 marks]
-- Explore the database and its tables, then discuss your findings. Consider all the usual aspects in database exploration:
-- (e.g., are the data types assigned to each field correct? Are there any duplicates?)
-- Answer this question: What is the common key between the two tables?
-- Remember to take into account where the data comes from.

use Divvy;
Describe Trips;
-- For start_time and end time are text, they should be datetime; 
-- For tripduration, it is text and should be BIGINT;
-- For birthyear, it is double and should be year type.
Describe Stations;
-- online_date type is text, should be changed to date.

-- other finds: some birthyear value is 0 and some gender value is blank; There is 0 duplicated in two tables.
use Divvy;
Select count(*) as duplicate_count
From 
(
    Select count(*) as count
    From Trips
    Group by trip_id, start_time, end_time, bikeid, tripduration, from_station_id, to_station_id, usertype, gender, birthyear
    Having count > 1
) 
As duplicates;
use Divvy;
Select count(*) as duplicate_count
From
(
    Select count(*) as count
    From Stations
    Group by id, name, latitude, longitude, dpcapacity, landmark, online_date
    Having count > 1
) 
As duplicates;
-- common key：  'id' & 'from_station_id 'and 'to_station_id'

-- PART 2 [5 marks]
-- Imagine your database administrator is a slacker, and hasn't updated the Stations table since 2013.
-- (We uploaded the 2013 stations on purpose here of course!).
-- How many unique stations are in the Trips but not in the Stations? 
-- TIPS: 
-- Include stations "from_station_id" as well as stations "to_station_id".
-- You will need to use the keyword UNION, which combines the results from two queries into one column, dropping any duplicates
-- You can do a mini-practice here to understand the keyword before applying it: https://www.w3schools.com/sql/sql_union.asp
-- Remember to also display your results as a percentage of the total number of stations and not only as a absolute number.
-- We are suggesting a four-step plan to help you. You don't have to follow it, but it would be very helpful.
-- Don't forget to make your reasoning clear and to comment each of your steps.

-- Step 1: Write a query to know which station IDs in the "from_station_id" field are not in the Stations table.
-- Then do the same for the column "to_station_id".

use Divvy;
select from_station_id AS station_id
FROM Trips
WHERE from_station_id not IN (SELECT id FROM Stations); 

select to_station_id AS station_id
FROM Trips
WHERE to_station_id not IN (SELECT id FROM Stations);

-- Step 2: Now, combine your two tables in STEP 1, using the keyword UNION.
-- A UNION will drop any duplicates, so you just need to count everything in the combined table
-- This will essentially represent the number of all missing stations.

select from_station_id AS station_id
FROM Trips
WHERE from_station_id not IN (SELECT id FROM Stations)
union -- combine two tables without duplicated values
select to_station_id AS station_id
FROM Trips
WHERE to_station_id not IN (SELECT id FROM Stations)
;
-- Step 3: Using the same UNION keyword, count the total number of different stations in the two columns of the Trips table
-- (i.e., from_station_id and to_station_id).
-- TIP: Remember that a UNION will drop any duplicates and 
-- Note that in this case you are using UNION to combine data in two columns of the same table
use Divvy;
select count(station_id)
from  -- use the combined table as sub query, and count all station_id
(
select from_station_id AS station_id
FROM Trips
WHERE from_station_id not IN (SELECT id FROM Stations)
union
select to_station_id AS station_id
FROM Trips
WHERE to_station_id not IN (SELECT id FROM Stations)

) sub; 
-- Step 4: Finally, write a query that displays the percentage of missing stations from the stations table.

use Divvy;
select 
-- Below is the formula for missing station. Numerator is the count for all station_id from trips tables;
-- Denominator is the count for all id from Stations table. Transfer to percentage and Round to two decimal places
CONCAT(ROUND(COUNT(station_id) / (SELECT COUNT(id) FROM Stations) * 100, 2), '%') AS percentage_id
from
(
select from_station_id AS station_id
FROM Trips
WHERE from_station_id not IN (SELECT id FROM Stations)
union
select to_station_id AS station_id
FROM Trips
WHERE to_station_id not IN (SELECT id FROM Stations)
) sub;

-- PART 3 [7 marks (4+3)]
-- The marketing department wants to know the age distribution of our users, and how their usage differs (in terms of trip durations). 
-- Give them a plot of age (on the X-axis), and average tripduration on the y-axis. 

-- PART 3.1
-- To achieve this, this, write a query that returns both age and average tripduration data from the Divvy Database
-- You need to extract the age from the birthyear field in the Trips table, given that this data contains all the trips from the year 2018
-- Make sure to not include missing values, and and order results by age. 
-- Now, export your data into a CSV file, then convert into Excel, and make the plot in Excel.
-- Explain your steps and discuss your findings. Please hand in your excel file, plus a discussion of what you did 
-- and what your conclusions are (Excel or SQL script comments). 
-- There appears to be a difference between the way the plot behaves before and after an age of about 65. 
-- Discuss what you think the reason is for the shape of the plot overall, and this difference as well.
use Divvy;
SELECT
YEAR(CURRENT_DATE) - birthyear AS age, -- Caculate the age from birthyear
AVG(tripduration) AS average_tripduration 
FROM Trips
-- Below is make sure the year is 2018, and birthyear is not null and 0;
-- Age more than 100 is not possible to ride, so we remove it
WHERE start_time LIKE '%2018%' AND (birthyear IS NOT NULL AND birthyear != '0') AND YEAR(CURRENT_DATE) - birthyear < 100 
GROUP BY YEAR(CURRENT_DATE) - birthyear
ORDER BY age;

-- PART 3.2
-- Change your query in 3.1 by using FLOOR([your data]/10)*10 AS age_bin in a query that counts the number of trips 
-- grouped per age ranges (represented by age_bin, e.g., 10,20,30,40,50 etc.) instead of absolute values of age. 
-- This is a histogram in tabular form, which can then be exported to Excel in order to plot it.
-- Make the plot, then compare it to the one from your Query in 3.1. 
-- If you had done only this query (and not Query 3.1), would you have arrived at a different conclusion? 
-- Would it have been valid? Why yes or why not?
use Divvy;
SELECT
FLOOR((YEAR(CURRENT_DATE) - birthyear)/10)*10 AS age_bin,
COUNT(*) AS number_of_trips
FROM Trips
WHERE start_time LIKE '%2018%' AND birthyear IS NOT NULL AND birthyear != '0' AND YEAR(CURRENT_DATE) - birthyear < 100
GROUP BY age_bin
ORDER BY age_bin;







