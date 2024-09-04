# Pozadani uzivatele o zadani cesty ke slozce
$folderPath = Read-Host "Zadejte cestu ke slozce, kde jsou umisteny soubory"

# Overeni existence slozky
if (-Not (Test-Path -Path $folderPath -PathType Container)) {
    Write-Host "Zadana slozka neexistuje. Skript bude ukoncen."
    exit
}

# Pozadani uzivatele o zadani pripony
$prefix = Read-Host "Zadejte priponu, kterou chcete pridat k nazvum souboru"

# Ziskejte vsechny soubory ve slozce (rekurzivne)
$files = Get-ChildItem -Path $folderPath -File -Recurse

# Pro kazdy soubor pridat zadanou priponu k nazvu souboru, pokud ji jiz neobsahuje
foreach ($file in $files) {
    $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

    if (-not $fileNameWithoutExtension.StartsWith($prefix)) {
        $newName = $prefix + $file.Name
        Rename-Item -Path $file.FullName -NewName $newName
    }
}

Write-Host "Soubory byly uspesne prejmenovany."