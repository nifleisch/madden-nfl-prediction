library(tidyverse)
library(nflreadr)
library(janitor)

madden_enriched_path <- file.path("..", "..", "data", "processed_data", "madden_with_depth_team.csv")
madden_enriched <- read_csv(madden_enriched_path)

basic_features_path <- file.path("..", "..", "data","processed_data","basic_features.csv")
features <- read_csv(basic_features_path)

snap_count <- load_snap_counts(2012:2020)

helper <- load_depth_charts(2012:2020) %>% 
  mutate(player = paste(first_name, last_name, sep = " ")) %>% 
  inner_join(
    snap_count,
    by = c("season", "week", "player", "club_code" = "team", "position")
  ) %>% 
  filter(formation == "Offense") %>% 
  group_by(depth_team) %>% 
  summarise(
    median = median(offense_pct)
  ) %>% 
  mutate(formation = "Offense")

depth_team_snap_pct <- load_depth_charts(2012:2020) %>% 
  mutate(player = paste(first_name, last_name, sep = " ")) %>% 
  inner_join(
    snap_count,
    by = c("season", "week", "player", "club_code" = "team", "position")
  ) %>% 
  filter(formation == "Defense") %>% 
  group_by(depth_team) %>% 
  group_by(depth_team) %>% 
  summarise(
    median = median(defense_pct)
  ) %>% 
  mutate(formation = "Defense") %>% 
  union_all(helper) %>% 
  mutate(depth_team = as.double(depth_team))


features <- features %>% 
  mutate(
    offense_team = if_else(offense_home, home_team, away_team),
    defense_team = if_else(offense_home, away_team, home_team)
  )

position_rating <- madden_enriched %>% 
  left_join(
    depth_team_snap_pct,
    by = c("formation", "depth_team")
  ) %>%  
  group_by(season, formation, club_code, week, position, depth_team) %>% 
  summarise(
    rating = mean(rating, na.rm=T),
    median = first(median)
  ) %>% 
  ungroup() %>% 
  group_by(season, formation, club_code, week, position) %>%
  summarise(
    position_rating = weighted.mean(rating, median, na.rm=T)
  ) %>% 
  arrange(season, formation, club_code, week, position)

offense_position_rating <- position_rating %>% 
  filter(formation == "Offense") %>% 
  pivot_wider(id_cols = season:week, names_from = position, values_from = position_rating) %>% 
  ungroup() %>% 
  select(where(~mean(is.na(.)) < 0.3)) %>% 
  select(-formation)

offense_position_rating <- offense_position_rating %>% 
  filter(club_code %in% c("STL", "SD", "OAK")) %>% 
  mutate(club_code = case_when(
    club_code == "STL" ~ "LA",
    club_code == "SD" ~ "LAC",
    club_code == "OAK" ~ "LV"
  )) %>% 
  union_all(offense_position_rating)

defense_position_rating <- position_rating %>% 
  filter(formation == "Defense") %>% 
  pivot_wider(id_cols = season:week, names_from = position, values_from = position_rating) %>% 
  ungroup() %>% 
  select(where(~mean(is.na(.)) < 0.3)) %>% 
  select(-formation)


defense_position_rating <- defense_position_rating %>% 
  filter(club_code %in% c("STL", "SD", "OAK")) %>% 
  mutate(club_code = case_when(
    club_code == "STL" ~ "LA",
    club_code == "SD" ~ "LAC",
    club_code == "OAK" ~ "LV"
  )) %>% 
  union_all(defense_position_rating)

enriched_features <- features %>% 
  left_join(
    offense_position_rating,
    by = c("offense_team" = "club_code", "season", "week")
  ) %>% 
  left_join(
    defense_position_rating,
    by = c("defense_team" = "club_code", "season", "week")
  ) %>% 
  clean_names() %>% 
  mutate(
    elo_offense_team = if_else(offense_home, elo_home, elo_away),
    elo_defense_team = if_else(offense_home, elo_away, elo_home),
    elo_prob_offense_win = if_else(offense_home, elo_prob_home_win, 1 - elo_prob_home_win)
  )

madden_enriched_path <- file.path("..", "..", "data", "processed_data", "features_with_madden.csv")
write_csv(enriched_features, madden_enriched_path)