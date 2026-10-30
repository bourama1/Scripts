<#
.SYNOPSIS
    Zips PDF and Excel files into one ZIP per year inside every 6-digit folder (e.g. 000101, 002226).

.DESCRIPTION
    For each subfolder of -Root whose name is exactly 6 digits, all PDF and Excel files
    (including subfolders) are grouped by year and added to <folder>\<year>.zip, e.g. 000101\2022.zip.
    Files from the current year are left alone. Excel lock files (~$*.xlsx) are ignored.
    If a year ZIP already exists, new files are added to it (existing entries are not overwritten).

.PARAMETER Root
    Directory that contains the 6-digit folders.

.PARAMETER DateProperty
    Which date decides the year: LastWriteTime ("Date modified", default) or CreationTime.
    Note: copying files resets CreationTime on Windows, so LastWriteTime is usually more reliable.

.PARAMETER Extensions
    File types to archive. Default: .pdf .xls .xlsx .xlsm .xlsb

.PARAMETER DeleteOriginals
    Delete each file after it was successfully added to the ZIP.

.EXAMPLE
    .\Archive-Pdfs.ps1 -Root "D:\Data" -WhatIf
    Shows what would be done, changes nothing.

.EXAMPLE
    .\Archive-Pdfs.ps1 -Root "D:\Data" -DeleteOriginals
#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory)]
  [string]$Root,

  [ValidateSet('CreationTime', 'LastWriteTime')]
  [string]$DateProperty = 'LastWriteTime',

  [string[]]$Extensions = @('.pdf', '.xls', '.xlsx', '.xlsm', '.xlsb'),

  [switch]$DeleteOriginals
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$currentYear = (Get-Date).Year
$rootPath = (Resolve-Path -LiteralPath $Root).ProviderPath

$folders = @(Get-ChildItem -LiteralPath $rootPath -Directory | Where-Object { $_.Name -match '^\d{6}$' })
Write-Host "Found $($folders.Count) folder(s) with a 6-digit name in $rootPath (using $DateProperty)"

foreach ($folder in $folders) {
  $allFiles = @(Get-ChildItem -LiteralPath $folder.FullName -File -Recurse |
    Where-Object { $Extensions -contains $_.Extension.ToLower() -and $_.Name -notlike '~$*' })
  $toZip = @($allFiles | Where-Object { $_.$DateProperty.Year -lt $currentYear })
  Write-Host "$($folder.Name): $($allFiles.Count) file(s), $($allFiles.Count - $toZip.Count) from $currentYear kept, $($toZip.Count) to zip"

  if (-not $toZip) { continue }

  foreach ($group in ($toZip | Group-Object { $_.$DateProperty.Year })) {
    $zipPath = Join-Path $folder.FullName "$($group.Name).zip"

    if (-not $PSCmdlet.ShouldProcess($zipPath, "Add $($group.Count) file(s)")) { continue }

    $added = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
    # 'Create' streams to disk (fast, low memory); 'Update' is only needed to append to an existing zip
    $mode = if (Test-Path -LiteralPath $zipPath) { 'Update' } else { 'Create' }

    try {
      $zip = [System.IO.Compression.ZipFile]::Open($zipPath, $mode)
      try {
        foreach ($file in $group.Group) {
          # keep the path relative to the 6-digit folder (so subfolders are preserved)
          $entryName = $file.FullName.Substring($folder.FullName.Length).TrimStart('\', '/') -replace '\\', '/'

          if ($mode -eq 'Update' -and $zip.GetEntry($entryName)) {
            Write-Warning "Already in $zipPath, skipped: $entryName"
            continue
          }

          [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, $file.FullName, $entryName, [System.IO.Compression.CompressionLevel]::Optimal)
          $added.Add($file)
        }
      }
      finally {
        $zip.Dispose()   # zip is fully written only after this
      }
    }
    catch {
      Write-Error "Failed on $zipPath : $_" -ErrorAction Continue
      if ($mode -eq 'Create') { Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue }
      continue             # nothing gets deleted if the zip failed
    }

    Write-Host "$zipPath  <- $($added.Count) file(s)"

    if ($DeleteOriginals -and $added.Count) {
      $added | Remove-Item -Force
    }
  }
}

Write-Host "Done."