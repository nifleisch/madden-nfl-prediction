library(tidyverse)
library(nflverse)
library(readxl)

madden_05_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_05.csv")
madden_06_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_06.csv")
madden_07_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_07.csv")
madden_08_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_08.csv")
madden_09_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_09.csv")
madden_10_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_10.csv")
madden_11_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_11.csv")
madden_12_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_12.csv")
madden_13_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_13.xlsx")
madden_14_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_14.xlsx")
madden_15_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_15.xlsx")
madden_16_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_16.xlsx")
madden_17_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_17.xlsx")
madden_18_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_18.xlsx")
madden_19_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_19.xlsx")
madden_20_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_20.csv")
madden_21_path <- file.path("..","..","data", "raw_data", "madden", "madden_nfl_21.csv")


madden_05 <- read_csv(madden_05_path) %>% 
  rename("first_name" = "FIRSTNAME", "last_name" = "LASTNAME", "position" = "Position", 
         "number" = "JERSEYNUM", "rating" = "OVERALLRATING") %>% 
  select(parsed_team, first_name, last_name, number, position, rating) %>% 
  mutate(season = 2004)

madden_06 <- read_csv(madden_06_path) %>% 
  rename("first_name" = "FIRSTNAME", "last_name" = "LASTNAME", "position" = "Position", 
         "number" = "JERSEYNUMBER", "rating" = "OVERALLRATING") %>% 
  select(parsed_team, first_name, last_name, number, position, rating) %>% 
  mutate(season = 2005)

madden_07 <- read_csv(madden_07_path) %>% 
  rename("first_name" = "PLYR_FIRSTNAME", "last_name" = "PLYR_LASTNAME", "position" = "Position", 
         "number" = "PLYR_JERSEYNUM", "rating" = "PLYR_OVERALLRATING") %>% 
  select(parsed_team, first_name, last_name, number, position, rating) %>% 
  mutate(season = 2006)

madden_08 <- read_csv(madden_08_path) %>% 
  rename("first_name" = "First_Name", "last_name" = "Last_Name", "position" = "Position", 
         "number" = "Jersey_#", "rating" = "Overall_Rating") %>% 
  select(parsed_team, first_name, last_name, number, position, rating) %>% 
  mutate(season = 2007)

madden_09 <- read_csv(madden_09_path) %>% 
  rename("first_name" = "FIRSTNAME", "last_name" = "LASTNAME", "position" = "Position", 
         "number" = "JERSEYNUM", "rating" = "OVERALL") %>% 
  select(parsed_team, first_name, last_name, number, position, rating) %>% 
  mutate(season = 2008)

madden_10 <- read_csv(madden_10_path) %>% 
  rename("team" = "Team", "first_name" = "First", "last_name" = "Last", "position" = "POS", 
         "rating" = "OVR") %>% 
  select(team, first_name, last_name, position, rating) %>% 
  mutate(season = 2009)

madden_11 <- read_csv(madden_11_path) %>% 
  rename("team" = "TEAM", "first_name" = "FIRST NAME", "last_name" = "LAST NAME", "position" = "POSITION", 
         "number" = "JERSEY #", "rating" = "OVERALL RATING") %>% 
  select(team, first_name, last_name, number, position, rating) %>% 
  mutate(season = 2010)

madden_12 <- read_csv(madden_12_path) %>% 
  filter(Name != "Name") %>% 
  filter(!is.na(Name)) %>% 
  extract(Name, c("first_name", "last_name"), "([^ ]+) (.*)") %>% 
  rename("position" = "Position", "rating" = "Overall") %>% 
  select(parsed_team, first_name, last_name, position, rating) %>% 
  mutate(
    season = 2011,
    rating = as.double(rating)
  )

madden_13 <- read_excel(madden_13_path) %>% 
  rename("team" = "Team", "first_name" = "First Name", "last_name" = "Last Name", "position" = "Position", 
         "rating" = "Overall") %>% 
  select(team, first_name, last_name, position, rating) %>% 
  mutate(season = 2012)
madden_14 <- read_excel(madden_14_path) %>% 
  rename("team" = "Team", "first_name" = "First Name", "last_name" = "Last Name", "position" = "Position", 
         "number" = "Jersey", "rating" = "Overall") %>% 
  select(team, first_name, last_name, number, position, rating) %>% 
  mutate(season = 2013)

madden_15 <- read_excel(madden_15_path) %>% 
  rename("team" = "Team", "first_name" = "First Name", "last_name" = "Last Name", "position" = "Position", 
         "number" = "Jersey", "rating" = "Overall") %>% 
  select(team, first_name, last_name, number, position, rating) %>% 
  mutate(
    season = 2014,
    rating = as.double(rating)
  )

madden_16 <- read_excel(madden_16_path) %>% 
  rename("team" = "Team", "first_name" = "First Name", "last_name" = "Last Name", "position" = "Position", "number" = "Jersey Number", "rating" = "OVR") %>% 
  select(team, first_name, last_name, number, position, rating) %>% 
  mutate(
    season = 2015,
    rating = as.double(rating),
    number = as.double(number)
  )

