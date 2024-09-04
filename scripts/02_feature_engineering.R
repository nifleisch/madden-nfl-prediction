library(tidyverse)
library(lubridate)
library(janitor)
library(geosphere)

offense_game_data_path <- file.path("..","..","data", "processed_data", "offense_game_data.csv")
defense_game_data_path <- file.path("..","..","data", "processed_data", "defense_game_data.csv")
meta_game_data_path <- file.path("..","..","data", "processed_data", "meta_game_data.csv")
weather_data_path <- file.path("..","..","data", "raw_data", "tom_bliss", "games_weather.csv")
stadium_data_path <- file.path("..","..","data", "raw_data", "tom_bliss", "stadium_coordinates.csv")
stadium_game_data_path <- file.path("..","..","data", "raw_data", "tom_bliss", "games.csv")
elo_data_path <- file.path("..","..","data","raw_data","fivethirtyeight","nfl_games.csv")

off_game_data <- read_csv(offense_game_data_path)
def_game_data <- read_csv(defense_game_data_path)
meta_game_data <- read_csv(meta_game_data_path)
weather_data <- read_csv(weather_data_path) %>% 
  clean_names()
stadium_data <- read_csv(stadium_data_path) %>% 
  clean_names() %>% 
  select(-home_team) %>% 
  distinct()
new_game_data <- read_csv(stadium_game_data_path) %>%
  clean_names()
elo_data <- read_csv(elo_data_path) %>% 
  filter(season >= 2004) %>% 
  select(season, date, team1, team2, elo1, elo2, elo_prob1) %>% 
  rename(c("elo_home" = "elo1", "elo_away" = "elo2", "elo_prob_home_win" = "elo_prob1"))

meta_game_data <- meta_game_data %>% 
  left_join(
    weather_data, 
    by = c("old_game_id" = "game_id")
    ) %>%
  group_by(across(game_id:rest_time_home_team)) %>% 
  summarise(
    across(
      source:estimated_condition, 
      ~ first(na.omit(.x))
      )
    ) %>% 
  ungroup() %>% 
  left_join(
    new_game_data, 
    by = c("old_game_id" = "game_id", "season" = "season")
    ) %>% 
  left_join(
    stadium_data, 
    by = c("stadium_name" = "stadium_name")
    )

team_location_data <- meta_game_data %>% 
  group_by(home_team, season, longitude, latitude) %>% 
  summarise(n = n()) %>% 
  ungroup() %>% 
  group_by(home_team, season) %>% 
  arrange(desc(n)) %>% 
  summarise(
    across(
      longitude:latitude, 
      ~ first(na.omit(.x))
      )
    ) %>% 
  ungroup() %>% 
  rename(team = home_team)


meta_game_data <- meta_game_data %>% 
  left_join(
    team_location_data, 
    by = c("away_team" = "team", "season" = "season"), 
    suffix = c("_home", "_away")
    ) %>% 
  rowwise() %>% 
  mutate(travel_distance = distm(c(longitude_home, latitude_home), c(longitude_away, latitude_away), fun = distHaversine)) %>% 
  ungroup()

off_game_data <- off_game_data %>% 
  group_by(team, season) %>% 
  mutate(game_nr = seq(n())) %>% 
  ungroup()


last_season_means <- off_game_data %>% 
  mutate(is_regular_season = as.double(season_type == "REG")) %>% 
  group_by(team, season) %>%
  summarise(
    across(
      points_scored:pass_touchdown_rate, 
      ~ weighted.mean(.x, is_regular_season, na.rm = TRUE)
      )
    ) %>% 
  ungroup() %>% 
  mutate(season = season + 1)

help_off_game_data <- tibble(
  game_id = c("auxilary_game_1", "auxilary_game_2", "auxilary_game_3", "auxilary_game_4", "auxilary_game_5"),
  week = c(0, -1, -2, -3, -4),
  game_nr = c(0, -1, -2, -3, -4),
  season_type = c("REG", "REG", "REG", "REG", "REG")
  ) %>% 
  full_join(
    last_season_means, 
    by = character()
    ) %>% 
  relocate(season, .before = week)

lag_0 <- union_all(off_game_data, help_off_game_data) %>% mutate(lag = 0)
lag_1 <- lag_0 %>% mutate(game_nr = game_nr + 1, lag = lag +1)
lag_2 <- lag_1 %>% mutate(game_nr = game_nr + 1, lag = lag +1)
lag_3 <- lag_2 %>% mutate(game_nr = game_nr + 1, lag = lag +1)
lag_4 <- lag_3 %>% mutate(game_nr = game_nr + 1, lag = lag +1)
lag_5 <- lag_4 %>% mutate(game_nr = game_nr + 1, lag = lag +1)

