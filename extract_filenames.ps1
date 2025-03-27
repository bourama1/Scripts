# User prompt for folder path
$folderPath = Read-Host "Enter the path to the folder where the files are located"

# Check if the folder exists
if (-Not (Test-Path -Path $folderPath -PathType Container)) {
    Write-Host "The specified folder does not exist. The script will be terminated."
    exit
}

# Initialize the output list
$output = @()

# Get all files in the folder (without recursion)
$files = Get-ChildItem -Path $folderPath -File

# Get the list of keywords for filtering from the user
$keywords = @()
while ($true) {
    $keyword = Read-Host "Enter a word for filtering (leave empty to finish)"
    if ([string]::IsNullOrWhiteSpace($keyword)) {
        break
    }
    $keywords += $keyword
}

# Add header to the output with formatted columns (64 characters wide)
$output += "{0,-64} ; {1}" -f "Original Name", "Characteristic"

# For each file, check if it contains any of the entered words (case-insensitive)
foreach ($file in $files) {
    $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

    foreach ($keyword in $keywords) {
        if ($fileNameWithoutExtension -ilike "*$keyword*") {

            # TODO: Parameterize prefixes?
            $newName = $fileNameWithoutExtension -ireplace "^DW_", "Delka_"

            # Format the columns with a semicolon separator and 64-character width
            $formattedLine = "{0,-64} ; {1}" -f $fileNameWithoutExtension, $newName
            $output += $formattedLine
            break # Stop further searching for this file if it has already been found
        }
    }
}

# Get the path where the script was executed from
$scriptDirectory = (Get-Location).Path

# Save the output to a text file in the directory where the script was run
$outputPath = Join-Path $scriptDirectory "fileNamesCharacteristics.txt"
$output | Out-File -FilePath $outputPath -Encoding UTF8

# Open the output file
Invoke-Item -Path $outputPath

Write-Host "The results have been saved to the file: $outputPath"
