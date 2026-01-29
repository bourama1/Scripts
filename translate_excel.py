import html
import re
import shutil
import time

import deepl
import xlwings as xw

# --- CONFIGURATION ---
API_KEY = 'd781ca8f-eae0-4f92-83eb-ebf3110ad216:fx'
INPUT_FILE = r'D:\temp\Naceňování postranních panelů – TESTOVACÍ VERZE_EN.xlsx'
OUTPUT_FILE = r'D:\temp\Side_panels_pricing.xlsx'
TARGET_LANG = 'EN-US'

IGNORE_LIST = {"SL", "VL", "HL", "LL", "ASP", "FVE"}
CUSTOM_GLOSSARY_DICT = {"vedení": "rails"}

translator = deepl.Translator(API_KEY)

def apply_local_glossary(text):
    safe_text = html.escape(text)
    modified_text = safe_text
    for src, target in CUSTOM_GLOSSARY_DICT.items():
        pattern = re.compile(re.escape(html.escape(src)), re.IGNORECASE)
        modified_text = pattern.sub(f'<keep>{target}</keep>', modified_text)
    return modified_text

def translate_text(text):
    if not text or not isinstance(text, str) or text.strip() == "" or text.strip().isdigit():
        return text
    if text.strip() in IGNORE_LIST:
        return text

    protected_text = apply_local_glossary(text)
    for i in range(5):
        try:
            result = translator.translate_text(
                protected_text,
                target_lang=TARGET_LANG,
                tag_handling='xml',
                ignore_tags=['keep']
            )
            clean_text = result.text.replace('<keep>', '').replace('</keep>', '')
            return html.unescape(clean_text)
        except Exception:
            time.sleep(1)
    return text

def process_excel_with_xlwings():
    shutil.copy(INPUT_FILE, OUTPUT_FILE)

    app = xw.App(visible=False)
    try:
        wb = app.books.open(OUTPUT_FILE)

        # 1. Sheet Name Translation
        for sheet in wb.sheets:
            try:
                old_name = sheet.name
                new_name = translate_text(old_name)[:31]
                sheet.name = new_name
                print(f"Renamed: {old_name} -> {new_name}")
            except Exception as e:
                print(f"Skipping rename for {sheet.name}: {e}")

        # 2. Content Translation
        for sheet in wb.sheets:
            print(f"Processing content in: {sheet.name}")
            used_range = sheet.used_range

            # Read both values and formulas
            # values: gives us the text to translate
            # formulas: tells us what to skip
            vals = used_range.value
            forms = used_range.formula

            if vals is None:
                continue

            # Standardize to list of lists
            if not isinstance(vals, list):
                vals = [[vals]]
                forms = [[forms]]
            elif not isinstance(vals[0], list):
                vals = [[v] for v in vals]
                forms = [[f] for f in forms]
            else:
                vals = [list(row) for row in vals]
                forms = [list(row) for row in forms]

            # Translate only the text cells, leaving formulas and numbers alone
            for r in range(len(vals)):
                for c in range(len(vals[r])):
                    v = vals[r][c]
                    f = forms[r][c]

                    # Only translate if it's a string AND the formula version
                    # doesn't start with '=' (meaning it's pure text)
                    if isinstance(v, str) and isinstance(f, str) and not f.strip().startswith('='):
                        vals[r][c] = translate_text(v)
                    else:
                        # Keep the formula or number exactly as it was
                        vals[r][c] = f

            # 3. Safe Write Back
            try:
                # Try writing the whole block at once (fast)
                used_range.formula = vals
            except Exception as e:
                print(f"Block write failed in {sheet.name}, trying cell-by-cell... Error: {e}")
                # Fallback: Write cell-by-cell (slow but robust)
                for r in range(len(vals)):
                    for c in range(len(vals[r])):
                        try:
                            # offset(row, col) is 0-indexed in xlwings
                            used_range.cells(r+1, c+1).formula = vals[r][c]
                        except:  # noqa: E722
                            pass

        wb.save()
        print(f"\nSUCCESS! Translated file: {OUTPUT_FILE}")

    finally:
        app.quit()

if __name__ == "__main__":
    process_excel_with_xlwings()