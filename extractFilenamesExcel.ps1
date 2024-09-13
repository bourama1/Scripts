# Pozadani uzivatele o zadani cesty ke slozce
$folderPath = Read-Host "Zadejte cestu ke slozce, kde jsou umisteny soubory"

# Overeni existence slozky
if (-Not (Test-Path -Path $folderPath -PathType Container)) {
    Write-Host "Zadana slozka neexistuje. Skript bude ukoncen."
    exit
}

# Ziskani vsech souboru ve slozce (bez rekurze)
$files = Get-ChildItem -Path $folderPath -File

# Ziskani seznamu slov pro filtraci od uzivatele
$keywords = @()
while ($true) {
    $keyword = Read-Host "Zadejte slovo pro filtraci (nechte prazdne pro konec)"
    if ([string]::IsNullOrWhiteSpace($keyword)) {
        break
    }
    $keywords += $keyword
}

# Inicializace hashtable pro kontrolu unikatnich zaznamu
$uniqueFiles = @{}

# Pro kazdy soubor zkontrolovat, zda obsahuje kterekoliv zadane slovo (case-insensitive)
foreach ($file in $files) {
    $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

    foreach ($keyword in $keywords) {
        if ($fileNameWithoutExtension -ilike "*$keyword*") {
            $newName = $fileNameWithoutExtension -ireplace "^DW_", "Delka_"

            # Pokud soubor jeste nebyl pridany do unikatniho seznamu
            if (-Not $uniqueFiles.ContainsKey($fileNameWithoutExtension)) {
                $uniqueFiles[$fileNameWithoutExtension] = $newName
            }
            break # Zastavit dalsi hledani pro tento soubor, pokud uz je nalezen
        }
    }
}

# Ziskani cesty, odkud byl skript spusten
$scriptDirectory = (Get-Location).Path

# Cesta k excel souboru
$outputPath = Join-Path $scriptDirectory "nazvyCharakteristik.xlsx"

# Vytvoreni pole pro Excel tabulku
$excelData = @()
foreach ($key in $uniqueFiles.Keys) {
    $excelData += [pscustomobject]@{
        "Puvodni nazev" = $key
        "Charakteristika" = $uniqueFiles[$key]
    }
}

# Pokud nemas nainstalovany ImportExcel modul, pouzij tento prikaz: Install-Module -Name ImportExcel
# Export dat do Excel tabulky
$excelData | Export-Excel -Path $outputPath -AutoSize -WorksheetName "Nazvy"

# Otevrit Excel soubor
Invoke-Item -Path $outputPath

Write-Host "Vysledky byly ulozeny do souboru: $outputPath"