import pandas as pd
from typing import List
import os
import re
import fnmatch


EXCLUDED_FILES = ["*free_agent*", "*madden_elites*", "*roster_update*", "*all-25*", "*full_player_ratings.csv*", "*pro_bowl*", "*madden_legends*", 
                  "*rookie*", "*final_ratings.csv*", "*canton_greats*", "*madden_nfl_23_player_ratings*", "*nfl_19_-_full_player_ratings*"]

ATTR_MAP = {
    "team": ["team"],
    "position": ["position", "pos"],
    "overall_rating": ["overall", "ovr"],
    "awareness": ["awareness"],
    "speed": ["speed"],
    "acceleration": ["acceleration", "accleration"],
    "agility": ["agility"],
    "jumping": ["jumping"],
    "strength": ["strength", "stength"],
    "throw_power": ["throw_power", "throwpower"],
    "throw_accuracy_short": ["throw_accuracy_short", "short_throw_accuracy", "throwaccuracyshortrating", "short_accuracy"],
    "throw_accuracy_middle": ["throw_accuracy_middle", "medium_throw_accuracy", "throw_accuracy_medium","throw_accuracy_mid", "throw_accuracy_med", 
                                "throwaccuracymidrating", "middle_accuracy"],
    "throw_accuracy_deep": ["throw_accuracy_deep", "deep_throw_accuracy", "throwaccuracydeeprating", "deep_throw_accruacy", "deep_accuracy"],
    "throw_accuracy": ["throw_accuracy", "throwaccuracy"],
    "throw_under_pressure": ["throw_under_pressure", "throwunderpressurerating"],
    "throw_on_the_run": ["throw_on_the_run", "throw_on_run", "throwontherunrating"],
    "ball_carrier_vision": ["ball_carrier_vision", "bcvision", "bc_vision"],
    "play_action": ["play_action", "playaction"],
    "toughness": ["toughness"],
    "carrying": ["carrying"],
    "elusiveness": ["elusiveness"],
    "break_tackle": ["break_tackle", "breaktackle"],
    "trucking": ["trucking"],
    "spin_move": ["spin_move", "spinmove"],
    "juke_move": ["juke_move", "jukemove"],
    "break_sack": ["break_sack", "breaksack"],
    "stiff_arm": ["stiff_arm", "stiffarm"],
    "catching": ["catching"],
    "catch_in_traffic": ["catch_in_traffic", "catchintraffic"],
    "short_route_running": ["short_route_running", "shortrouterunningrating", "short_route_runing"],
    "medium_route_running": ["medium_route_running", "mediumrouterunningrating"],
    "deep_route_running": ["deep_route_running", "deeprouterunningrating"],
    "route_running": ["route_running", "routerunning"],
    "spectacular_catch": ["spectacular_catch", "spectacularcatch"],
    "impact_blocking": ["impact_blocking", "impactblocking", "impact_block"],
    "lead_blocking": ["lead_blocking", "leadblocking", "lead_block"],
    "run_block_power": ["run_block_power", "runblockpower"],
    "pass_block_power": ["pass_block_power", "passblockpower"],
    "play_recognition": ["play_recognition", "playrecognition"],
    "power_moves": ["power_moves", "powermoves"],
    "pass_block_finesse": ["pass_block_finesse", "passblockfinesse"],
    "run_block_finesse": ["run_block_finesse", "runblockfinesse"],
    "run_block_strength": ["run_block_strength", "runblock_strength", "runblockstrength"],
    "run_block_footwork": ["run_block_footwork", "runblock_footwork", "runblockfootwork"],
    "pass_block_strength": ["pass_block_strength", "passblock_strength", "passblockstrength"],
    "pass_block_footwork": ["pass_block_footwork", "passblock_footwork", "passblockfootwork"],
    "run_block": ["run_block", "runblock"],
    "pass_block": ["pass_block", "passblock"],
    "release": ["release"],
    "hit_power": ["hit_power", "hitpower"],
    "finessee_move": ["finessee_move", "finesseemove", "finessee_moves", "finessemoves"],
    "block_shedding": ["block_shedding", "blockshedding"],
    "man_coverage": ["man_coverage", "mancoverage", "man_cover"],
    "zone_coverage": ["zone_coverage", "zonecoverage", "zone_cover"],
    "press": ["press"],
    "kick_power": ["kick_power", "kickpower"],
    "kick_accuracy": ["kick_accuracy", "kickaccuracy"],
    "kick_return": ["kick_return", "kickreturn", "return"],
    "stamina": ["stamina"],
    "injury": ["injury"],
    "player_handedness": ["player_handedness"],
    "running_style": ["running_style", "runningstyle"],
    "archetype": ["archetype"],
    "first_name": ["first"],
    "last_name": ["last"],
    "full_name": ["full_name", "fullname", "name"],
    "tackle": ["tackle"],
    "catching": ["catching"],
    "carrying": ["carrying"],
    "pursuit": ["pursuit"],
    "madden": ["madden"], 
    "salary": ["salary", "total_salary"], 
    "height": ["height"],
    "morale": ["morale"], 
    "weight": ["weight"],
    "jersey_number": ["jersey", "number"],
    "age": ["age"],
    "parsed_team": ["parsed_team"]
}

