# Skripty

## `extractFilenames.ps1`

### Popis

Skript `extractFilenames.ps1` prohledá všechny soubory ve specifikované složce, nahradí předponu `DW_` v názvech souborů předponou `Delka_` a vytvoří seznam názvů souborů spolu s jejich novými názvy na základě zadaných filtrů. Skript zapisuje výsledky do textového souboru v aktuálním pracovním adresáři.

### Použití

1. **Zadejte cestu ke složce**: Skript se zeptá na cestu ke složce, kterou chcete prohledat. Ujistěte se, že složka existuje.

2. **Zadejte slova pro filtraci**: Skript umožňuje zadat slova, která mají být použita k filtrování názvů souborů. Po zadání všech slov stiskněte Enter pro ukončení zadávání.

3. **Výstup**: Skript vytvoří textový soubor `nazvyCharakteristik.txt` v aktuálním pracovním adresáři, který obsahuje původní názvy souborů a jejich nové názvy s odpovídajícími předponami.

### Ukazka

![extractFilenames.ps1](https://github.com/user-attachments/assets/d804d2aa-5e39-4736-8b7c-a0e16472f007)

## `renamePrefix.ps1`

### SolidWorks

**Use Pack&Go feature from SolidWorks, there is option to add prefix or postfix to whole package with all changes needed for SW.**

### Popis

Skript `renamePrefix.ps1` slouží k přidání specifikované předpony ke všem souborům v zadané složce a jejích podadresářích. Skript přidá předponu pouze k těm souborům, které ji ještě nemají. Skript je užitečný pro hromadné přejmenování souborů podle zadaného vzoru.

### Použití

1. **Zadejte cestu ke složce**: Skript se zeptá na cestu k cílové složce, kterou chcete prohledat. Ujistěte se, že zadaná složka existuje.

2. **Zadejte předponu**: Skript se dále zeptá na předponu, kterou chcete přidat k názvům souborů. Předpona bude přidána pouze k souborům, které ji ještě neobsahují.

3. **Rekurzivní přejmenování**: Skript prohledá zadanou složku i všechny její podadresáře a přidá předponu ke všem odpovídajícím souborům.

## `pdm_file_transfer.ps1`

### Popis

Skript pdm_file_transfer.ps1 je navržen pro automatizaci přesunu a kopírování souborů dle specifikované struktury verzování. Prochází všechny soubory ve složce Import_PDM a pro každý soubor:

Identifikuje revizi: Extrahuje číslo revize ze souboru, například z názvu T09-060-10-0098_Rev1.eprt.

Vytvoří cílovou adresářovou strukturu: Na základě "common part" názvu (část názvu před _Rev) a segmentace pomocí pomlček se vytvoří adresářová struktura pod kořenovým adresářem.

Porovná revize a typ souboru: Při kontrole existujících souborů v cílové složce skript identifikuje soubory se stejnou společnou částí a příponou. Pokud existující soubor má revizi menší nebo rovnou aktuální, je přesunut do podsložky OLD.

Přesune aktuální soubor: Po případném přesunu starších verzí je aktuální soubor přesunut do cílové složky.

Skript obsahuje rozsáhlé výpisy do konzole, které usnadňují sledování průběhu operací a debugování.

### Použití

1. Zadejte zdrojovou složku: Ujistěte se, že cesta ke složce s názvem Import_PDM je správně nastavena. (součást kódu, druhý řádek)

2. Zadejte cílový kořenový adresář: Cesta, kam bude vytvářena cílová adresářová struktura. (součást kódu, třetí řádek)

3. Spuštění skriptu: Skript zpracuje všechny soubory v Import_PDM, vytvoří potřebnou strukturu, přesune starší či shodné verze do složky OLD a zkopíruje aktuální soubory na správná místa.

## `make_shortcut.ps1`

### Popis

Skript make_shortcut.ps1 slouží k vytvoření zástupce (shortcut) pro specifikovaný PowerShell skript. Tento skript automatizuje proces vytváření zástupce, který umožňuje snadné spuštění PowerShell skriptu s předem definovanými parametry. Zástupce bude obsahovat cestu k PowerShellu, argumenty pro spuštění skriptu a volitelně možnost spuštění jako správce.

### Použití

Zadejte cestu ke skriptu: Skript se zeptá na cestu k PowerShell skriptu, pro který chcete vytvořit zástupce. Ujistěte se, že skript existuje.

Vytvoření zástupce: Skript vytvoří zástupce ve formátu .lnk ve stejném adresáři, kde je uložen PowerShell skript, nebo na ploše, pokud upravíte cestu k výstupu.

Výsledek: Zástupce bude obsahovat cestu k powershell.exe a parametry pro spuštění PowerShell skriptu. Pokud chcete, můžete upravit ikonu zástupce nebo přidat další možnosti, jako například spuštění jako správce.

### Ukázka použití

Pokud máte PowerShell skript s názvem example.ps1 a chcete pro něj vytvořit zástupce, spusťte:

```powershell
.\make_shortcut.ps1 "C:\cesta\k\example.ps1"
```

Tento příkaz vytvoří zástupce pro skript v aktuálním adresáři. Sentinel pravdepodobne smaže.
