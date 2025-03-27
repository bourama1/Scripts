# Get all files in the current directory, filter them to CSV files, and sort by last write time (newest first)
$files = Get-ChildItem -File -Filter "*.csv" | Sort-Object LastWriteTime -Descending

# Variable for the number of found files
$found_count = 0

# Loop through all files
foreach ($file in $files) {
  # Get the file name without extension
  $name_without_extension = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName)

  # Check if the file name without extension does not end with "ND" (case-insensitive)
  if (-not $name_without_extension.EndsWith("ND", [System.StringComparison]::OrdinalIgnoreCase)) {
    # Output the file name
    Write-Host $file.FullName

    # Increment the number of found files
    $found_count++

    # Check if we have found 50 files
    if ($found_count -ge 50) {
      break  # If yes, exit the loop
    }
  }
}