import os
import argparse
import requests
import pandas as pd
from bs4 import BeautifulSoup
from tqdm import tqdm
from datetime import datetime


def parse_and_download(url, domain, dir):
    try:
        page = requests.get(url)
        page.raise_for_status()  # Raises stored HTTPError, if one occurred
    except requests.HTTPError:
        print(f'URL not found: {url}')
        return

    soup = BeautifulSoup(page.text, 'html.parser')

    # Find links
    links = soup.find_all('a', href=True)
    for link in tqdm(links):
        href = link['href']
        if href.endswith(('.xlsx', '.xls')):  # Download Excel files only
            file_name = (href.split('/')[-1]).split('.')[0]
            if file_name == "st":
                file_name = f"st.{(href.split('/')[-1]).split('.')[1]}"
            file_url = domain[:-1] + href

            # Check if the file already exists
            csv_path = os.path.join(dir, f"{file_name}.csv")
            if os.path.exists(csv_path):
                print(f"File already exists: {csv_path}. Skipping...")
                continue

            # Download and parse the Excel file
            try:
                data = pd.read_excel(file_url)
                data['parsed_team'] = file_name
            except Exception as e:
                print(f"Couldn't download or parse file: {file_name}. Error: {str(e)}")
                continue

            # Save the DataFrame to a csv file in the specified directory
            data.to_csv(csv_path, index=False)

def main(start_year, end_year):
    # Base URL
    domain = "https://maddenratings.weebly.com/"

    # URLs list
    url_list =  [domain + f"madden-nfl-20{str(i).zfill(2)}.html" for i in range(start_year, min(6, end_year + 1))] + \
                [domain + f"madden-nfl-{str(i).zfill(2)}.html" for i in range(max(6, start_year), end_year + 1)]

    if 14 in range(start_year, end_year + 1):
        url_list.append(domain + "madden-nfl-25.html")

    # Directory for saving data
    data_dir = "madden_data"
    os.makedirs(data_dir, exist_ok=True)

    # Parse and download for each URL
    for idx, url in enumerate(url_list):
        sub_dir = os.path.join(data_dir, str(start_year + idx).zfill(2))
        os.makedirs(sub_dir, exist_ok=True)
        parse_and_download(url, domain, sub_dir)

if __name__ == "__main__":
    current_year = datetime.now().year % 100 + 1

    parser = argparse.ArgumentParser(description="Download Madden ratings data for a given range of years.")
    parser.add_argument("--from", dest="from_year", type=int, default=2, help="The start year (inclusive).")
    parser.add_argument("--to", dest="to_year", type=int, default=current_year, help="The end year (inclusive).")

    args = parser.parse_args()

    # Validate and correct years if needed
    if args.from_year < 2:
        print("Years before 2002 are not supported, setting to default (02)")
        args.from_year = 2
    if args.to_year > current_year:
        print(f"Year is not supported, setting to default ({current_year + 1})")
        args.to_year = current_year

    main(args.from_year, args.to_year)


