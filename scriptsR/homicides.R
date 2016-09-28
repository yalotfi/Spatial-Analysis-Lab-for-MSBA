rm(list = ls())

source("scriptsR/sourcePackages.R")
source("scriptsR/mapHelpers.R")
source("scriptsR/ODBC.R")


#########################
### Pull Spatial Data ###
#########################
## Neighborhood Polygons
sql_hoods <- "SELECT * FROM nyc_neighborhoods"
hoods <- get_postgis_query(con, sql_hoods, "geom")
rm(sql_hoods)

## Homicide Points
sql_homic <- "SELECT a.* FROM nyc_homicides AS a JOIN nyc_neighborhoods AS b ON ST_Intersects(a.geom, b.geom)"
homic <- get_postgis_query(con, sql_homic, "geom")
rm(sql_homic)

## Murders in each NYC neighborhood
system.time (
  homicides <- query("
      SELECT    a.name AS name,
                count(b.*) AS murder_ct
      FROM      nyc_neighborhoods AS a
      JOIN      nyc_homicides AS b
        ON      ST_Intersects(a.geom, b.geom)
      GROUP BY  a.name
    ;")
  )

#####################
### Data Cleaning ###
#####################
## Prepare NYC Neighborhood Polygon Data
hoods.ft <- fortify(hoods)
hoods.df <- hoods@data
hoods.df$id <- row.names(hoods.df)
hoods.map <- left_join(hoods.ft, hoods.df, by = "id")

## Prepare Homicide Data
homic.pt <- as.data.frame(homic@coords)
names(homic.pt) <- c("long", "lat")
homic.df <- homic@data
names(homic.df) <- tolower(names(homic.df))
homic.map <- cbind.data.frame(homic.df, homic.pt)
homic.map <- subset(homic.map, weapon == "gun" | weapon == "knife")

## Join Homicide Counts with Neighborhoods
hoods.map <- left_join(hoods.map, homicides, by = "name")  # Add count column to map df
apply(hoods.map, 2, function(x) sum(is.na(x)))  # Check NAs only exist in dead count column
hoods.map$murder_ct[is.na(hoods.map$murder_ct)] <- 0  # Replace NAs w/ 0
apply(hoods.map, 2, function(x) sum(is.na(x)))  # Check NAs were removed


###############
### Mapping ###
###############
## Plot NYC Homicides
col.pal <- c("#FF5733", "#56B1F7")  # Red and Blue Hexes for color scale
pointHeatMap <- ggplot() + 
  geom_polygon(data = hoods.map, aes(x = long, y = lat, group = group, fill = hoods.map$murder_ct), color = "#000000") +
  geom_point(data = homic.map, aes(long, lat, color = weapon), size = 0.25) +
  coord_equal(ratio = 1) +
  scale_fill_gradient(  name  = "Homicides \n Count"
                        , high  = "#ffe6e6"
                        , low   = "#4d4d4d"
                        , space = "Lab") +
  scale_color_manual(  values = col.pal
                     , name = "Weapon \n Type"
                     , labels = c("Guns", "Knife")) +
  ggtitle_subtitle("Homicides in NYC:", "2003 - 2011") +
  BlackTheme(18) +
  theme(
    legend.justification = c(0,1.35), 
    legend.position = c(0, 1)
  )
# pointHeatMap
ggsave(pointHeatMap, filename = "output/pointHeat.homic.pdf", width = 8.5, height = 11)

