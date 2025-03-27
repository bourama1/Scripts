# User prompt to enter the folder path
$folderPath = Read-Host "Enter the path to the folder where the files are located"

# Check if the folder exists
if (-Not (Test-Path -Path $folderPath -PathType Container)) {
    Write-Host "The specified folder does not exist. The script will be terminated."
    exit
}

# Get all files in the folder (non-recursively)
$files = Get-ChildItem -Path $folderPath -File

# Get list of keywords for filtering from the user
$keywords = @()
while ($true) {
    $keyword = Read-Host "Enter a keyword for filtering (leave empty to finish)"
    if ([string]::IsNullOrWhiteSpace($keyword)) {
        break
    }
    $keywords += $keyword
}

# Initialize hashtable for checking unique entries
$uniqueFiles = @{}

# For each file, check if it contains any of the specified keywords (case-insensitive)
foreach ($file in $files) {
    $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

    foreach ($keyword in $keywords) {
        if ($fileNameWithoutExtension -ilike "*$keyword*") {
            $newName = $fileNameWithoutExtension -ireplace "^DW_", "Delka_"

            # If the file has not been added to the unique list yet
            if (-Not $uniqueFiles.ContainsKey($fileNameWithoutExtension)) {
                $uniqueFiles[$fileNameWithoutExtension] = $newName
            }
            break # Stop searching for this file once it is found
        }
    }
}

# Get the path where the script was run
$scriptDirectory = (Get-Location).Path

# Path to the Excel file
$outputPath = Join-Path $scriptDirectory "file_names.xlsx"

# Create an array for the Excel table
$excelData = @()
foreach ($key in $uniqueFiles.Keys) {
    $excelData += [pscustomobject]@{
        "Original Name"  = $key
        "Characteristic" = $uniqueFiles[$key]
    }
}

# If you don't have the ImportExcel module installed, use this command: Install-Module -Name ImportExcel
# Export data to Excel table
$excelData | Export-Excel -Path $outputPath -AutoSize -WorksheetName "Names"

# Open the Excel file
Invoke-Item -Path $outputPath

Write-Host "The results have been saved to the file: $outputPath"
