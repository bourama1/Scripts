# User request to input the folder path
$folderPath = Read-Host "Enter the path to the folder where the files are located"

# Check if the folder exists
if (-Not (Test-Path -Path $folderPath -PathType Container)) {
    Write-Host "The specified folder does not exist. The script will be terminated."
    exit
}

# User request to input the prefix
$prefix = Read-Host "Enter the prefix you want to add to the file names"

# Get all files in the folder (recursively)
$files = Get-ChildItem -Path $folderPath -File -Recurse

# For each file, add the specified prefix to the file name, if it doesn't already have it
foreach ($file in $files) {
    $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

    if (-not $fileNameWithoutExtension.StartsWith($prefix)) {
        $newName = $prefix + $file.Name
        Rename-Item -Path $file.FullName -NewName $newName
    }
}

Write-Host "Files have been successfully renamed."