ATTR_ORDER = ["madden", "team", "parsed_team", "first_name", "last_name", "full_name", "position", "jersey_number", "salary", "age", "weight", "height", 
              "overall_rating", "awareness", "speed", "acceleration", "agility", "jumping", "strength", "throw_power", "throw_accuracy_short",
              "throw_accuracy_middle", "throw_accuracy_deep", "throw_accuracy", "throw_under_pressure", "throw_on_the_run", "ball_carrier_vision",
              "play_action", "toughness", "carrying", "elusiveness", "break_tackle", "trucking", "spin_move", "juke_move", "break_sack", "stiff_arm",
              "catching", "catch_in_traffic", "short_route_running", "medium_route_running", "deep_route_running", "route_running", "spectacular_catch",
              "impact_blocking", "lead_blocking", "run_block_power", "pass_block_power", "play_recognition", "power_moves", "pass_block_finesse", 
              "run_block_finesse", "run_block_strength", "run_block_footwork", "pass_block_strength", "pass_block_footwork", "run_block", "pass_block",
              "release", "hit_power", "finessee_move", "block_shedding", "man_coverage", "zone_coverage", "press", "kick_power", "kick_accuracy",
              "kick_return", "stamina", "injury", "player_handedness", "running_style", "archetype", "tackle", "catching", "carrying", "pursuit",
              "morale"]


def unify_attr_name(name: str) -> str:
    name = name.lower()

    for splitter in [" ", "-", "_"]:
        name = name.replace(splitter, "_")
    
    if name.endswith("_rating"):
        name = name[:-7]
    if name.startswith("plyr_"):
        name = name[5:]

    for unified_name, variants in ATTR_MAP.items():
        if any(name.startswith(variant) for variant in variants):
            return unified_name
    return name


def unify_csv(path: str) -> pd.DataFrame:
    df = pd.read_csv(path)
    df['parsed_team'] = df['parsed_team'].apply(lambda x: re.split('__madden|_\(madden|_madden', str(x))[0])
    df.columns = [unify_attr_name(name) for name in df.columns]
    if df.columns.duplicated().any():
        print(f"Warning: Duplicate columns found after unification in file {path}. Taking first occurrence.")
        df = df.loc[:, ~df.columns.duplicated(keep='first')]
    df = df.reindex(columns=ATTR_MAP.keys())
    return df

def combine_csv_files(file_paths: List[str]) -> pd.DataFrame:
    if len(file_paths) == 0:
        return None
    dfs = [unify_csv(path) for path in file_paths]
    combined_df = pd.concat(dfs, ignore_index=True, sort=False)
    combined_df = combined_df.reindex(columns=ATTR_MAP.keys())
    return combined_df

def get_team_rating_paths(folder_path: str) -> pd.DataFrame:
    team_rating_paths = []
    for root, _, files in os.walk(folder_path):
        for file in files:
            if file.endswith(".csv") and not any(fnmatch.fnmatch(file, pattern) for pattern in EXCLUDED_FILES):
                team_rating_paths.append(os.path.join(root, file))
    return team_rating_paths

def combine_madden_data(root_folder: str) -> pd.DataFrame:
    dfs = []
    for madden in os.listdir(root_folder):
        folder_path = os.path.join(root_folder, madden)
        if os.path.isdir(folder_path):
            team_rating_paths = get_team_rating_paths(folder_path)
            df = combine_csv_files(team_rating_paths)
            if df is not None:
                df['madden'] = int(madden)
                dfs.append(df)

    if len(dfs) == 0:
        print(f"No .csv files found in any subfolder of {root_folder}")
        return None

    combined_df = pd.concat(dfs, ignore_index=True, sort=False)
    return combined_df

if __name__ == "__main__":
    final_df = combine_madden_data(root_folder='madden_data')
    final_df = final_df[ATTR_ORDER].sort_values(by=["madden", "team", "parsed_team", "jersey_number"])
    final_df = final_df.dropna(thresh=3)
    condition = ~((final_df['full_name'] == 'Name') & (final_df['position'] == 'Position'))
    final_df = final_df[condition]
    os.makedirs("processed_data", exist_ok=True)
    final_df.to_csv('processed_data/combined_madden_ratings.csv', index=False)
