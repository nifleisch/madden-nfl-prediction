library(tidyverse)
library(nflverse)


madden_data_path <- file.path("..","..","data", "processed_data", "madden_overall_rating.csv")
madden <- read_csv(madden_data_path)

depth_charts <- load_depth_charts(2004:2020)

helper_df <- depth_charts %>% 
  mutate(
    jersey_number = as.double(jersey_number),
    club_code
  ) %>% 
  rename(c("first_name_l" = "first_name", "last_name_l" = "last_name", "jersey_number_l" = "jersey_number", "position_l" = "position")) %>% 
  left_join(
    madden,
    by = c("season", "club_code" = "team_abbr", "first_name_l" = "first_name", "last_name_l" = "last_name", 
           "jersey_number_l" = "jersey_number", "position_l" = "position")
  )

madden_enriched <- helper_df %>% filter(!is.na(team_name))

to_go <- helper_df %>% filter(is.na(team_name)) %>% select(season:full_name)

#-------------------------------------------------------------------------------------------------------------------------

helper_df <- to_go %>% 
  left_join(
    madden,
    by = c("season", "club_code" = "team_abbr", "last_name_l" = "last_name", 
           "jersey_number_l" = "jersey_number", "position_l" = "position")
  )
madden_enriched <- helper_df %>% filter(!is.na(team_name)) %>% union_all(madden_enriched)
to_go <- helper_df %>% filter(is.na(team_name)) %>% select(season:full_name)

#-------------------------------------------------------------------------------------------------------------------------

helper_df <- to_go %>% 
  left_join(
    madden,
    by = c("season", "club_code" = "team_abbr", "last_name_l" = "last_name", 
           "jersey_number_l" = "jersey_number", "depth_position" = "position")
  )
madden_enriched <- helper_df %>% filter(!is.na(team_name)) %>% union_all(madden_enriched)
to_go <- helper_df %>% filter(is.na(team_name)) %>% select(season:full_name)

#-------------------------------------------------------------------------------------------------------------------------

helper_df <- to_go %>% 
  left_join(
    madden,
    by = c("season", "club_code" = "team_abbr", "last_name_l" = "last_name", 
           "jersey_number_l" = "jersey_number")
  )
madden_enriched <- helper_df %>% filter(!is.na(team_name)) %>% union_all(madden_enriched)
to_go <- helper_df %>% filter(is.na(team_name)) %>% select(season:full_name)

#-------------------------------------------------------------------------------------------------------------------------

helper_df <- to_go %>% 
  left_join(
    madden,
    by = c("season", "club_code" = "team_abbr", "first_name_l" = "first_name", "last_name_l" = "last_name")
  )
madden_enriched <- helper_df %>% filter(!is.na(team_name)) %>% union_all(madden_enriched)
to_go <- helper_df %>% filter(is.na(team_name)) %>% select(season:full_name)

#-------------------------------------------------------------------------------------------------------------------------

helper_df <- to_go %>% 
  left_join(
    madden,
    by = c("season", "club_code" = "team_abbr", "position_l" = "position", "last_name_l" = "last_name")
  )
madden_enriched <- helper_df %>% filter(!is.na(team_name)) %>% union_all(madden_enriched)
to_go <- helper_df %>% filter(is.na(team_name)) %>% select(season:full_name)

#-------------------------------------------------------------------------------------------------------------------------

helper_df <- to_go %>% 
  left_join(
    madden,
    by = c("season", "club_code" = "team_abbr", "depth_position" = "position", "last_name_l" = "last_name")
  )
madden_enriched <- helper_df %>% filter(!is.na(team_name)) %>% union_all(madden_enriched)
to_go <- helper_df %>% filter(is.na(team_name)) %>% select(season:full_name)

#-------------------------------------------------------------------------------------------------------------------------

helper_df <- to_go %>% 
  left_join(
    madden,
    by = c("season", "first_name_l" = "first_name", "last_name_l" = "last_name", 
           "position_l" = "position")
  )
madden_enriched <- helper_df %>% filter(!is.na(team_name)) %>% union_all(madden_enriched)
to_go <- helper_df %>% filter(is.na(team_name)) %>% select(season:full_name)

#-------------------------------------------------------------------------------------------------------------------------

helper_df <- to_go %>% 
  left_join(
    madden,
    by = c("season", "first_name_l" = "first_name", "last_name_l" = "last_name", 
           "depth_position" = "position")
  )
madden_enriched <- helper_df %>% filter(!is.na(team_name)) %>% union_all(madden_enriched)
to_go <- helper_df %>% filter(is.na(team_name)) %>% select(season:full_name)

#-------------------------------------------------------------------------------------------------------------------------

helper_df <- to_go %>% 
  left_join(
    madden,
    by = c("season", "club_code" = "team_abbr", "first_name_l" = "first_name",  "position_l" = "position")
  )
madden_enriched <- helper_df %>% 
  filter(!is.na(team_name)) %>% 
  union_all(madden_enriched) %>% 
  select(season, club_code, team_id, week, first_name_l, last_name_l, jersey_number_l, formation, position_l, depth_position, depth_team, rating) %>% 
  rename(c("last_name" = "last_name_l", "first_name" = "first_name_l", "jersey_number" = "jersey_number_l", "position" = "position_l"))

madden_enriched_path <- file.path("..","..","data", "processed_data", "madden_with_depth_team.csv")
write_csv(madden_enriched, madden_enriched_path)
