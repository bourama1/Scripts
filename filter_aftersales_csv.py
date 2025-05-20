import csv
import sys

INPUT_FILE = 'katalog_sklady.csv'
OUTPUT_FILE = 'sklady-polozky.csv'
DELIMITER = ';'

def is_number(value):
    """Checks if a value can be converted to a float."""
    if value is None or value.strip() == '': # Handle None or empty strings
        return False
    try:
        float(value)
        return True
    except ValueError:
        return False

def main():
    # 1) Read in, skipping the header
    try:
        with open(INPUT_FILE, newline='', encoding='utf-8') as f:
            reader = csv.reader(f, delimiter=DELIMITER)
            try:
                next(reader)  # toss the header row
            except StopIteration:
                print("Input file is empty!", file=sys.stderr)
                sys.exit(1)
            data = list(reader)
    except FileNotFoundError:
        print(f"Error: Input file '{INPUT_FILE}' not found.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error reading file '{INPUT_FILE}': {e}", file=sys.stderr)
        sys.exit(1)

    if not data:
        print("No data rows found after header.", file=sys.stderr)
        sys.exit(1)

    # 2) Set the default value to 100
    default_val = '100' # Hardcoded default value as a string to match CSV content

    # 3) Filter out any row whose 2nd column == default_val (100) OR is not a valid number
    filtered = []
    for i, row in enumerate(data):
        # Ensure the row has at least 2 columns before accessing index 1
        if len(row) < 2:
            print(f"Warning: Skipping row {i+2} (after header) with insufficient columns: {row}", file=sys.stderr)
            continue

        second_col_val = row[1]

        # Check if the second column is NOT the default value (100) AND is a valid number
        if second_col_val != default_val and is_number(second_col_val):
            filtered.append(row)


    # 4) Write output: first line is "DEFAULT;<default_val>", then the filtered rows
    try:
        with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f, delimiter=DELIMITER)
            writer.writerow(['DEFAULT', default_val]) # Write the hardcoded default value
            writer.writerows(filtered)
    except Exception as e:
        print(f"Error writing to file '{OUTPUT_FILE}': {e}", file=sys.stderr)
        sys.exit(1)


    print(f"Wrote {len(filtered)} rows (default={default_val}) to {OUTPUT_FILE}")

if __name__ == '__main__':
    main()