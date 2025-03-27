# Definition of source and destination folders
$sourceFolder = "N:\300 Departments\200 Development\Standardni_Prvky_PDM\Import_PDM"
$destinationRoot = "N:\300 Departments\200 Development\Standardni_Prvky_PDM"

Write-Host "Source: $sourceFolder"
Write-Host "Destination: $destinationRoot"
Write-Host "-------------------------------------"

# Cycle for all files
Get-ChildItem -Path $sourceFolder -File | ForEach-Object {
    $sourceFile = $_.FullName
    $fileName = $_.Name
    Write-Host "File processing: $fileName"

    # Getting revision part (_RevX)
    if ($fileName -match '_Rev(\d+)') {
        $newRevision = [int]$matches[1]
        Write-Host "  Revision found, num of revision: $newRevision"
    }
    else {
        Write-Host "  Revision not found. Skipping."
        return
    }

    # Getting common part of filename (before _RevX)
    $commonPart = $fileName -replace '(_Rev.*)$', ''
    Write-Host "  Common part: $commonPart"

    # Getting file type
    $extension = [System.IO.Path]::GetExtension($fileName)
    Write-Host "  File type: $extension"

    # Creating folder structure name
    $parts = $commonPart.Split("-")
    $folderPath = $destinationRoot
    Write-Host "  Num of parts: $($parts.Count)"

    # Přidáme první segment jen jednou
    if ($parts.Count -ge 1) {
        $folderPath = Join-Path $folderPath $parts[0]
        Write-Host "    First part added: $parts[0] => $folderPath"
    }

    # Pokud máme alespoň tři části, přidáme střední segmenty (od 2. do předposledního)
    if ($parts.Count -ge 3) {
        for ($i = 1; $i -le $parts.Count - 2; $i++) {
            $folderPath = Join-Path $folderPath $parts[$i]
            Write-Host "    Adding part {$i}: $($parts[$i]) => $folderPath"
        }
    }

    # Přidáme commonPart jako poslední složku
    $folderPath = Join-Path $folderPath $commonPart
    Write-Host "    Path to dir: $folderPath"

    # Creating dir structure if it doesn't exist
    if (!(Test-Path $folderPath)) {
        Write-Host "    Dir structure doesn't exist. Creating: $folderPath"
        New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
    }
    else {
        Write-Host "    Dir structure already exists."
    }

    # Path to file with filename
    $destinationFile = Join-Path $folderPath $fileName
    Write-Host "    Path to file: $destinationFile"

    # Check files in the dir, move to OLD
    Write-Host "    Check of existing files in: $folderPath"
    Get-ChildItem -Path $folderPath -File | ForEach-Object {
        $existingFile = $_
        $existingName = $existingFile.Name
        # Finding files with same common part and file extension
        if ($existingName -match "^$([regex]::Escape($commonPart))_Rev(\d+)" -and ([System.IO.Path]::GetExtension($existingName) -eq $extension)) {
            $existingRevision = [int]$matches[2]
            Write-Host "      File found: $existingName with revision: $existingRevision"
            # Check for revision number: move if the existing revision is less or equal than new revision
            if ($existingRevision -le $newRevision) {
                $oldFolder = Join-Path $folderPath "OLD"
                if (!(Test-Path $oldFolder)) {
                    Write-Host "      Making dir OLD: $oldFolder"
                    New-Item -ItemType Directory -Path $oldFolder -Force | Out-Null
                }
                Write-Host "      Moving file $existingName to OLD"
                Move-Item -Path $existingFile.FullName -Destination $oldFolder -Force
            }
        }
    }

    # Copy to destination
    Write-Host "    Copying to: $destinationFile"
    Copy-Item -Path $sourceFile -Destination $destinationFile -Force
    Write-Host "    File $fileName successfully copied."
    Write-Host "-------------------------------------"
}
