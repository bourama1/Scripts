param(
    [string]$rootDir = "C:\PDM\T09"
)

#–– Logging setup ––
$log = Join-Path $PSScriptRoot "cleanup_log.txt"
Start-Transcript -Path $log -Force

Write-Host "Starting cleanup under root: $rootDir`n"

#–– Find leaf dirs ––
$leafDirs = Get-ChildItem $rootDir -Directory -Recurse |
    Where-Object {
        (Test-Path (Join-Path $_.FullName '*.*')) -and
        @(Get-ChildItem $_.FullName -Directory -ErrorAction SilentlyContinue).Count -eq 0
    }

foreach ($dir in $leafDirs) {
    Write-Host "Processing: $($dir.FullName)"
    $allFiles = Get-ChildItem $dir.FullName -File

    #–– Build a single list of [BaseName, Ext, FileInfo, Revision] ––
    $entries = foreach ($f in $allFiles) {
        if ($f.BaseName -match '^(.*)_Rev(\d+)$') {
            [PSCustomObject]@{
                Base     = $matches[1]
                Ext      = $f.Extension.ToLower()
                File     = $f
                Revision = [int]$matches[2]
            }
        }
    }

    #–– Group by Base+Ext and move older versions ––
    $entries | Group-Object -Property Base,Ext |
    ForEach-Object {
        $group = $_.Group
        if ($group.Count -gt 1) {
            # sort descending → highest rev first
            $sorted = $group | Sort-Object Revision -Descending
            $latest = $sorted[0]
            $older  = $sorted | Select-Object -Skip 1

            # create OLD if needed
            $oldDir = Join-Path $dir.FullName "OLD"
            if (!(Test-Path $oldDir)) {
                Write-Host "  → Creating OLD folder"
                New-Item -ItemType Directory -Path $oldDir | Out-Null
            }

            foreach ($e in $older) {
                Write-Host "  → Moving $($e.File.Name) (rev $($e.Revision))"
                Move-Item $e.File.FullName (Join-Path $oldDir $e.File.Name) -Force
            }
        }
        else {
            Write-Host "  • Only one revision for $($_.Name): no action"
        }
    }
    Write-Host ""
}

Write-Host "Cleanup finished.`n"
Stop-Transcript
