# MSBA Lab: lab-spatialDB-nyc

Please Clone or Download this repo if you want to follow along during the lab session.

This repo is for a class lab designed to introduce spatial database management systems in PostgreSQL, ODBC workflow, and R as a GIS from data wrangling to visualization.

## Installing PostgreSQL and PostGIS

I suggest downloading the OpenGeo stack distributed by [BoundlessGeo](http://boundlessgeo.com/products/downloads/).  It is completely free but in order to get the download files, you need to fill out a quick form and they should email you.  It makes installation of PostgreSQL, PostGIS, GeoServer and more super easy and hassle free.  Sometimes it takes some time to receive the files, so I will include direct installation of PostgreSQL and PostGIS for Windows and Mac OS.  If you do not receive an email, go ahead and install postgres directly.

### Windows:

* Retrieve the executables for [PostgreSQL from the EnterpriseDB distribution](http://www.enterprisedb.com/products-services-training/pgdownload) and choose the appropriate OS.
* Install PostgreSQL
* After installing it on your system, launch Application Stack Builder
  * Start -> Programs -> PostGreSQL 9.6 -> Application Stack Builder
  * Under Spatial Extensions, select the most recent PostGIS extension
* Make note of your server port, password (best to make it "postgres"), user/host name, ect.

If you are having trouble, consult StackOverflow!

### Mac OS:

There is a very simple PostgreSQL distribution for Mac OSX called [postgres.app](http://postgresapp.com).  Just download the application and move the blue elephant icon into your applications folder, and run it.  Once pgsql is running you should see a small elephant in profile appear in your menu bar, which is normally located along the top of your desktop.  

You will also be interested in installing a GUI tool that will assist with a variety of functions, including viewing your tables and executing scripts.  A very popular and widely used GUI is pgAdmin4.  Please go ahead and install it from [pgadmin](https://www.pgadmin.org/download/macos4.php).  Some other popular PostgreSQL GUI tools are Postico, PG Commander, and Induction, which you can find links to from the [postgress.app page] (http://postgresapp.com/documentation/gui-tools.html).

Once you have installed postgres.app and pgadmin4, you can go into the pgadmin4 application and create a new server and database.  In the browser window, right click on server and add server (name it as you please).  Once you have done this, right click on your server and choose to create a new database.  After creating your database, use the plus button to expand the database and find the Extensions element, right click on it and choose Create Extension, and then add the postgis extension to your database.  Now your database should be ready to use.

On a Mac, you may need to add the path to the postgresql application, in order to execute commands from the terminal.  To do this, go to your elephant in the menu bar and select 'about psql,' which will provide you with the version.  Then you will want to enter the PATH to the executable as a command in terminal by entering the following.

'PATH=/Applications/Postgres.app/Contents/Versions/9.5/bin/:$PATH'



## Create a New DataBase

With our new local server, let's create a new Database called `nyc`.
* Open pgAdmin and log into the localhost server with port 5432.
  * Password and username should be postgres
* Right click on Databases and create a new one.
  * Name it nyc and set owner to postgres
* Open pgAdmin4, log into the server, and open a new SQL window (top tooldbar)
  * Execute query `CREATE EXTENSION postgis();`
  * IMPORTANT: Don't skip this step or else any functions that you call from PostGIS will return an error

## Load Shapefiles

### Run CREATE TABLE Scripts:

Run each SQL script found in `lab-spatialDB-nyc/scriptsSQL/BatchLoad`.  You will find 6 sql scripts that create a table in the database called `nyc` for each dataset.  This is a laborious way to upload the data into the database, but it is best given that everyone is running different systems.  My insutrctions below are biased towards Windows users (insert PC Master Race joke here) and the bash shell script might not work for Mac users.  While the command prompt or bash terminal methods (explained below) are ideal, it is easier if everyone runs the same script.  I will go over this in class.

### OpenGeo's pgShapeLoader:

The great thing about OpeGeo is that they include a Graphical User Interface (GUI) for the shp2pgsql command line interface called [pgShapeLoader or shp2pgsql-gui](http://suite.opengeo.org/opengeo-docs/dataadmin/pgGettingStarted/pgshapeloader.html).  At this point, it is very straightforward uploading your shapefiles from the data file into the database you just created.  Follow this guide if you received the OpenGeo distirbution in a timely manner.  Follow the instructions, but note that the SRID (Spatial Reference ID, or what defined the projection) will be **26918** for this lab.

### shp2pgsql:

If you do not have a GUI file loader, we can load files the old-fashioned way... the trusty command-line.  PostgreSQL's command line is normally called pgsql, but PostGIS extends GIS functions with the shp2pgsql command.  There are two ways to load shapefiles into tables, one command at a time or batch loading.  This is tricky to lay out here because each system may vary with database names, passwords, port numbers, ect.  I will write the code with the following assumptions, but be prepared to adjust if need be:

* `<DBNAME>` is "nyc"
* `<DBTABLE>` is the name of the shapefile minus the extension
* `<SCHEMA>` is the default "public" one created when you install postgres
* `<SRID>` will **ALWAYS** be defined as 26918 for this lab.
* PORT # is 5432
* `<FILE\PATH.shp>` **You have to denote you're own file paths where necessary!!**

Reference this guide on PostgreSQL Command-Line Interface for [shp2pgsql](http://suite.opengeo.org/opengeo-docs/dataadmin/pgGettingStarted/shp2pgsql.html) and if you have trouble, consult StackOverflow.

#### Method 1

Check that postgres is responsive or connected:

Syntax: 
```
psql -U postgres -d <DBNAME> -c "SELECT postgis_version()"
```
Code: 
```
psql -U postgres -d nyc -c "SELECT postgis_version()"
```
Good? Let's run the shp2pgsql command

Syntax: 
```
shp2pgsql -I -s <SRID> <PATH/TO/SHAPEFILE> <SCHEMA>.<DBTABLE> | psql -U postgres -d <DBNAME>
```
Code: 
```
shp2pgsql -I -s 26918 C:\Users\yalot\OneDrive\DataProjects\nyc_census_blocks.nyc public.nyc_census_blocks | psql -U postgres -d nyc
```

You know it completed when the end of the long list of `INSERT` ends with `COMMIT`.  Check by counting the number of rows in a new command:
```
psql -U postgres -d nyc -c "SELECT count(*) FROM nyc_census_blocks"
```
You could repeat this 4 or 5 times to create each table individually or we can write a script to load them all at once!

#### Method 2: Batch Loading

If you named your database `nyc` then simply run the following files depending on you're OS.  If not, make the simple edit to the file.

Windows user: run `loadfiles.cmd` (BATCH file) in the data folder.

MAC user:  run the `loadfiles.sh` (Bash file) in the same folder.

Take a look at the code as it uses regular expressions, pipe operators, and loops! 

## Explore Tables (PostgreSQL)

The hard part is out of the way and now we are all prepared to actually dive into the data.  We can perform traditional `SELECT` queries to get a sense of the data we imported and what it can tell us.  pgAdmin is a nice UI to see the structure of PostgreSQL servers and databases.  Opening a SQL Query window is where the majority of scripting will occur.  It's the most advanced editor (no IntelliSense like MS SQL Server) but it has basic code coloring.

## Geometric, GIS-related Queries (PostGIS Functions)

Notice the `geom` column in our tables.  This is a metadata column for storing the spatial information for each row.  We can use this to perform spatial joins and geometric functions like area or length calculations.  This is the bread and butter aspect of PostGIS where we can do super simple queries to calculate population densities per square kilometer or advanced techniques like K-Nearest Neighbor or writing geospatial functions from scratch.

## ODBC with R

Our workflow will deal primairly with homicide and demographic stats.  We were able to get a sense of our data in SQL.  Now, we are ready to get into analysis which is best done in a tool like QGIS, ArcGIS, or R.  The first task is to connect our R session to our local Postgres database.  This is called Open DataBase Connection (ODBC) and is akin to how you can connect to a database in Excel.  The `ODBC.R` script loads the reuired packages and code so that we can run SQL queries natively in R.

Most real world data is going to be stored on a database, whether its Postgres, MySQL, MS SQL Server ect.  Understanding how we can combine the benefits of a relational database and a language like R is truly powerful.  The concept of ODBC applies across languages and tools.  Similar functionality exists in Python, for example.

## Data Wrangling in R 

Thanks to ODBC and multiple R libraries that facilitate communication with our RDBMS, we can pull data into R, clean it, and ultimately build beautiful maps!

We want to prepare our data in order to easily plot it using Hadley Whickham's awesome grammar of graphics syntax from `ggplot2`.  That means executing relevent queries from within R, perform multiple steps like fortifying the spatial elements and joining dataframes.  Thanks to the fact that data in an RDBMS is already structured and organized, there are relatively few steps we need to do.  There also is not missing or other issues that generally haunt data scientists.  That is another benefit of pulling from a database populated by pre-processed data.  That is certainly not always the case.

## R and ggplot2 as a GIS

With the right packages, we can turn R into an effective GIS.  That means importing shapefiles, transforming them, and of course mapping them.  Take a look at the `sourcePackages.R` scripts which calls GIS packages.  While PostGIS is by far the best way to organize sptial data and perform spatial manipulations, we can't actually present the data without connecting this back-end to a front-end system.  By front-end, I mean something like QGIS, CartoDB, ArcGIS, or in this case, R.  Keep in mind R is excellent at statistical modeling and packages like `spatstat` allow for powerful spatial statistical modeling as well. 

If you do not have PostgreSQL installed on your computer, you can also directly import shapefiles into R.  While not ideal when dealing with several layers, it is still nice to know that you can import, project, organize, and visualize basic shapefiles within R given the right packages.
