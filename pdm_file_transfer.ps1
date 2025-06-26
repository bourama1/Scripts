# --- START LOGGING CONFIGURATION ---
# Get the directory where the script file itself is located
$scriptDir = $PSScriptRoot
# Define the name for the log file
$logFileName = "log.txt"
# Combine the directory and filename to get the full log file path
$logFilePath = Join-Path -Path $scriptDir -ChildPath $logFileName

# Start capturing all host output to the specified log file.
try {
    Start-Transcript -Path $logFilePath -Force -ErrorAction Stop
    Write-Host "Transcript started. Logging output to: $logFilePath"
}
catch {
    Write-Error "Failed to start transcript. Error: $($_.Exception.Message)"
}
# --- END LOGGING CONFIGURATION ---

# Definition of source and destination folders
$sourceFolder = "N:\300 Departments\200 Development\Standardni_Prvky_PDM\Import_PDM"
$destinationRoot = "N:\300 Departments\200 Development\Standardni_Prvky_PDM"

# These lines will now go to both the console AND the log file
Write-Host "Source: $sourceFolder"
Write-Host "Destination: $destinationRoot"
Write-Host "-------------------------------------"

# Cycle for all files
# All Write-Host, Write-Error, etc. inside this loop will be captured by the transcript
Get-ChildItem -Path $sourceFolder -File | ForEach-Object {
    $sourceFile = $_.FullName
    $originalFileName = $_.Name
    Write-Host "File processing: $originalFileName"

    # --- Extract Parts from NEW File ---
    # Using stem (filename without extension) for revision checks
    $originalStem = [System.IO.Path]::GetFileNameWithoutExtension($originalFileName)
    $extension = [System.IO.Path]::GetExtension($originalFileName)
    Write-Host "  Stem: '$originalStem'"
    Write-Host "  Extension: '$extension'"

    $newRevision = 0
    $commonStemOfNewFile = $null

    # Getting revision part (_RevX) from the END of the STEM
    if ($originalStem -match '_Rev(\d+)') {
        # Match on the stem
        $newRevision = [int]$matches[1]
        Write-Host "  Revision found at end of stem: $newRevision"
        # Get the common part of the NEW file STEM (before _RevX suffix)
        $commonStemOfNewFile = $originalStem -replace '_Rev\d+$', ''
        Write-Host "  Common stem part: '$commonStemOfNewFile'"
    }
    else {
        Write-Host "  Revision pattern '_RevX' not found at the end of stem '$originalStem'. Skipping file: $originalFileName"
        Write-Host "-------------------------------------"
        return # Skip to the next file
    }

    # Getting the part of the filename before the FIRST underscore (for directory structure)
    $baseNameForPath = ($originalFileName -split '_', 2)[0]
    Write-Host "  Base name for path structure: '$baseNameForPath'"

    # --- Create Directory Structure ---
    $parts = $baseNameForPath.Split("-")
    $folderPath = $destinationRoot

    if ($parts.Count -ge 1) {
        $folderPath = Join-Path $folderPath $parts[0]
    }
    if ($parts.Count -ge 2) {
        for ($i = 1; $i -le $parts.Count - 2; $i++) {
            $folderPath = Join-Path $folderPath $parts[$i]
        }
    }
    $folderPath = Join-Path $folderPath $baseNameForPath # Final directory level is the base name
    Write-Host "    Path to dir: $folderPath"

    if (!(Test-Path $folderPath)) {
        Write-Host "    Dir structure doesn't exist. Creating: $folderPath"
        try {
            New-Item -ItemType Directory -Path $folderPath -Force -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Error " FAILED to create destination directory: $folderPath. Error: $($_.Exception.Message). Skipping file."
            Write-Host "-------------------------------------"
            return
        }
    }
    else {
        Write-Host "    Dir structure already exists."
    }

    # Path to destination file (using the original filename)
    $destinationFile = Join-Path $folderPath $originalFileName
    Write-Host "    Path to destination file: $destinationFile"

    # --- Check Existing Files and Handle Revisions ---
    $newerRevisionExists = $false
    Write-Host "    Checking existing files in: $folderPath"
    Write-Host "    (Comparing against files with common stem '$commonStemOfNewFile' and extension '$extension')"

    Get-ChildItem -Path $folderPath -File | ForEach-Object {
        $existingFile = $_
        $existingName = $existingFile.Name
        $existingStem = [System.IO.Path]::GetFileNameWithoutExtension($existingName)
        $existingExtension = [System.IO.Path]::GetExtension($existingName)
        Write-Host "      Checking existing file: '$($existingName)' (Stem: '$existingStem', Ext: '$existingExtension')"

        # Extract revision from the existing file's STEM
        $existingRevision = 0
        $script:hasExistingRevision = $false
        if ($existingStem -match '_Rev(\d+)') {
            # Match on the stem
            $existingRevision = [int]$matches[1]
            $hasExistingRevision = $true
            Write-Host "        -> Found Revision in stem: $existingRevision"

            # Extract the common part of the EXISTING file's STEM
            $commonStemOfExistingFile = $existingStem -replace '_Rev\d+$', ''
            Write-Host "        -> Existing Common Stem Part: '$commonStemOfExistingFile'"

            # Compare the common STEM parts and extensions
            $commonStemsMatch = ($commonStemOfExistingFile -eq $commonStemOfNewFile)
            $extensionsMatch = ($existingExtension -eq $extension) # Case-sensitive extension comparison

            Write-Host "        -> Common Stems Match ('$commonStemOfExistingFile' == '$commonStemOfNewFile'): $commonStemsMatch"
            Write-Host "        -> Extensions Match ('$existingExtension' == '$extension'): $extensionsMatch"

            if ($commonStemsMatch -and $extensionsMatch) {
                Write-Host "      MATCH FOUND: Common stem and extension match."
                Write-Host "      Comparing Revisions: Existing ($existingRevision) vs New ($newRevision)"

                # --- START MODIFICATION ---
                # Check if existing revision is OLDER
                if ($existingRevision -lt $newRevision) {
                    Write-Host "        -> OLDER. Existing revision is lower. Moving to OLD."
                    $oldFolder = Join-Path $folderPath "OLD"
                    if (!(Test-Path $oldFolder)) {
                        Write-Host "          Making dir OLD: $oldFolder"
                        try {
                            New-Item -ItemType Directory -Path $oldFolder -Force -ErrorAction Stop | Out-Null
                            Write-Host "          OLD directory created/exists."
                        }
                        catch {
                            Write-Error "          FAILED to create OLD directory: $oldFolder. Error: $($_.Exception.Message)"
                            continue # Skip trying to move this existing file
                        }
                    }
                    else {
                        Write-Host "          OLD directory exists: $oldFolder"
                    }

                    Write-Host "          Moving file '$existingName' to OLD folder '$oldFolder'"
                    $destinationOldFile = Join-Path $oldFolder $existingName
                    try {
                        Move-Item -Path $existingFile.FullName -Destination $destinationOldFile -Force -ErrorAction Stop
                        Write-Host "          Move successful."
                    }
                    catch {
                        Write-Error "          FAILED to move '$($existingName)' to OLD. Error: $($_.Exception.Message)"
                    }
                }
                # Check if revisions are the SAME
                elseif ($existingRevision -eq $newRevision) {
                    Write-Host "        -> SAME. Existing revision is identical. It will be overwritten by the new file. No move needed."
                }
                # Otherwise, the existing revision must be NEWER
                else {
                    Write-Host "        -> NEWER. Existing revision ($existingRevision) is newer."
                    Write-Host "        -> Setting flag: newerRevisionExists = $true"
                    $script:newerRevisionExists = $true
                }
                # --- END MODIFICATION ---
            }
            else {
                # Common stems or extensions don't match
                Write-Host "      NO MATCH on common stem or extension. Skipping comparison."
            }

        }
        else {
            # Existing file stem does not have _RevX suffix
            Write-Host "        -> No Revision suffix found in stem '$existingStem'. Skipping comparison logic."
        }
        Write-Host "      ------" # Separator
    } # End check for existing files

    # --- Move New File if Applicable ---
    if (-not $newerRevisionExists) {
        Write-Host "    Copying '$originalFileName' to: $destinationFile" # Changed message to reflect Copy-Item
        try {
            Copy-Item -Path $sourceFile -Destination $destinationFile -Force -ErrorAction Stop
            # Move-Item -Path $sourceFile -Destination $destinationFile -Force -ErrorAction Stop
            Write-Host "    File '$originalFileName' successfully copied." # Changed message
        }
        catch {
            Write-Error " FAILED to copy '$originalFileName' to '$destinationFile'. Error: $($_.Exception.Message)" # Changed message
        }
    }
    else {
        Write-Host "    Skipping copy for '$originalFileName' because a newer revision exists in the destination." # Changed message
        # Optional: Delete the source file if you don't want skipped files left behind
        #Write-Host "    Removing source file '$originalFileName' as it was skipped due to newer existing revision."
        #try {
        #    Remove-Item -Path $sourceFile -Force -ErrorAction SilentlyContinue
        #}
        #catch {
        #    Write-Warning "Could not remove skipped source file '$sourceFile'. Error: $($_.Exception.Message)"
        #}
    }

    Write-Host "-------------------------------------"
}

Write-Host "Script finished."
Stop-Transcript
Write-Host "Transcript stopped."