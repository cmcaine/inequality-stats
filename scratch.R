library(tidyverse)
library(ggpubr)

all_imd = read_csv("data/File_7_ID_2015_All_ranks__deciles_and_scores_for_the_Indices_of_Deprivation__and_population_denominators.csv")
View(all_imd)

all_imd %>% arrange(`Index of Multiple Deprivation (IMD) Score`) %>% slice(1:10) %>% select(`LSOA name (2011)`, `Index of Multiple Deprivation (IMD) Score`, `Index of Multiple Deprivation (IMD) Rank (where 1 is most deprived)`)

all_imd %>%
  ggplot() +
  geom_point(aes(x = `Index of Multiple Deprivation (IMD) Score`,
    y = `Index of Multiple Deprivation (IMD) Rank (where 1 is most deprived)`)) +
  ggtitle("A lower score indicates a less deprived area")

scores = all_imd$`Index of Multiple Deprivation (IMD) Score`
gghistogram(scores)
summary(scores)

# Combine with LSOA polygons
library(sf)
lsoa_bounds = st_read("data/Lower_Layer_Super_Output_Areas_December_2011_Generalised_Clipped__Boundaries_in_England_and_Wales.shp")
sf_imds = dplyr::left_join(all_imd, lsoa_bounds, by = c("LSOA code (2011)" = "lsoa11cd")) %>% st_as_sf()

# Read 
bookmakers = read_csv("data/bookmaker_positions.csv") %>% st_as_sf(coords = c("lon", "lat")) %>% st_geometry()

# Transform to common reference system.
st_crs(bookmakers)<-4326
sf_imds = st_transform(sf_imds, 4326)

# Count the number of bookmakers in each lsoa and add that as a column
sf_imds$num_bookmakers = st_intersects(sf_imds, bookmakers) %>% lapply(length) %>% unlist()

# Quick  and dirty map plot: faster than tmap but 
# sf_imds %>% select(num_bookmakers) %>% plot()

library(tmap)

# Plot the first N LSOAs on a map
# -- This is really slow, slower than I think it would be if just uploaded to mapbox gl js
# Sending straight to PDF by wrapping with this helps by avoiding slow rstudio rendering.
#  pdf("map.pdf")
#  dev.off()

sf_imds %>% slice(1:1000) %>%
  tm_shape() + tm_fill("Index of Multiple Deprivation (IMD) Score", style="cont")

# Plot same with the locations of bookies as well
sf_imds %>% slice(1:1000) %>%
  tm_shape() + tm_fill("Index of Multiple Deprivation (IMD) Score", style="cont") +
  tm_shape(bookmakers) + tm_dots()
