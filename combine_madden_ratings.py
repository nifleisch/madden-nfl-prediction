import pandas as pd
from typing import List
import os

# A mapping dictionary for harmonizing attribute names
ATTR_MAP = {
    "team": ["team"],
    "position": ["position", "pos"],
    "overall_rating": ["overall", "ovr"],
    "jersey_number": ["jersey"],
    "awareness": ["awareness"],
    "speed": ["speed"],
    "acceleration": ["acceleration"],
    "agility": ["agility"],
    "jumping": ["jumping"],
    "strength": ["strength"],
    "throw_power": ["throw_power", "throwpower"],
    "throw_accuracy_short": ["throw_accuracy_short", "short_throw_accuracy"],
    "throw_accuracy_middle": ["throw_accuracy_middle", "medium_throw_accuracy", "throw_accuracy_medium","throw_accuracy_mid", "throw_accuracy_med"],
    "throw_accuracy_deep": ["throw_accuracy_deep", "deep_throw_accuracy"],
    "throw_accuracy": ["throw_accuracy"],
    "throw_under_pressure": ["throw_under_pressure"],
    "throw_on_the_run": ["throw_on_the_run"],
    "ball_carrier_vision": ["ball_carrier_vision", "bcvision"],
    "play_action": ["play_action"],
    "toughness": ["toughness"],
    "carrying": ["carrying"],
    "break_tackle": ["break_tackle", "breaktackle"],
    "trucking": ["trucking"],
    "spin_move": ["spin_move", "spinmove"],
    "juke_move": ["juke_move", "jukemove"],
    "break_sack": ["break_sack", "breaksack"],
    "stiff_arm": ["stiff_arm", "stiffarm"],
    "catching": ["catching"],
    "catch_in_traffic": ["catch_in_traffic", "catchintraffic"],
    "short_route_running": ["short_route_running"],
    "medium_route_running": ["medium_route_running"],
    "deep_route_running": ["deep_route_running"],
    "spectacular_catch": ["spectacular_catch", "spectacularcatch"],
    "impact_blocking": ["impact_blocking", "impactblocking"],
    "lead_blocking": ["lead_blocking", "leadblocking"],
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
    "block_shedding": ["block_shedding", "blockshedding"],
    "man_coverage": ["man_coverage", "mancoverage"],
    "zone_coverage": ["zone_coverage", "zonecoverage"],
    "press": ["press"],
    "kick_power": ["kick_power", "kickpower"],
    "kick_accuracy": ["kick_accuracy", "kickaccuracy"],
    "kick_return": ["kick_return", "kickreturn"],
    "stamina": ["stamina"],
    "injury": ["injury"],
    "player_handedness": ["player_handedness"],
    "running_style": ["running_style", "runningstyle"],
    "archetype": ["archetype"],
    "first_name": ["first"],
    "last_name": ["last"],
    "tackle": ["tackle"],
    "catching": ["catching"],
    "carrying": ["carrying"],
    "pursuit": ["pursuit"],
    "parsed_team": ["parsed_team"]
}

def harmonize_attr_name(name: str) -> str:
    """
    Convert different attribute names to a unified form.
    """
    # Always work with lowercase
    name = name.lower()

    # Handle different splitting methods
    for splitter in [" ", "-", "_"]:
        name = name.replace(splitter, "_")
    
    # Handle the word "rating" at the ending and "plyr"/"player" at the beginning
    if name.endswith("_rating"):
        name = name[:-7]
    if name.startswith("plyr_"):
        name = name[5:]

    for unified_name, variants in ATTR_MAP.items():
        if any(name.startswith(variant) for variant in variants):
            return unified_name

    return name

import os
import fnmatch
import pandas as pd
from typing import List

EXCLUDED_FILES = ["*free_agent*", "*roster_update*", "*all-25*", "*full_player_ratings.csv*", "*pro_bowl*", "*madden_legends*", "*rookie*", "*final_ratings.csv*"]

def read_and_harmonize_csv(path: str) -> pd.DataFrame:
    """
    Read a .csv file into a DataFrame and harmonize its attribute names.
    """
    df = pd.read_csv(path)
    df.columns = [harmonize_attr_name(name.lower()) for name in df.columns]

    # Handle potential duplicates in harmonized column names
    if df.columns.duplicated().any():
        print(f"Warning: Duplicate columns found after harmonization in file {path}. Taking first occurrence.")
        df = df.loc[:, ~df.columns.duplicated(keep='first')]

    df = df.reindex(columns=ATTR_MAP.keys())
    return df

def get_duplicate_columns(df):
    duplicate_columns = []
    seen_columns = set()

    for column in df.columns:
        if column in seen_columns:
            duplicate_columns.append(column)
        else:
            seen_columns.add(column)

    return duplicate_columns

def combine_csv_files(file_paths: List[str]) -> pd.DataFrame:
    """
    Combine multiple .csv files with similar but not identical attributes into a single DataFrame.
    """

    dfs = [read_and_harmonize_csv(path) for path in file_paths]
    combined_df = pd.concat(dfs, ignore_index=True, sort=False)
    combined_df = combined_df.reindex(columns=ATTR_MAP.keys())
    return combined_df

def combine_csv_files_in_folder(folder_path: str) -> pd.DataFrame:
    """
    Combine .csv files in a folder and its subfolders into a single DataFrame, excluding certain files.
    """
    csv_file_paths = []
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.endswith(".csv") and not any(fnmatch.fnmatch(file, pattern) for pattern in EXCLUDED_FILES):
                csv_file_paths.append(os.path.join(root, file))

    if len(csv_file_paths) == 0:
        print(f"No .csv files found in folder {folder_path}")
        return None
    return combine_csv_files(csv_file_paths)

def combine_all_subfolders(root_folder: str) -> pd.DataFrame:
    """
    Combine .csv files in all subfolders of a root folder into a single DataFrame.
    """
    dfs = []
    for folder_name in os.listdir(root_folder):
        folder_path = os.path.join(root_folder, folder_name)
        if os.path.isdir(folder_path):
            df = combine_csv_files_in_folder(folder_path)
            if df is not None:
                dfs.append(df)

    if len(dfs) == 0:
        print(f"No .csv files found in any subfolder of {root_folder}")
        return None

    combined_df = pd.concat(dfs, ignore_index=True, sort=False)
    combined_df = combined_df.reindex(columns=ATTR_MAP.keys())
    return combined_df

if __name__ == "__main__":
    final_df = combine_all_subfolders('madden_data')
    os.makedirs("processed_data", exist_ok=True)
    final_df.to_csv('processed_data/combined_madden_ratings.csv', index=False)
