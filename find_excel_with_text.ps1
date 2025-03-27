# Set directory and search text
$directory = "D:\temp"
$searchText = "TMP023300828"

# Create Excel COM object
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false  # Keep Excel hidden for performance

# Get all Excel files in the directory
$files = Get-ChildItem -Path $directory -Filter "*.xls*"

# List to store matching files
$matchingFiles = @()

foreach ($file in $files) {
    $filePath = $file.FullName
    Write-Host "Scanning: $filePath"

    try {
        # Open Workbook (Read-Only Mode)
        $workbook = $excel.Workbooks.Open($filePath, 0, $true)

        # Loop through all sheets
        foreach ($sheet in $workbook.Sheets) {
            $cells = $sheet.UsedRange  # Get the used range of the sheet

            # Loop through each cell in the used range
            foreach ($cell in $cells) {
                # Check if the cell contains the search text (case-insensitive)
                if ($cell.Text -like "*$searchText*") {
                    $matchingFiles += $file.Name
                    break  # No need to check further in this file
                }
            }

        }

        # Close Workbook
        $workbook.Close($false)
    }
    catch {
        Write-Host "Error processing $filePath : $_"
    }
}

# Quit Excel
$excel.Quit()

# Display results
if ($matchingFiles.Count -gt 0) {
    Write-Host "Files containing the text '$searchText':"
    $matchingFiles | ForEach-Object { Write-Host $_ }
}
else {
    Write-Host "No matching files found."
}