avg_last_five_games <- lag_1 %>% 
  union_all(lag_2) %>% 
  union_all(lag_3) %>% 
  union_all(lag_4) %>% 
  union_all(lag_5) %>% 
  group_by(season, game_nr, team) %>% 
  summarise(
    across(
      points_scored:pass_touchdown_rate, 
      ~ mean(.x, na.rm = T)
      )
    ) %>% 
  ungroup()

off_game_data <- lag_0 %>% 
  select(game_id, season, week, season_type, team, game_nr, points_scored) %>%
  rename(c("y" = "points_scored")) %>% 
  left_join(
    avg_last_five_games, 
    by = c("season" = "season", "game_nr" = "game_nr", "team" = "team")
    ) %>% 
  filter(game_nr >= 1) %>% 
  select(-game_nr)


def_game_data <- def_game_data %>% 
  group_by(team, season) %>% 
  mutate(game_nr = seq(n())) %>% 
  ungroup()

last_season_means <- def_game_data %>% 
  mutate(is_regular_season = as.double(season_type == "REG")) %>% 
  group_by(team, season) %>%
  summarise(
    across(points_allowed:percentage_sacks, 
           ~ weighted.mean(.x, is_regular_season, na.rm = TRUE)
           )
    ) %>% 
  ungroup() %>% 
  mutate(season = season + 1)

help_def_game_data <- tibble(
  game_id = c("auxilary_game_1", "auxilary_game_2", "auxilary_game_3", "auxilary_game_4", "auxilary_game_5"),
  week = c(0, -1, -2, -3, -4),
  game_nr = c(0, -1, -2, -3, -4),
  season_type = c("REG", "REG", "REG", "REG", "REG")) %>% 
  full_join(
    last_season_means, 
    by = character()
    )

lag_0 <- union_all(def_game_data, help_def_game_data) %>% mutate(lag = 0)
lag_1 <- lag_0 %>% mutate(game_nr = game_nr + 1, lag = lag +1)
lag_2 <- lag_1 %>% mutate(game_nr = game_nr + 1, lag = lag +1)
lag_3 <- lag_2 %>% mutate(game_nr = game_nr + 1, lag = lag +1)
lag_4 <- lag_3 %>% mutate(game_nr = game_nr + 1, lag = lag +1)
lag_5 <- lag_4 %>% mutate(game_nr = game_nr + 1, lag = lag +1)

avg_last_five_games <- lag_1 %>% 
  union_all(lag_2) %>% 
  union_all(lag_3) %>% 
  union_all(lag_4) %>% 
  union_all(lag_5) %>% 
  group_by(season, game_nr, team) %>% 
  summarise(
    across(points_allowed:percentage_sacks, 
           ~ mean(.x, na.rm = T)
           )
    ) %>% 
  ungroup()

def_game_data <- lag_0 %>% 
  select(game_id, season, week, season_type, team, game_nr) %>% 
  left_join(
    avg_last_five_games, 
    by = c("season" = "season", "game_nr" = "game_nr", "team" = "team")
    ) %>% 
  filter(game_nr >= 1) %>% 
  select(-game_nr)

basic_features <- off_game_data %>% 
  left_join(
    meta_game_data, 
    by = c("game_id", "season", "week", "season_type")
    ) %>% 
  mutate(
    offense_home = team == home_team,
    defense_team = if_else(team == home_team, away_team, home_team)
    ) %>% 
  left_join(
    def_game_data, 
    by = c("game_id", "season", "week", "defense_team" = "team"), 
    suffix = c("_offense", "_defense")
    ) %>% 
  filter(season >= 2004) %>% 
  mutate(
    travel_distance = travel_distance[1],
    home_team_join = case_when(
      home_team == "WAS" ~ "WSH",
      home_team == "LV" ~ "OAK",
      home_team == "LA" ~ "LAR",
      TRUE ~ home_team),
    away_team_join = case_when(
      away_team == "WAS" ~ "WSH",
      away_team == "LV" ~ "OAK",
      away_team == "LA" ~ "LAR",
      TRUE ~ away_team)
    ) %>% 
  left_join(
    elo_data,
    by = c("season", "game_date" = "date", "home_team_join" = "team1", "away_team_join" = "team2")
  ) %>% 
  mutate(
    temperature = if_else(is.na(temperature), temp, temperature),
    wind_speed = if_else(is.na(wind_speed), wind, wind_speed),
    is_regular_season = (season_type_offense == "REG")
  ) %>% 
  filter(season <= 2020) %>% 
  select(-c(wind, temp, stadium_id, game_stadium, defense_team, season_type_offense, season_type_defense, team, stadium_name,
            time_start_game, time_end_game, roof_type, longitude_home, latitude_home, stadium_azimuth_angle, longitude_away,
            latitude_away, defense_team, home_team_join, away_team_join, start_time, game_time, source, distance_to_station
            ))

basic_features_path <- file.path("..","..","data","processed_data","basic_features.csv")
write_csv(basic_features, basic_features_path)


