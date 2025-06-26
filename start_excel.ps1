# --- Configuration ---
# Name of your Add-in as it appears in Excel's Add-ins list
$addinName = "OPCEx3"

# Full path to your Add-in file (.xlam, .xla, etc.)
$addinPath = "D:\temp\OPCEx3.xla"

# Path to workbook that should be opened with the Add-in enabled
$workbookWithAddin = "D:\temp\test.xlsx"

# Path to workbook that should be opened without the Add-in
$workbookWithoutAddin = "D:\temp\test_without_addin.xlsx"

# --- Function to launch Excel with Add-in ---
function Start-ExcelWithAddin {
    param(
        [string]$addinName,
        [string]$addinPath,
        [string]$workbookPath
    )

    Write-Host "Launching Excel instance with Add-in '$addinName'..."
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $true

    # Open workbook if specified
    if ($workbookPath -and (Test-Path $workbookPath)) {
        try {
            Write-Host "Opening workbook: $workbookPath"
            $excel.Workbooks.Open($workbookPath) | Out-Null
        }
        catch {
            Write-Host "Error opening workbook: $_"
        }
    }

    # Install and enable the Add-in
    try {
        Write-Host "Installing and enabling add-in from: $addinPath"
        $addIn = $excel.AddIns.Add($addinPath)
        $addIn.Installed = $true
        Write-Host "Add-in '$addinName' activated."
    }
    catch {
        Write-Host "Error enabling add-in: $_"
        # Fallback: try to find existing add-in by name
        try {
            $existing = $excel.AddIns | Where-Object { $_.Name -eq "$($addinName).xla" -or $_.Name -eq $addinName }
            if ($existing) {
                $existing.Installed = $true
                Write-Host "Existing add-in '$addinName' found and enabled."
            }
            else {
                Write-Host "Add-in '$addinName' not found in collection."
            }
        }
        catch {
            Write-Host "Further error when locating add-in: $_"
        }
    }

    return $excel
}

# --- Function to launch Excel without Add-in ---
function Start-ExcelWithoutAddin {
    param(
        [string]$addinName,
        [string]$workbookPath
    )

    Write-Host "Launching Excel instance WITHOUT Add-in '$addinName'..."
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $true

    # Open workbook if specified
    if ($workbookPath -and (Test-Path $workbookPath)) {
        try {
            Write-Host "Opening workbook: $workbookPath"
            $excel.Workbooks.Open($workbookPath) | Out-Null
        }
        catch {
            Write-Host "Error opening workbook: $_"
        }
    }

    # Disable the Add-in in this instance if already loaded
    try {
        $existing = $excel.AddIns | Where-Object { $_.Name -eq "$($addinName).xla" -or $_.Name -eq $addinName }
        if ($existing) {
            $existing.Installed = $false
            Write-Host "Disabled add-in '$addinName' in this instance."
        }
        else {
            Write-Host "Add-in '$addinName' not present in this instance."
        }
    }
    catch {
        Write-Host "Error disabling add-in: $_"
    }

    return $excel
}

# --- Main Script Execution ---
# 1) Start Excel with Add-in and open workbook
$excelWith = Start-ExcelWithAddin -addinName $addinName -addinPath $addinPath -workbookPath $workbookWithAddin

# 2) Start a second Excel instance without the Add-in and open different workbook
$excelWithout = Start-ExcelWithoutAddin -addinName $addinName -workbookPath $workbookWithoutAddin

# (Optional) Clean-up: Release COM objects when done
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($excelWith) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($excelWithout) | Out-Null
Remove-Variable excelWith, excelWithout

Write-Host "Both Excel instances have been launched."
