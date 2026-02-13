import csv
import re

import requests
from bs4 import BeautifulSoup

# The URL you provided
URL = "https://wzornikonline.pl/kolory-z-nazwami/"

def scrape_ral_colors():
    # Language abbreviations as headers
    headers = ['RAL', 'pl', 'en', 'de', 'nl', 'fr', 'it', 'es', 'lt']

    # Headers to bypass the 403 Forbidden error
    browser_headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
    }

    rows_data = []

    try:
        print(f"Connecting to {URL}...")
        response = requests.get(URL, headers=browser_headers)
        response.raise_for_status() # This will catch errors like 404 or 403

        soup = BeautifulSoup(response.content, 'html.parser')

        # Target the specific table cells using the class from your HTML snippet
        cells = soup.find_all('td', class_='colors')

        print(f"Found {len(cells)} color entries. Processing...")

        for cell in cells:
            # 1. Get raw text and handle the bold <b> tag which contains RAL + Polish
            # We use a pipe '|' as a temporary delimiter
            raw_text = cell.get_text(separator="|", strip=True)

            # 2. Clean up weird separators like ';;' or '/'
            # and split into parts
            clean_text = raw_text.replace(";;", "|").replace("/", "|")
            parts = [p.strip() for p in clean_text.split('|') if p.strip()]

            if not parts:
                continue

            # 3. Separate RAL Code from the first chunk (e.g., "RAL 1000 Beżowo zielony")
            first_chunk = parts[0]
            ral_match = re.search(r'(RAL\s*\d{4})', first_chunk)

            if ral_match:
                ral_code = ral_match.group(1)
                # Polish name is whatever is left in that first chunk
                pl_name = first_chunk.replace(ral_code, "").strip()

                # Build the row: [RAL, PL, EN, DE, NL, FR, IT, ES, LT]
                current_row = [ral_code, pl_name]

                # Add subsequent languages found in 'parts'
                # parts[1:] contains English onwards
                current_row.extend(parts[1:])

                # Normalizing the row length to 9 columns
                if len(current_row) < len(headers):
                    current_row += [""] * (len(headers) - len(current_row))
                else:
                    current_row = current_row[:len(headers)]

                rows_data.append(current_row)

        # Write to CSV
        filename = 'ral_colors_full.csv'
        with open(filename, 'w', newline='', encoding='utf-8-sig') as f:
            writer = csv.writer(f)
            writer.writerow(headers)
            writer.writerows(rows_data)

        print(f"Success! File saved as '{filename}'")

    except requests.exceptions.HTTPError as err:
        print(f"HTTP Error: {err}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    scrape_ral_colors()