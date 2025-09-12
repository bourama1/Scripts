# ───────────────────────────────────────────────────────────
# start_excel.ps1
# ───────────────────────────────────────────────────────────


# 1) Force UTF-8 in/out
[Console]::InputEncoding  = [Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [Text.UTF8Encoding]::new()

# 2) Load WinForms for Screen/AllScreens
#    (Must run in Windows PowerShell 5.1 for easiest compatibility)
Add-Type -AssemblyName System.Windows.Forms

# 3) Define Win32.MoveWindow via P/Invoke
Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class Win32 {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool MoveWindow(
      IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  }
"@

# 4) Configuration
$excelExe = "C:\Program Files (x86)\Microsoft Office\root\Office16\EXCEL.EXE"
$timeout  = 5  # seconds

# Map each workbook filename to the monitor index you want:
$fileMonitors = @{
  "makroProcedura.xlsm"             = 1
  "rucniTisk.xlsm"                  = 1
  "evidence010-dvousmenny.xlsm"     = 2
  "Vizualizace andon.xlsm"          = 0
}

# Base folder containing your .xlsm files
$baseFolder = "D:\Aktuální SW\ExcelApp"

# 5) Enumerate and process
$monitors = [System.Windows.Forms.Screen]::AllScreens

Get-ChildItem -LiteralPath $baseFolder -Filter *.xlsm -File | ForEach-Object {
    $fileName = $_.Name
    if (-not $fileMonitors.ContainsKey($fileName)) {
        Write-Warning "Skipping $fileName (no monitor mapping)."
        return
    }

    $wbPath = $_.FullName
    $mon    = $fileMonitors[$fileName]

    Write-Host "Opening $fileName on monitor #$mon …"

    # Force a new Excel instance (/x), and quote the full path
    $arg = '/x ' + '"' + $wbPath + '"'
    $proc = Start-Process -FilePath $excelExe `
                          -ArgumentList $arg `
                          -PassThru

    # Wait for its window handle
    $sw = [Diagnostics.Stopwatch]::StartNew()
    do {
        Start-Sleep -Milliseconds 200
        $proc.Refresh()
    } until ($sw.Elapsed.TotalSeconds -ge $timeout)

    if ($proc.MainWindowHandle -eq 0) {
        Write-Warning "  → Couldn’t get window for PID $($proc.Id)"
        return
    }

    $bounds = $monitors[$mon].WorkingArea

    [Win32]::MoveWindow(
      $proc.MainWindowHandle,
      $bounds.X, $bounds.Y,
      $bounds.Width, $bounds.Height,
      $true
    )

    # Maximize window (3 = SW_MAXIMIZE)
    [Win32]::ShowWindow($proc.MainWindowHandle, 3)

    Write-Host "  → Moved to Monitor #$mon ($($bounds.Width)x$($bounds.Height))"
}

Write-Host "✅ Done."
