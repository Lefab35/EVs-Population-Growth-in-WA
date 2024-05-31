CREATE DATABASE ev_population;

USE ev_population;

# MY DATA WAS TOO LARGE TO BE IMPORTED INTO MYSQL DATABASE, SO I HAD TO SPLIT IT IN TWO CSV FILES: 'EV1' AND 'EV2' 
# ONCE IMPORTED INTO SCHEMA, I'VE THEN MERGED THEM USING THE 'UNION' COMMAND FROM MYSQL

SELECT * FROM ev1
UNION
SELECT * FROM ev2; 

# Data Cleaning
-- =>> Find and Remove Duplicates <<= --

SELECT vin, make, COUNT(*) as duplicates
FROM (
    SELECT vin, make
    FROM ev1
    UNION 
    SELECT vin, make
    FROM ev2
) as combined_tables
GROUP BY vin, make
HAVING duplicates > 1
ORDER BY duplicates DESC;     # NO DUPLCATE !!!


# QUESTIONS

-- > 1. EVs population by years in WASHINGTON STATE? <--
SELECT model_year, COUNT(*) AS total_ev
FROM (
    SELECT * 
    FROM ev1
    UNION 
    SELECT *
    FROM ev2
) as combined_tables
WHERE model_year != '2024'
GROUP BY model_year
ORDER BY model_year DESC;


-- >> 2. EV's Distribution by cities ? <<--
SELECT city, SUM(vin) AS ev_pop
FROM (
    SELECT *
    FROM ev1
    UNION ALL
    SELECT *
    FROM ev2
) as combined_tables
GROUP BY city
ORDER BY ev_pop DESC
LIMIT 10;


-- ><>> 3. EVs Model distribution across the state? <<><--
SELECT model, SUM(vin) AS total_ev
FROM (
    SELECT *
    FROM ev1
    UNION
    SELECT *
    FROM ev2
) as combined_tables
GROUP BY model
ORDER BY total_ev DESC
LIMIT 10;


-- <>>> 4. EVs range per models? <<<> --
SELECT model, AVG(electric_range) AS mile_range 
FROM (
	SELECT *
    FROM ev1
    UNION
    SELECT *
    FROM ev2
) as combined_tables
WHERE electric_range > 0
GROUP BY model
HAVING mile_range > 0
ORDER BY mile_range DESC
LIMIT 25;


-- >>>>> 5. Average EVs range per Brand? <<<<<--
SELECT make, AVG(electric_range) AS range_avg
FROM (
	SELECT make, electric_range
    FROM ev1
    UNION
    SELECT make, electric_range
    FROM ev2
) as combined_tables
WHERE electric_range > 0 
GROUP BY make
HAVING range_avg > 0 
ORDER BY range_avg DESC
LIMIT 10;


-- <>>>><> 6. Average base_mrsp by EV models? <><<<<> --
SELECT model, AVG(base_msrp) AS msrp_avg
FROM (
	SELECT model, base_msrp
    FROM ev1
    UNION
    SELECT model, base_msrp
    FROM ev2
) as combined_tables
WHERE base_msrp > 0 
GROUP BY model
HAVING msrp_avg > 0 
ORDER BY msrp_avg DESC
LIMIT 10;

-- >><> 7. Total EV's registered in the state? <><<--
SELECT COUNT(*) AS total_ev
FROM (
	SELECT *
    FROM ev1
    UNION
    SELECT *
    FROM ev2
) as combined_tables;


-- <>>>><>> 8. Average base_mrsp by EV models? <<><<<<> --
SELECT model_year, COUNT(*), model, AVG(base_msrp) AS msrp_avg 
FROM (
	SELECT *
    FROM ev1
    UNION
    SELECT *
    FROM ev2
) as combined_tables
WHERE base_msrp > 0 
GROUP BY model_year, model
HAVING msrp_avg > 0 
ORDER BY msrp_avg DESC
LIMIT 10;


-- >><><> 9. What're the EVs electric range? <><><<--
SELECT MIN(electric_range) AS sortest_range, MAX(electric_range) AS longest_range
FROM (
	SELECT * FROM ev1
    UNION
    SELECT * FROM ev2
) AS combined_tables
WHERE electric_range > 0;


SELECT 
	CASE
		WHEN electric_range >= 6 AND electric_range <= 99 THEN 'Low Battery Range'
        WHEN electric_range >= 100 AND electric_range <= 199 THEN 'Medium Battery Range'
        WHEN electric_range >= 200  AND electric_range <= 299 THEN 'Long Battery Range'
        ELSE 'Super Battery'
	END AS battery_range,
    COUNT(*) AS count
FROM (
	SELECT * 
    FROM ev1
    UNION
    SELECT * 
    FROM ev2
) AS combined_tables
WHERE electric_range > 0 
GROUP BY battery_range
ORDER BY battery_range;
    

SELECT 
	CASE
		WHEN electric_range >= 6 AND electric_range <= 99 THEN 'Low Battery Range'
        WHEN electric_range >= 100 AND electric_range <= 199 THEN 'Medium Battery Range'
        WHEN electric_range >= 200  AND electric_range <= 299 THEN 'Long Battery Range'
        ELSE 'Super Battery'
	END AS battery_range,
    COUNT(*) AS count,
    cafv_eligibility
FROM (
	SELECT * 
    FROM ev1
    UNION
    SELECT * 
    FROM ev2
) AS combined_tables
WHERE electric_range > 0 
GROUP BY battery_range, cafv_eligibility
ORDER BY battery_range;


-- <<<>>> 10. What're the list of all EV Models located in king county with electric_range is greather than 200 miles <<<>>> --

SELECT model, county, COUNT(model) AS count
FROM (
	SELECT * FROM ev1
    UNION
    SELECT * FROM ev2
) AS combined_tables
WHERE electric_range > 200 AND county = 'King'
GROUP BY county, model
HAVING COUNT(*) > 0
ORDER BY model;
