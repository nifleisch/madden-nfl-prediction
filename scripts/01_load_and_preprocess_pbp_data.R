library(tidyverse)
library(nflreadr)
library(lubridate)

pbp_data <- load_pbp(2003:2022)

game_data <- pbp_data %>% 
  select(play_id, game_id, yards_gained, old_game_id, home_team, away_team, season_type, 
         week, posteam, yardline_100, game_date, qtr, down, ydstogo, ydsnet, play_type, 
         field_goal_result, kick_distance, extra_point_result, two_point_conv_result, ep, 
         epa, total_home_epa, total_away_epa, total_home_rush_epa, total_away_rush_epa, 
         total_home_pass_epa, total_away_pass_epa, third_down_converted, third_down_failed, 
         fourth_down_converted, fourth_down_failed, incomplete_pass, interception, fumble_forced, 
         fumble_not_forced, qb_hit, rush_attempt, pass_attempt, sack, pass_touchdown, rush_touchdown, 
         two_point_attempt, field_goal_attempt,fumble, passing_yards, rushing_yards, penalty_yards, 
         penalty_team, season, start_time, play_type_nfl, drive_time_of_possession, fixed_drive_result, 
         away_score, home_score, div_game, roof, surface, temp, wind, stadium_id, game_stadium) %>% 
  mutate(
    home_penalty_yards = if_else(penalty_team == home_team, penalty_yards, 0), 
    away_penalty_yards = if_else(penalty_team != home_team, penalty_yards, 0),
    pass_yards_gained = if_else(play_type == "pass", yards_gained, NULL),
    run_yards_gained = if_else(play_type == "run", yards_gained, NULL), 
    run_attempt = if_else(play_type == "run", 1, 0),
    field_goal_made = if_else(field_goal_result == "made", 1, 0),
    extra_point_good = if_else(extra_point_result == "good", 1, 0),
    pass_epa = if_else(play_type == "pass", epa, NULL), 
    rush_epa = if_else(play_type == "run", epa, NULL)
  ) %>% 
  group_by(game_id, old_game_id, home_team, away_team, season_type, week, posteam, game_date, season, 
           start_time, away_score, home_score, div_game, roof, surface, stadium_id, game_stadium) %>%
  summarize(
    avg_epa = mean(epa, na.rm = TRUE),
    avg_pass_epa = mean(pass_epa, na.rm = TRUE),
    avg_rush_epa = mean(rush_epa, na.rm = TRUE),
    n_third_down_converted = sum(third_down_converted, na.rm = TRUE),
    n_third_down_failed = sum(third_down_failed, na.rm = TRUE),
    n_fourth_down_converted = sum(fourth_down_converted, na.rm = TRUE),
    n_fourth_down_failed = sum(fourth_down_failed, na.rm = TRUE),
    n_pass_attempts = sum(pass_attempt, na.rm = TRUE),
    n_run_attempts = sum(run_attempt, na.rm = TRUE),
    n_incomplete_pass = sum(incomplete_pass, na.rm = TRUE),
    n_interception = sum(interception, na.rm = TRUE),
    n_fumble_forced = sum(fumble_forced, na.rm = TRUE),
    n_fumble_not_forced = sum(fumble_not_forced, na.rm = TRUE),
    n_qb_hit = sum(qb_hit, na.rm = TRUE),
    n_sacks = sum(sack, na.rm = TRUE),
    n_two_point_attempts = sum(two_point_attempt, na.rm = TRUE),
    n_field_goal_attempts = sum(field_goal_attempt, na.rm = TRUE),
    n_fumbles = sum(fumble, na.rm = TRUE),
    sum_home_penalty_yards = sum(home_penalty_yards, na.rm = TRUE),
    sum_away_penalty_yards = sum(away_penalty_yards, na.rm = TRUE),
    n_pass_touchdown = sum(pass_touchdown, na.rm = TRUE),
    n_rush_touchdown = sum(rush_touchdown, na.rm = TRUE),
    field_goal_success_rate = mean(field_goal_made, na.rm = TRUE),
    extra_point_success_rate = mean(extra_point_good, na.rm = TRUE),
    avg_pass_yards_gained = mean(pass_yards_gained, na.rm = TRUE),
    avg_run_yards_gained = mean(run_yards_gained, na.rm = TRUE),
    temp = first(na.omit(temp)), 
    wind = first(na.omit(wind))
  ) %>% 
  ungroup() %>% 
  filter(!is.na(posteam)) %>% 
  mutate(
    third_down_conversion_rate = n_third_down_converted / (n_third_down_converted + n_third_down_failed),
    fourth_down_attempts = n_fourth_down_converted + n_fourth_down_failed, 
    fourth_down_conversion_rate = n_fourth_down_converted / fourth_down_attempts,
    percentage_pass_attemps = n_pass_attempts / (n_pass_attempts + n_run_attempts),
    percentage_run_attemps = n_run_attempts / (n_pass_attempts + n_run_attempts),
    percentage_incomplete_pass = n_incomplete_pass / n_pass_attempts,
    percentage_interception = n_interception / n_pass_attempts,
    n_attempts = n_pass_attempts + n_run_attempts,
    percentage_fumbles = n_fumbles / n_attempts,
    percentage_qb_hits = n_qb_hit/ n_attempts,
    percentage_sacks = n_sacks/ n_attempts,
    n_touchdowns = n_pass_touchdown + n_rush_touchdown,
    pass_touchdown_rate = n_pass_touchdown / n_touchdowns,
    offense= if_else(home_team == posteam, home_team, away_team),
    defense = if_else(home_team == posteam, away_team, home_team)
  ) %>% 
  pivot_longer(c(offense, defense), names_to = "platoon", values_to = "team")



