param (
    [string]$ps1Path
)

if (-not (Test-Path $ps1Path)) {
    Write-Host "Script $ps1Path don't exist!" -ForegroundColor Red
    exit 1
}

$shortcutPath = "$([System.IO.Path]::ChangeExtension($ps1Path, '.lnk'))"

$targetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ps1Path`""

$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.Arguments = $arguments
$shortcut.Description = "Will run ps1 script: $ps1Path"
$shortcut.IconLocation = "C:\Windows\System32\shell32.dll,1"
$shortcut.Save()

Write-Host "Shortcut created: $shortcutPath" -ForegroundColor Green
