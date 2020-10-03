library(tidyverse)
library(sf)

gadm_full <- read_sf("../gadm36.gpkg")

# first, check for partial match cases within each level
# or whatever you'd call that ... basically same ID / different valid / remarks / etc,
gadm_columns <- st_drop_geometry(gadm_full)

# save column info
gadm_columns %>% 
  write_rds("Data/gadm_columns.rds", compress = "gz")


potential_valid_dates <- gadm_columns %>% 
  select(starts_with("VALIDTO")) %>% 
  pivot_longer(everything(), names_to = "level", names_prefix = "VALIDTO_", values_to = "date") %>% 
  count(level, date)

# I'm pretty much fine keeping all the locations that don't have an explicit end date
# for now, drop all areas that are no longer valid

gadm_bad1 <- gadm_columns %>% filter(str_starts(VALIDTO_1, "[0-9]{2}"))

# or maybe lets just let it play out however it does ... no way I'll need anything below level 3, so let's start there
gadm_g3 <- gadm_full %>% 
  group_by(GID_0, GID_1, GID_2, GID_3) %>% 
  summarize(members = n(),
            .groups = "drop")
