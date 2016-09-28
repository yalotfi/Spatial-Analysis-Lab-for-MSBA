## ODBC
library(RPostgreSQL)
library(sqldf)
library(DBI)
library(postGIStools)


dbname   <- "nyc"
user     <- "postgres"
password <- "postgres"
host     <- "localhost"
port     <- 5432

## Connect via RPostgreSQL Package
con <- dbConnect(dbDriver("PostgreSQL"), user = user, password = password, dbname = dbname, host = host)
query <- function(sql) {
  fetch(dbSendQuery(con, sql), n = nchar(sql))
}

rm(dbname, user, password, host, port) # Remove superfluous objects
