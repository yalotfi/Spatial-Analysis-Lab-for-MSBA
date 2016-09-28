-----------------------------
-- Create Spatial Database --
-----------------------------
CREATE EXTENSION postgis;
SELECT postgis_full_version();

-----------------------
-- Define Projection --
-----------------------
SELECT srtext FROM spatial_ref_sys WHERE srid = 26918;

----------------------
-- Explore the Data --
----------------------

-- Look at neighborhoods
SELECT name FROM nyc_neighborhoods;

SELECT 	 boroname AS Boro, 
	 count(name) AS Neighborhood_ct
FROM 	 nyc_neighborhoods
GROUP BY boroname;

-- Total Population in Millions
SELECT sum(popn_total) / 1000000 FROM nyc_census_blocks;

SELECT 	 boroname AS Boro, 
	 sum(popn_total) / 1000000 AS totalPopulation_M
FROM 	 nyc_census_blocks
GROUP BY boroname
ORDER BY sum(popn_total) / 1000000 desc;

-- Racial demographics
SELECT 	 boroname AS Boro,
	 (sum(popn_white) / sum(popn_total)) * 100 AS pct_white
FROM 	 nyc_census_blocks
GROUP BY boroname
ORDER BY (sum(popn_white) / sum(popn_total)) * 100 asc;

-- Crime Stats
select * from nyc_homicides limit 5;

select 	year,
	count(*) AS murder_count
from 	nyc_homicides
group by year
order by year desc;

select boroname, count(*) AS murder_count
from nyc_homicides
group by boroname;

select * from nyc_census_blocks limit 5;

select boroname, sum(popn_total) 
from nyc_census_blocks
group by boroname;

select boroname, count(*)
from nyc_homicides
group by boroname;
----------------
-- Geometries --
----------------
select * from geometry_columns;
