# --- Section 1: Kill All Excel Processes ---
Get-Process -Name "EXCEL" -ErrorAction SilentlyContinue | Stop-Process -Force

Start-Sleep -Seconds 5

# --- Section 2: Clean Temp folder and Excel AutoRecover files ---
$tempPath = $env:TEMP
$autoRecoverPaths = @(
    "$env:APPDATA\Microsoft\Excel",
    "$env:LOCALAPPDATA\Microsoft\Office\UnsavedFiles"
)

try {
    Write-Host "Cleaning TEMP folder..."
    Get-ChildItem -Path $tempPath -Recurse -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

    foreach ($path in $autoRecoverPaths) {
        if (Test-Path $path) {
            Write-Host "Cleaning Excel AutoRecover files in: $path"
            Get-ChildItem -Path $path -Include *.xls*,*.tmp,*.asd -Recurse -ErrorAction SilentlyContinue |
                Remove-Item -Force -ErrorAction SilentlyContinue
        }
    }
}
catch {
    Write-Host "An error occurred while cleaning temporary or AutoRecover files. Continuing..."
}

# Start-Sleep -Seconds 5

# --- Section 3: Reboot Computer ---
# Restart-Computer -Force