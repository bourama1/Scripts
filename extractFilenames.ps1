# Pozadani uzivatele o zadani cesty ke slozce
$folderPath = Read-Host "Zadejte cestu ke slozce, kde jsou umisteny soubory"

# Overeni existence slozky
if (-Not (Test-Path -Path $folderPath -PathType Container)) {
    Write-Host "Zadana slozka neexistuje. Skript bude ukoncen."
    exit
}

# Inicializace seznamu pro ukladani vystupu
$output = @()

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

# Pridani hlavicky do vystupu s formatovanim sloupcu na 64 znaku
$output += "{0,-64} ; {1}" -f "Puvodni nazev", "Charakteristika"

# Pro kazdy soubor zkontrolovat, zda obsahuje kterekoliv zadane slovo (case-insensitive)
foreach ($file in $files) {
    $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    
    foreach ($keyword in $keywords) {
        if ($fileNameWithoutExtension -ilike "*$keyword*") {
            $newName = $fileNameWithoutExtension -ireplace "^DW_", "Delka_"
            
            # Naformatovani sloupcu s oddelovacem strednikem na 64 znaku
            $formattedLine = "{0,-64} ; {1}" -f $fileNameWithoutExtension, $newName
            $output += $formattedLine
            break # Zastavit dalsi hledani pro tento soubor, pokud uz je nalezen
        }
    }
}

# Ziskani cesty, odkud byl skript spusten
$scriptDirectory = (Get-Location).Path

# Vystup ulozit do textoveho souboru ve slozce, odkud byl skript spusten
$outputPath = Join-Path $scriptDirectory "nazvyCharakteristik.txt"
$output | Out-File -FilePath $outputPath -Encoding UTF8

# Otevrit vystupni soubor
Invoke-Item -Path $outputPath

Write-Host "Vysledky byly ulozeny do souboru: $outputPath"