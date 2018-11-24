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

# Plot the first 100 LSOAs on a map
library(tmap)
sf_imds %>% slice(1:100) %>% qtm(fill = "Index of Multiple Deprivation (IMD) Score")