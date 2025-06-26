# Skripty

## PowerShell

### `extract_filenames_excel.ps1`

#### Popis

Skript extract_filenames_excel.ps1 prohledá soubory ve specifikované složce, filtruje je na základě uživatelem zadaných klíčových slov, a pro každý soubor, který splňuje kritéria, nahradí předponu "DW_" v názvu souboru předponou Delka_. Výsledkem je seznam názvů souborů a jejich nových názvů, který skript uloží do Excel souboru (nazvyCharakteristik.xlsx) v aktuálním pracovním adresáři.

#### Použití

1. Zadejte cestu ke složce: Skript se zeptá na cestu k složce, kterou chcete prohledat. Ujistěte se, že složka existuje.

2. Zadejte klíčová slova pro filtraci: Skript umožňuje zadat klíčová slova, která budou použita k filtrování názvů souborů. Po zadání všech slov stiskněte Enter pro ukončení zadávání.

3. Výstup: Skript vytvoří Excel soubor file_names.xlsx v aktuálním pracovním adresáři, který obsahuje původní názvy souborů a jejich nové názvy s odpovídajícími předponami.

4. Po dokončení: Skript automaticky otevře vygenerovaný Excel soubor.

### `extract_filenames.ps1`

#### Popis

Skript `extractFilenames.ps1` prohledá všechny soubory ve specifikované složce, nahradí předponu `DW_` v názvech souborů předponou `Delka_` a vytvoří seznam názvů souborů spolu s jejich novými názvy na základě zadaných filtrů. Skript zapisuje výsledky do textového souboru v aktuálním pracovním adresáři.

#### Použití

1. **Zadejte cestu ke složce**: Skript se zeptá na cestu ke složce, kterou chcete prohledat. Ujistěte se, že složka existuje.

2. **Zadejte slova pro filtraci**: Skript umožňuje zadat slova, která mají být použita k filtrování názvů souborů. Po zadání všech slov stiskněte Enter pro ukončení zadávání.

3. **Výstup**: Skript vytvoří textový soubor `nazvyCharakteristik.txt` v aktuálním pracovním adresáři, který obsahuje původní názvy souborů a jejich nové názvy s odpovídajícími předponami.

#### Ukazka

