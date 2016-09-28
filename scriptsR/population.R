rm(list = ls())

source("scriptsR/sourcePackages.R")  # Call relevent libraries
source("scriptsR/mapHelpers.R")  # Create helper functions and procedures
source("scriptsR/ODBC.R")  # Prepare DataBase connection and query methods

#########################
### Query Census Data ###
#########################
## Bring inital query into R data frame
system.time(
  population <- query("
    SELECT    a.name                                              AS name
              , Sum(b.popn_total)                                 AS total_pop
              , Sum(b.popn_total) / (ST_Area(a.geom) / 1000000.0) AS pop_per_km2
              , 100.0 * Sum(b.popn_white) / Sum(b.popn_total)     AS white_pct
              , 100.0 * Sum(b.popn_black) / Sum(b.popn_total)     AS black_pct
              , 100.0 * Sum(b.popn_asian) / Sum(b.popn_total)     AS asain_pct
              , 100.0 * Sum(b.popn_other) / Sum(b.popn_total)     AS other_pct
    FROM      nyc_neighborhoods AS a
    JOIN      nyc_census_blocks AS b
      ON      ST_Intersects(a.geom, b.geom)
    WHERE     b.popn_total <> 0
    GROUP BY  a.name, a.geom
    ORDER BY  Sum(b.popn_total) DESC
  ;")
)

## Add additional column to identify majority group
population <- within(population, {
  race <- NA
  race[
    white_pct > black_pct &
      white_pct > asain_pct &
      white_pct > other_pct
  ] <- "white"
  race[
    black_pct > white_pct &
      black_pct > asain_pct &
      black_pct > other_pct
  ] <- "black"
  race[
    asain_pct > white_pct &
      asain_pct > black_pct &
      asain_pct > other_pct
  ] <- "asain"
  race[
    other_pct > white_pct &
      other_pct > black_pct &
      other_pct > asain_pct
  ] <- "other"
})


######################
### Method 1: ODBC ###
######################
## Use PostGIStools
sql_hoods <- "SELECT * FROM  nyc_neighborhoods"
nyc <- get_postgis_query(con, sql_hoods, "geom")
rm(sql_hoods)


###############################
### Method 2: Direct Import ###
###############################
## Import shapefiles directly
proj4 <- "+proj=utm +zone=18 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
nyc <- spTransform(readOGR(dsn = "data", layer = "nyc_neighborhoods", stringsAsFactors = F, verbose = F), CRS(proj4))
rm(proj4)

#########################
### Clean/Manage Data ###
#########################
## Manage/Clean spatial data in R
nyc.ft <- fortify(nyc)  # Coerce long/lat ect data into ggplot readable table
nyc.df <- nyc@data  # Extract non-spatial data
nyc.df$id <- row.names(nyc.df)  # Add ID row for join
nyc.map <- left_join(nyc.ft, nyc.df, by = "id")  # Join Spatial and non-spatial data on ID
names(nyc.map) <- tolower(names(nyc.map))  # Change ncolumn names  # Make col names lowercase... Necessary for Method 2
# names(nyc.map) <- c(names(nyc.map[,1:7]), "boroname", "name")  # Alternative way to change col names
demogs.map <- left_join(nyc.map, population, by = "name")

## Race/ethnic Breakout
white <- filter(demogs.map, race == "white")
black <- filter(demogs.map, race == "black")
asain <- filter(demogs.map, race == "asain")
other <- filter(demogs.map, race == "other")


#####################
### Plotting Data ###
#####################
## Plot Population Densities in NYC
map.pop <- ggplot() + 
  geom_polygon(data = demogs.map, aes(long, lat, group = group, fill = total_pop)) +
  coord_equal() + 
  geom_path(color = "black") +
  scale_fill_gradient(name = "Population"
                      , labels = c("50K", "100K", "150K", "200K", "250K")
                      , breaks = c(5e4, 1e5, 1.5e5, 2e5, 2.5e5)
                      , low = "#132B43"
                      , high = "#56B1F7"
                      , space = "Lab")+ 
  ggtitle_subtitle("Plotting NYC's High Population Areas", 
                   "Yaseen Lotfi - Data Science Lab") +
  BlackTheme(15) +
  theme(
      legend.justification = c(0,1.35)
    , legend.position = c(0, 1)
  )
# map.pop
ggsave(map.pop, filename = "output/map.pop.pdf", width = 8.5, height = 11)

## Plot Demographics of NYC
cols <- c(  "White"="#56B1F7"
            , "Black"="#00e600"
            , "Asain"="#FF5733"
            , "OtherHispanic"="#ffcc00")  # Values for legend scale
demogs.map <- ggplot() +
  geom_polygon(data = white, aes(long, lat, group = group), fill = "#56B1F7", color = "black") +
  geom_polygon(data = black, aes(long, lat, group = group), fill = "#00e600", color = "black") +
  geom_polygon(data = asain, aes(long, lat, group = group), fill = "#FF5733", color = "black") +
  geom_polygon(data = other, aes(long, lat, group = group), fill = "#ffcc00", color = "black") +
  coord_equal() + 
  geom_path() +
  scale_fill_manual(name = "Demographics", values = cols) +
  ggtitle_subtitle("Demographics of NYC", "Plotting Neighborhood Diversity") +
  BlackTheme(18)
# demogs.map
ggsave(demogs.map, filename = "output/demogs.pop.pdf", width = 8.5, height = 11)