def_game_data <- game_data %>% 
  filter(platoon == "defense") %>% 
  mutate(
    points_allowed = if_else(team == home_team, away_score, home_score),
    penalty_yards = if_else(team == home_team, sum_home_penalty_yards, sum_away_penalty_yards),
    rush_touchdowns_allowed = n_rush_touchdown,
    pass_touchdowns_allowed = n_pass_touchdown,
    touchdowns_allowed = n_touchdowns,
    avg_pass_yards_allowed = avg_pass_yards_gained,
    avg_run_yards_allowed = avg_run_yards_gained,
    third_down_success_rate = 1 - third_down_conversion_rate,
    fourth_down_success_rate = 1 - fourth_down_conversion_rate,
    percentage_incomplete_passes_forced = 1 - percentage_incomplete_pass
  ) %>% 
  select(game_id, old_game_id, season, week, season_type, team, points_allowed, avg_epa, avg_rush_epa, 
         avg_pass_epa, third_down_success_rate, fourth_down_success_rate, 
         percentage_incomplete_passes_forced, n_incomplete_pass, n_interception, n_fumble_forced, 
         n_qb_hit, n_sacks, penalty_yards, rush_touchdowns_allowed, pass_touchdowns_allowed, 
         touchdowns_allowed, avg_pass_yards_allowed, avg_run_yards_allowed, percentage_incomplete_passes_forced, 
         percentage_interception, percentage_qb_hits, percentage_sacks)


off_game_data <- game_data %>% 
  filter(platoon == "offense") %>%
  mutate(
    points_scored = if_else(team == home_team, home_score, away_score),
    penalty_yards = if_else(team == home_team, sum_home_penalty_yards, sum_away_penalty_yards)
  ) %>% 
  select(game_id, season, week, season_type, team, points_scored, avg_epa, avg_rush_epa, avg_pass_epa, 
         n_third_down_converted, n_third_down_failed, n_fourth_down_converted, n_fourth_down_failed, 
         n_interception, n_qb_hit, n_sacks, n_fumbles, penalty_yards, n_pass_touchdown, n_rush_touchdown, 
         field_goal_success_rate, extra_point_success_rate, avg_pass_yards_gained, avg_run_yards_gained, 
         third_down_conversion_rate, fourth_down_conversion_rate, percentage_pass_attemps, 
         percentage_incomplete_pass, percentage_interception, percentage_fumbles, percentage_qb_hits,
         percentage_sacks, n_touchdowns, pass_touchdown_rate)

meta_game_data <- game_data %>% 
  select(game_id, old_game_id, season, game_date, start_time, week, season_type, home_team, away_team, 
         div_game, roof, surface, stadium_id, game_stadium, temp, wind) %>% 
  distinct() %>% 
  mutate(
    game_time = str_c(game_date, start_time, sep=" "),
    game_time = parse_date_time(game_time, "ymd HMS")) %>% 
  pivot_longer(
    cols=c(home_team, away_team), 
    names_to = "home_away", 
    values_to = "team") %>% 
  group_by(team) %>% 
  arrange(team, game_time) %>% 
  mutate(
    lagged_game_time = lag(game_time, n = 1, default = NA),
    rest_time = interval(lagged_game_time, game_time) %/% hours(1),
    rest_time = if_else(is.na(rest_time) | rest_time > 500, 168, rest_time), 
    weekday = wday(game_time, label = T),
    monday_game = weekday == "Mon",
    thursday_game = weekday == "Thu"
  ) %>% 
  select(-c(lagged_game_time, weekday)) %>% 
  pivot_wider(
    id_cols = -c(home_away, team, rest_time), 
    names_from = home_away, 
    values_from = c(team,rest_time)) %>% 
  rename(c(away_team = team_away_team, home_team = team_home_team))

game_data_path <- file.path("..","..","data", "processed_data", "game_data.csv")
offense_game_data_path <- file.path("..","..","data", "processed_data", "offense_game_data.csv")
defense_game_data_path <- file.path("..","..","data", "processed_data", "defense_game_data.csv")
meta_game_data_path <- file.path("..","..","data", "processed_data", "meta_game_data.csv")

write_csv(game_data, game_data_path)
write_csv(off_game_data, offense_game_data_path)
write_csv(def_game_data, defense_game_data_path)
write_csv(meta_game_data, meta_game_data_path)

