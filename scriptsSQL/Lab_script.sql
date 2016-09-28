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

-- Project NYC Streets Table
SELECT ST_SRID(geom) FROM nyc_streets LIMIT 1;  -- Check SRID
SELECT UpdateGeometrySRID('nyc_streets', 'geom', 26918);
	-- Basically a compact ALTER TABLE statement
SELECT ST_SRID(geom) FROM nyc_streets LIMIT 1;  -- Check again, should change

-- Spatial Joins: Population Density in Upper East and West Sides
SELECT    b.name, 
	  Sum(a.popn_total) / (ST_Area(b.geom) / 1000000.0) AS pop_per_km2
FROM 	  nyc_census_blocks AS a
JOIN 	  nyc_neighborhoods AS b
  ON 	  ST_Intersects(a.geom, b.geom)
WHERE	  b.name like 'Upper West Side' OR b.name like 'Upper East Side'
GROUP BY  b.name, b.geom
	-- Two spatial functions (Area and Intersects)
	--Note the Time: 113ms

/** SIDENOTE **/	
-- Indexing and Vacuuming: Efficiency in PostgreSQL
DROP INDEX nyc_census_blocks_geom_idx --Already Exists
CREATE INDEX nyc_census_blocks_geom_idx  --Name of Index
  ON nyc_census_blocks  -- Table to Index
  USING GIST (geom); -- Generic Index Structure

	-- Test Compute Time: Note how many ms it takes to execute query
	SELECT    b.name, 
		  Sum(a.popn_total) / (ST_Area(b.geom) / 1000000.0) AS pop_per_km2
	FROM 	  nyc_census_blocks AS a
	JOIN 	  nyc_neighborhoods AS b
	  ON 	  ST_Intersects(a.geom, b.geom)
	WHERE	  b.name like 'Upper West Side' OR b.name like 'Upper East Side'
	GROUP BY  b.name, b.geom
		-- w/out Index: 485ms
		-- w/ Index: 85ms

-- Vacuuming also improves efficiency
VACUUM ANALYZE nyc_census_blocks
	-- Return freed space after creating index, running updates or deletes, ect
/** Back to GIS **/

-- Length of Lines
SELECT type, Sum(ST_Length(geom)) AS length
FROM nyc_streets
GROUP BY type
ORDER BY length DESC;

-- K Nearest Neighbor: Closest Streets from Bryant Park Subway (42nd St)
SELECT
  a.gid,
  a.name
FROM
  nyc_streets a
ORDER BY
  a.geom <->
  (SELECT geom 
   FROM nyc_subway_stations 
   WHERE name like '42nd St' AND alt_name like 'Bryant Park')
LIMIT 10;