![extractFilenames.ps1](https://github.com/user-attachments/assets/d804d2aa-5e39-4736-8b7c-a0e16472f007)

### `find_csv.ps1`

Tento PowerShell skript slouží k prohledání všech CSV souborů ve vybraném adresáři a výpisu jejich cest, přičemž soubory jsou seřazeny podle času poslední změny (od nejnovějších po nejstarší). Skript vylučuje soubory, jejichž název končí na "ND" (bez ohledu na velikost písmen). Po zpracování prvních 50 souborů skript ukončí běh.

#### Popis

- Prochází všechny CSV soubory ve vybraném adresáři.
- Seřadí je podle času poslední změny (novější soubory jsou na začátku).
- Ověří, zda název souboru neobsahuje příponu "ND" (není závislé na velikosti písmen).
- Vypíše cestu k souboru pro každé soubory, které splňují podmínky.
- Po nalezení 50 souborů skript ukončí provádění.

#### Použití

1. Skript je určen pro procházení souborů ve složce, kde jsou uloženy CSV soubory.
2. Skript postupně vypíše cesty k souborům (až do 50 souborů), které neobsahují "ND" v názvu.

### `find_excel_with_text.ps1`

#### Popis

Skript find_excel_with_text.ps1 prohledává všechny Excel soubory (*.xls*) v zadané složce a vyhledává specifikovaný text v každém souboru. Pokud je text nalezen v libovolné buňce na jakémkoliv listu, přidá název souboru do seznamu a pokračuje v prohledávání dalších souborů. Na konci skript vypíše seznam souborů, které obsahují hledaný text.

#### Použití

1. Nastavte složku: Skript začíná definováním cesty k adresáři, ve kterém budou prohledávány Excel soubory. Cesta k adresáři je nastavena proměnnou $directory.

2. Zadejte hledaný text: Skript hledá text specifikovaný v proměnné $searchText. Tento text bude vyhledáván v obsahu všech listů a buněk každého Excel souboru.

3. Prohledávání souborů: Skript otevře každý Excel soubor v dané složce v režimu pouze pro čtení, prohledá všechny listy a hledá zadaný text.

4. Výsledek: Pokud skript najde soubor obsahující hledaný text, přidá název souboru do seznamu a na konci vypíše seznam souborů, které text obsahují.

5. Po dokončení: Skript ukončí Excel a vypíše výsledky na obrazovku.

### `make_shortcut.ps1`

#### Popis

Skript make_shortcut.ps1 slouží k vytvoření zástupce (shortcut) pro specifikovaný PowerShell skript. Tento skript automatizuje proces vytváření zástupce, který umožňuje snadné spuštění PowerShell skriptu s předem definovanými parametry. Zástupce bude obsahovat cestu k PowerShellu, argumenty pro spuštění skriptu a volitelně možnost spuštění jako správce.

#### Použití

Zadejte cestu ke skriptu: Skript se zeptá na cestu k PowerShell skriptu, pro který chcete vytvořit zástupce. Ujistěte se, že skript existuje.

Vytvoření zástupce: Skript vytvoří zástupce ve formátu .lnk ve stejném adresáři, kde je uložen PowerShell skript, nebo na ploše, pokud upravíte cestu k výstupu.

Výsledek: Zástupce bude obsahovat cestu k powershell.exe a parametry pro spuštění PowerShell skriptu. Pokud chcete, můžete upravit ikonu zástupce nebo přidat další možnosti, jako například spuštění jako správce.

#### Ukázka použití

Pokud máte PowerShell skript s názvem example.ps1 a chcete pro něj vytvořit zástupce, spusťte:

```powershell
.\make_shortcut.ps1 "C:\cesta\k\example.ps1"
```

Tento příkaz vytvoří zástupce pro skript v aktuálním adresáři. Sentinel pravdepodobne smaže.

### `pdm_file_transfer.ps1`

#### Popis

Skript pdm_file_transfer.ps1 je navržen pro automatizaci přesunu a kopírování souborů dle specifikované struktury verzování. Prochází všechny soubory ve složce Import_PDM a pro každý soubor:

Identifikuje revizi: Extrahuje číslo revize ze souboru, například z názvu T09-060-10-0098_Rev1.eprt.

Vytvoří cílovou adresářovou strukturu: Na základě "common part" názvu (část názvu před _Rev) a segmentace pomocí pomlček se vytvoří adresářová struktura pod kořenovým adresářem.

Porovná revize a typ souboru: Při kontrole existujících souborů v cílové složce skript identifikuje soubory se stejnou společnou částí a příponou. Pokud existující soubor má revizi menší nebo rovnou aktuální, je přesunut do podsložky OLD.

Přesune aktuální soubor: Po případném přesunu starších verzí je aktuální soubor přesunut do cílové složky.

Skript obsahuje rozsáhlé výpisy do konzole, které usnadňují sledování průběhu operací a debugování.

Logování: Veškeré podrobné výpisy o průběhu operací (zpracovávané soubory, vytvářené adresáře, přesouvané soubory, chyby) jsou nyní zaznamenávány do souboru log.txt, který se vytváří (a při každém spuštění přepisuje) ve stejném adresáři, kde je umístěn samotný skript pdm_file_transfer.ps1.

#### Použití

1. Zadejte zdrojovou složku: Ujistěte se, že cesta ke složce s názvem Import_PDM je správně nastavena. (součást kódu, druhý řádek)

2. Zadejte cílový kořenový adresář: Cesta, kam bude vytvářena cílová adresářová struktura. (součást kódu, třetí řádek)

3. Spuštění skriptu: Skript zpracuje všechny soubory v Import_PDM, vytvoří potřebnou strukturu, přesune starší či shodné verze do složky OLD a zkopíruje aktuální soubory na správná místa.

### `rename_prefix.ps1`

#### SolidWorks

**Use Pack&Go feature from SolidWorks, there is option to add prefix or postfix to whole package with all changes needed for SW.**

#### Popis

Skript `renamePrefix.ps1` slouží k přidání specifikované předpony ke všem souborům v zadané složce a jejích podadresářích. Skript přidá předponu pouze k těm souborům, které ji ještě nemají. Skript je užitečný pro hromadné přejmenování souborů podle zadaného vzoru.

#### Použití

1. **Zadejte cestu ke složce**: Skript se zeptá na cestu k cílové složce, kterou chcete prohledat. Ujistěte se, že zadaná složka existuje.
2. **Zadejte předponu**: Skript se dále zeptá na předponu, kterou chcete přidat k názvům souborů. Předpona bude přidána pouze k souborům, které ji ještě neobsahují.
3. **Rekurzivní přejmenování**: Skript prohledá zadanou složku i všechny její podadresáře a přidá předponu ke všem odpovídajícím souborům.

### `start_excel.ps1`

#### Popis

Skript RunTwoExcelInstances.ps1 spouští dvě oddělené instance aplikace Microsoft Excel:

1. Instance s aktivním doplňkem – automaticky načte a aktivuje zadaný Add-in (např. OPCEx3) a otevře definovaný sešit.
2. Instance bez aktivního doplňku – spustí čistou instanci Excelu, deaktivuje (pokud je načten) stejný Add-in a otevře jiný určený sešit.

Tento přístup je užitečný, pokud potřebujete současně pracovat se sešity, u kterých mají doplňky různá nastavení nebo pokud testujete chování sešitů bez načteného doplňku.

#### Konfigurace

Na začátku skriptu upravte tyto proměnné podle svých potřeb:

- $addinNameNázev doplňku přesně tak, jak se zobrazuje v Excelu (např. "OPCEx3").
- $addinPathÚplná cesta k souboru doplňku (.xla, .xlam apod.), např. D:\temp\OPCEx3.xla.
- $workbookWithAddinCesta k Excel sešitu, který chcete otevřít v instanci s aktivním doplňkem.
- $workbookWithoutAddinCesta k Excel sešitu, který chcete otevřít v instanci bez doplňku.

## Python

### filter_aftersales_csv.py

#### Popis

Skript sklady_polozky.py je navržen pro zpracování CSV souboru katalog_sklady.csv, ve kterém se:

1. Načtou data
    - Otevře se vstupní soubor (implicitně katalog_sklady.csv) s kódováním UTF-8 a oddělovačem ;.
    - První řádek je hlavička a je přeskočen; pokud soubor neobsahuje ani hlavičku, skript hlásí chybu a končí.
    - Ostatní řádky se uloží do seznamu data.
2. Určí výchozí hodnotu
    - Z prvního datového řádku (tj. druhé řádky souboru) se z druhého sloupce přečte tzv. default_val.
3. Filtrace řádků
    - Z pole data se odfiltrují všechny řádky, jejichž druhý sloupec je roven default_val.
    - Používá se list-comprehension pro rychlé porovnání každého řádku.
4. Zápis výstupu
    - Do nového souboru (implicitně sklady-polozky.csv) se nejprve zapíše hlavička ve formátu: ***DEFAULT;100***
    - Následně se do výstupního CSV zapíší všechny zbývající řádky.
    - Po úspěšném zápisu skript na konzoli vypíše počet zapsaných řádků a hodnotu default_val.
