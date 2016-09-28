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

-- Homicides per Year
SELECT 	year,
	count(*) AS murder_count
FROM 	nyc_homicides
GROUP BY year
ORDER BY year DESC;

-- Avg Murder Rate (2003 - 2011)
SELECT boroname, sum(popn_total) AS total_pop
INTO temp_pop
FROM nyc_census_blocks
GROUP BY boroname;

SELECT boroname, count(*) AS murder_ct
INTO temp_homic
FROM nyc_homicides
GROUP BY boroname;

SELECT 	  a.boroname, 
	  a.total_pop, 
	  b.murder_ct, 
	  b.murder_ct / (a.total_pop / 100000) AS avg_murder_rate
FROM 	  temp_pop AS a
JOIN 	  temp_homic AS b
  ON 	  a.boroname = b.boroname
ORDER BY  b.murder_ct / (a.total_pop / 100000) DESC;

DROP TABLE temp_pop
DROP TABLE temp_homic

------------------------
-- Geometries and GIS --
------------------------
--Projections
SELECT * FROM geometry_columns;
SELECT * FROM spatial_ref_sys WHERE srid = 26918;
SELECT proj4text FROM spatial_ref_sys WHERE srid = 26918;
SELECT ST_SRID(geom) FROM nyc_streets LIMIT 1;
