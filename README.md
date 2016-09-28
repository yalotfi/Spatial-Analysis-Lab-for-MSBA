# lab-spatialDB-nyc
A class lab designed to introduce spatial database management systems in PostgreSQL, ODBC workflow, and using R as a GIS from data wrangling to visualization.

## Installing PostgreSQL and PostGIS
Retrieve the executables for [PostgreSQL](http://www.enterprisedb.com/products-services-training/pgdownload) and choose the appropriate OS.
### Windows:
* Install PostgreSQL
* After installing it on your system, launch Application Stack Builder
  * Start -> Programs -> PostGreSQL 9.5 -> Application Stack Builder
  * Under Spatial Extensions, select the most recent PostGIS extension

### Mac OS:

## Create a New DataBase

## Load Shapefiles

## Explore Tables (PostgreSQL)
We can perform traditional 'SELECT' queries to get a sense of the data we imported and what it can tell us.

## Geometric, GIS-related Queries (PostGIS Functions)
Notice the 'geom' column in our tables.  This is a metadata column for storing the spatial information for each row.  We can use this to perform spatial joins and geometric functions like area or length calculations.

## ODBC with R
Our workflow will deal primairly with homicide and demographic stats.  We were able to get a sense of our data and NYC.  Now, we are ready to get into analysis which is best done in a full GIS like QGIS or (surprise, surprise) R.  The first task is to connect our R session to our local Postgres database.

Most real world data is going to be stored on a database, whether its Postgres, MySQL, MS SQL Server ect.  Understanding how we can combine the benefits of a relational database and a language like R is truly powerful.

## Data Wrangling in R 
Thanks to ODBC and multiple R libraries that facilitate communication with our RDBMS, we can pull data into R, clean it, and ultimately build bueatiful maps!

We want to prepare our data in order to easily plot it using Hadley Whickham's awesome grammar of graphics syntax (ggplot2).  That means executing relevent queries from within R, perform multiple steps like fortifying the spatial elements and joins, and then we are ready.

## R and ggplot2 as a GIS
With the right packages, we can turn R into an effective GIS.  That means importing shapefiles, transforming them, and of course mapping them.  While PostGIS is by far the best way to organize and perform spatial manipulations, we can't actually present the data without connecting this back-end to a front-end system like QGIS, ArcGIS, or, in this case, R.  While we won't get into it here, since R is so powerful at statistical modeling, there are also packages like 'spatstat' that allow for powerful spatial statistical modeling as well. 
