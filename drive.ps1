$driveLetter = "N:"
$uncPath = "\\loading-systems.local\TOCZ\510-TOCZ"

# Check if the drive is already mapped
if (-not (Test-Path -Path "$($driveLetter)\")) {
    Write-Host "Mapping network drive $driveLetter to $uncPath..."
    try {
        New-PSDrive -Name $driveLetter.Trim(":") -PSProvider FileSystem -Root $uncPath -Persist -ErrorAction Stop
        Write-Host "Drive $driveLetter mapped successfully."
    }
    catch {
        Write-Error "Failed to map network drive $driveLetter. Error: $($_.Exception.Message)"
        exit 1
    }
}
else {
    Write-Host "Drive $driveLetter already exists."
}