# Definition of source and destination folders
$sourceFolder = "N:\300 Departments\200 Development\Standardni_Prvky_PDM\Import_PDM"
$destinationRoot = "N:\300 Departments\200 Development\Standardni_Prvky_PDM"

Write-Host "Source: $sourceFolder"
Write-Host "Destination: $destinationRoot"
Write-Host "-------------------------------------"

# Cycle for all files
Get-ChildItem -Path $sourceFolder -File | ForEach-Object {
    $sourceFile = $_.FullName
    $originalFileName = $_.Name
    Write-Host "File processing: $originalFileName"

    # Getting revision part (_RevX) from the END of the filename
    if ($originalFileName -match '_Rev(\d+)') {
        $newRevision = [int]$matches[1]
        Write-Host "  Revision found at the end, num of revision: $newRevision"
    }
    else {
        Write-Host "  Revision pattern '_RevX' not found at the end. Skipping file: $originalFileName"
        Write-Host "-------------------------------------"
        return
    }

    # Getting the part of the filename before the FIRST underscore (=BAAN, for directory structure)
    $baseNameForPath = ($originalFileName -split '_', 2)[0] # Split only on the first underscore
    Write-Host "  Base name for path: $baseNameForPath"

    # Getting the part of the filename before the revision (for comparison later)
    $commonPartBeforeRevision = $originalFileName -replace '_Rev\d+', ''
    Write-Host "  Common part before revision: $commonPartBeforeRevision"

    # Getting file type
    $extension = [System.IO.Path]::GetExtension($originalFileName)
    Write-Host "  Extension: $extension"

    # Creating folder structure name based on baseNameForPath
    $parts = $baseNameForPath.Split("-")
    $folderPath = $destinationRoot

    # Add first part
    if ($parts.Count -ge 1) {
        $folderPath = Join-Path $folderPath $parts[0]
    }

    # Add other parts (excluding the last part of the baseNameForPath)
    if ($parts.Count -ge 2) {
        # Changed condition to ensure there's something to loop through
        for ($i = 1; $i -le $parts.Count - 2; $i++) {
            $folderPath = Join-Path $folderPath $parts[$i]
        }
    }

    # Adding baseNameForPath as the final directory level
    $folderPath = Join-Path $folderPath $baseNameForPath
    Write-Host "    Path to dir: $folderPath"

    # Creating dir structure if it doesn't exist
    if (!(Test-Path $folderPath)) {
        Write-Host "    Dir structure doesn't exist. Creating: $folderPath"
        New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
    }
    else {
        Write-Host "    Dir structure already exists."
    }

    # Path to destination file (using the original filename)
    $destinationFile = Join-Path $folderPath $originalFileName
    Write-Host "    Path to destination file: $destinationFile"

    # Check files in the destination dir, move to OLD
    $newerRevisionExists = $false
    Write-Host "    Checking existing files in: $folderPath"

    # Get the common part of the NEW file (before _RevX suffix) for comparison
    $commonPartOfNewFile = $originalFileName -replace '_Rev\d+', ''
    Write-Host "    (Expecting to find existing files matching base: '$commonPartOfNewFile' with lower/equal revision)"


    Get-ChildItem -Path $folderPath -File | ForEach-Object {
        $existingFile = $_
        $existingName = $existingFile.Name
        Write-Host "      Checking existing file: '$($existingName)'"

        # Extract revision from the existing file (must have _RevX suffix)
        $existingRevision = 0
        $script:hasExistingRevision = $false
        if ($existingName -match '_Rev(\d+)') {
            $existingRevision = [int]$matches[1]
            $script:hasExistingRevision = $true
            Write-Host "        -> Found Revision: $existingRevision"

            # Extract the common part of the EXISTING file (before _RevX suffix)
            $commonPartOfExistingFile = $existingName -replace '_Rev\d+', ''
            Write-Host "        -> Existing Common Part: '$commonPartOfExistingFile'"

            # Compare the common part of the NEW file with the common part of the EXISTING file
            # Also compare the file extensions
            $commonPartsMatch = ($commonPartOfExistingFile -eq $commonPartOfNewFile)
            $extensionsMatch = ([System.IO.Path]::GetExtension($existingName) -eq $extension)

            Write-Host "        -> Common Parts Match ($commonPartOfExistingFile == $commonPartOfNewFile): $commonPartsMatch"
            Write-Host "        -> Extensions Match: $extensionsMatch"

            if ($commonPartsMatch -and $extensionsMatch) {
                Write-Host "      MATCH FOUND: Common part and extension match."
                Write-Host "      Comparing Revisions: Existing ($existingRevision) <= New ($newRevision) ?"

                # Check revision number
                if ($existingRevision -le $newRevision) {
                    Write-Host "        -> YES. Existing revision is lower or equal. Moving to OLD."
                    $oldFolder = Join-Path $folderPath "OLD"
                    if (!(Test-Path $oldFolder)) {
                        Write-Host "          Making dir OLD: $oldFolder"
                        try {
                            New-Item -ItemType Directory -Path $oldFolder -Force -ErrorAction Stop | Out-Null
                            Write-Host "          OLD directory created/exists."
                        }
                        catch {
                            Write-Error "          FAILED to create OLD directory: $oldFolder. Error: $($_.Exception.Message)"
                            continue # Skip to the next existing file
                        }
                    }
                    else {
                        Write-Host "          OLD directory exists: $oldFolder"
                    }

                    Write-Host "          Moving file '$existingName' to OLD folder"
                    $destinationOldFile = Join-Path $oldFolder $existingName
                    try {
                        Move-Item -Path $existingFile.FullName -Destination $destinationOldFile -Force -ErrorAction Stop
                        Write-Host "          Move successful."
                    }
                    catch {
                        Write-Error "          FAILED to move '$($existingName)' to OLD. Error: $($_.Exception.Message)"
                    }
                }
                else {
                    Write-Host "        -> NO. Existing revision ($existingRevision) is newer."
                    Write-Host "        -> Setting flag: newerRevisionExists = $true"
                    $script:newerRevisionExists = $true
                }
            }
            else {
                Write-Host "      NO MATCH on common part or extension. Skipping comparison."
            }

        }
        else {
            Write-Host "        -> No Revision suffix found. Skipping comparison logic for '$existingName'."
        }
    }

    if (-not $newerRevisionExists) {
        Copy-Item -Path $sourceFile -Destination $destinationFile -Force
        # Move-Item -Path $sourceFile -Destination $destinationFile -Force
    }
    else {
        Write-Host "    Skipping move for '$originalFileName' because a newer revision exists in the destination."
        # Optional: Delete the source file if you don't want skipped files left behind
        # Remove-Item -Path $sourceFile -Force
    }

    Write-Host "-------------------------------------"
}

Write-Host "Script finished."