madden_17 <- read_excel(madden_17_path) %>% 
  rename("team" = "Team", "first_name" = "First Name", "last_name" = "Last Name", "position" = "Position", 
         "rating" = "Overall") %>% 
  select(team, first_name, last_name, position, rating) %>% 
  mutate(
    season = 2016,
    rating = as.double(rating)
  )

madden_18 <- read_excel(madden_18_path) %>% 
  rename("team" = "Team", "first_name" = "First Name", "last_name" = "Last Name", "position" = "Position", 
         "number" = "Jersey Number", "rating" = "Overall") %>% 
  select(team, first_name, last_name, number, position, rating) %>% 
  mutate(
    season = 2017,
    rating = as.double(rating)
  )

madden_19 <- read_excel(madden_19_path) %>% 
  extract(Name, c("first_name", "last_name"), "([^ ]+) (.*)") %>% 
  rename("team" = "Team", "position" = "Position", 
         "number" = "Jersey #", "rating" = "Overall") %>% 
  select(team, first_name, last_name, number, position, rating) %>% 
  mutate(
    season = 2018,
    rating = as.double(rating)
  )

madden_20 <- read_csv(madden_20_path) %>% 
  filter(is.na(`AFC Pro Bowl Team`)) %>% 
  extract(Name, c("first_name", "last_name"), "([^ ]+) (.*)") %>% 
  rename("team" = "Team", "position" = "Position", 
         "number" = "Jersey", "rating" = "Overall") %>% 
  select(team, first_name, last_name, number, position, rating) %>% 
  mutate(
    season = 2019,
    rating = as.double(rating)
  )

madden_21 <- read_csv(madden_21_path) %>% 
  filter(is.na(`AFC Pro Bowl Team`)) %>% 
  extract(`Full Name`, c("first_name", "last_name"), "([^ ]+) (.*)") %>% 
  rename("team" = "Team", "position" = "Position", 
         "number" = "Jersey Number", "rating" = "Overall Rating") %>% 
  select(team, first_name, last_name, number, position, rating) %>% 
  mutate(
    season = 2020,
    rating = as.double(rating)
  )

teams <- load_teams() %>% 
  union_all(tibble(team_abbr = c("FRA"), team_name = c("Free Agents")))

madden <- madden_05 %>% 
  union_all(madden_06) %>% 
  union_all(madden_07) %>% 
  union_all(madden_08) %>% 
  union_all(madden_09) %>% 
  union_all(madden_10) %>% 
  union_all(madden_11) %>% 
  union_all(madden_12) %>% 
  union_all(madden_13) %>%
  union_all(madden_14) %>%
  union_all(madden_15) %>% 
  union_all(madden_16) %>% 
  union_all(madden_17) %>% 
  union_all(madden_18) %>% 
  union_all(madden_19) %>% 
  union_all(madden_20) %>% 
  union_all(madden_21) %>% 
  mutate(
    parsed_team = str_extract(parsed_team, "[/\\\\][a-z_\\.0-9]*_\\(?madden"),
    parsed_team = str_replace(parsed_team, "[/\\\\]", ""),
    parsed_team = str_replace(parsed_team, "_\\(?madden", ""),
    parsed_team = str_replace_all(parsed_team, "_+", " "),
    parsed_team = str_to_title(parsed_team), 
    team = if_else(is.na(team), parsed_team, team),
    team = str_trim(team), 
    team = if_else(team == "Washington Redskins" | team == "Redskins", "Washington Commanders", team),
    team = if_else(team == "Jacksonville Jagaurs", "Jacksonville Jaguars", team),
    team = if_else(team == "Bucs", "Buccaneers", team)
  ) %>% 
  full_join(
    teams, 
    by = character()
  ) %>% 
  filter((team == team_name) | str_detect(team_name, team)) %>% 
  filter(! (((team == "Raiders") & (season < 2020))& (team_name == "Las Vegas Raiders"))) %>% 
  filter(! (((team == "Raiders") & (season >= 2020))& (team_name == "Oakland Raiders"))) %>% 
  filter(! (((team == "Rams") & (season < 2016))& (team_name == "Los Angeles Rams"))) %>%
  filter(! (((team == "Rams") & (season >= 2016))& (team_name == "St. Louis Rams"))) %>%
  filter(! (((team == "Chargers") & (season < 2017))& (team_name == "Los Angeles Chargers"))) %>%
  filter(! (((team == "Chargers") & (season >= 2017))& (team_name == "San Diego Chargers"))) %>%
  rename(c("jersey_number" = "number")) %>% 
  select(season, team_name, team_abbr, team_id, jersey_number, first_name, last_name, position, rating)

madden_data_path <- file.path("..","..","data", "processed_data", "madden_overall_rating.csv")

write_csv(madden, madden_data_path)