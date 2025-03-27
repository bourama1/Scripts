# Získání všech souborů v aktuálním adresáři, jejich filtrování na CSV soubory a seřazení podle času poslední změny (od nejnovějších po nejstarší)
$soubory = Get-ChildItem -File -Filter "*.csv" | Sort-Object LastWriteTime -Descending

# Proměnná pro počet nalezených souborů
$pocet_nalezenych = 0

# Procházení všech souborů
foreach ($soubor in $soubory) {
  # Získání názvu souboru bez přípony
  $nazev_bez_pripony = [System.IO.Path]::GetFileNameWithoutExtension($soubor.FullName)

  # Kontrola, zda název souboru bez přípony nekončí na "ND" (case-insensitive)
  if (-not $nazev_bez_pripony.EndsWith("ND", [System.StringComparison]::OrdinalIgnoreCase)) {
    # Výpis názvu souboru
    Write-Host $soubor.FullName

    # Zvýšení počtu nalezených souborů
    $pocet_nalezenych++

    # Kontrola, zda jsme již nalezli 50 souborů
    if ($pocet_nalezenych -ge 50) {
      break  # Pokud ano, ukončíme smyčku
    }
  }
}