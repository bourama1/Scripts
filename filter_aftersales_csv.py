import csv
import sys

INPUT_FILE  = 'katalog_sklady.csv'
OUTPUT_FILE = 'sklady-polozky.csv'
DELIMITER   = ';'

def main():
    # 1) Read in, skipping the header
    with open(INPUT_FILE, newline='', encoding='utf-8') as f:
        reader = csv.reader(f, delimiter=DELIMITER)
        try:
            next(reader)  # toss the header row
        except StopIteration:
            print("Input file is empty!", file=sys.stderr)
            sys.exit(1)
        data = list(reader)

    if not data:
        print("No data rows found after header.", file=sys.stderr)
        sys.exit(1)

    # 2) Grab the default value from the first data row’s 2nd column
    default_val = data[0][1]

    # 3) Filter out any row whose 2nd column == default_val
    filtered = [row for row in data if row[1] != default_val]

    # 4) Write output: first line is "DEFAULT;<default_val>", then the filtered rows
    with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f, delimiter=DELIMITER)
        writer.writerow(['DEFAULT', default_val])
        writer.writerows(filtered)

    print(f"Wrote {len(filtered)} rows (default={default_val}) to {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
