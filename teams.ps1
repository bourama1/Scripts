Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

while ($true) {
    $pos = [System.Windows.Forms.Cursor]::Position
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(($pos.X + 1), $pos.Y)
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.Cursor]::Position = $pos

    $currentWindow = [WinAPI]::GetForegroundWindow()

    $proc = Start-Process -FilePath "notepad.exe" -PassThru
    Start-Sleep -Seconds 2

    if (-not $proc.HasExited) {
        $proc.CloseMainWindow() | Out-Null
        Start-Sleep -Seconds 1
        if (-not $proc.HasExited) {
            $proc | Stop-Process -Force
        }
    }

    [WinAPI]::SetForegroundWindow($currentWindow)

    Start-Sleep -Seconds 300
}
