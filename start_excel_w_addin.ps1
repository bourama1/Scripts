# --- Configuration ---
# Set the name of your Add-in as it appears in Excel's Add-ins list.
# You might need to check the exact name in Excel > File > Options > Add-ins.
$addinName = "OPCEx3"

# Set the full path to your Add-in file (.xlam, .xla, etc.).
# IMPORTANT: Update this path to the actual location of your OPX3 add-in file.
$addinPath = "D:\temp\OPCEx3.xla"

# (Optional) Set the full path to a specific Excel file to open.
# If you don't need to open a specific file, leave this blank ("").
$workbookPath = "D:\temp\test.xlsx"

# --- Script Logic ---

# Create a new, invisible instance of Excel
Write-Host "Starting a new instance of Excel..."
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $true # Set to $true to see the Excel window

# (Optional) Open a specific workbook
if ($workbookPath -ne "" -and (Test-Path $workbookPath)) {
    try {
        Write-Host "Opening workbook: $workbookPath"
        $excel.Workbooks.Open($workbookPath)
    }
    catch {
        Write-Host "An error occurred while opening the workbook: $_"
    }
}

# Install and enable the Add-in
try {
    Write-Host "Attempting to install and enable the '$addinName' add-in..."

    # Add the add-in from its path
    $addIn = $excel.AddIns.Add($addinPath)

    # Set the add-in to be installed (activated)
    $addIn.Installed = $true

    Write-Host "'$addinName' add-in has been successfully enabled."
}
catch {
    Write-Host "An error occurred while enabling the add-in: $_"
    # Try to find the add-in if it's already in the collection and enable it
    try {
        $existingAddin = $excel.AddIns | Where-Object { $_.Name -eq ($addinName + ".xla") -or $_.Name -eq $addinName }
        if ($existingAddin) {
            $existingAddin.Installed = $true
            Write-Host "Found and enabled the existing '$addinName' add-in."
        } else {
            Write-Host "Could not find the '$addinName' add-in to enable."
        }
    }
    catch {
        Write-Host "A further error occurred: $_"
    }
}

# Release the COM object
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
Remove-Variable excel

Write-Host "Automation script finished."