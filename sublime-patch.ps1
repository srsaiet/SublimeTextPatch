# ==============================================================================
# Script Patch Sublime Text 4 (Build 4213 & 4215) - Windows x64
# ==============================================================================

# 1. Make sure the script is run as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
Write-Host " [!] Please run PowerShell as Administrator!" -ForegroundColor Red
Pause
exit
}

# 2. Close the Sublime Text process if it is running.
$process = Get-Process -Name "sublime_text" -ErrorAction SilentlyContinue
if ($process) {
Write-Host " [*] Closing the running Sublime Text...." -ForegroundColor Yellow
Stop-Process -Name "sublime_text" -Force
Start-Sleep -Seconds 1
}

# 3. Target file location
$path = "C:\Program Files\Sublime Text\sublime_text.exe"

if (-not (Test-Path $path)) {
Write-Host " [!] File sublime_text.exe not found in: $path" -ForegroundColor Red
Pause
exit
}

# 4. Target Byte Pattern (Build 4213 & 4215)
$old = "0F-B6-51-0C-83-F2-01"
$new = "C6-41-0C-01-31-D2-90"

# 5. Create a backup copy (Backup)
Write-Host " [*] Creating backup file: sublime_text.exe.bak...." -ForegroundColor Cyan
Copy-Item $path "$path.bak" -Force

# 6. Convert hex string to byte array
$bytes = [System.IO.File]::ReadAllBytes($path)
$hexOld = $old.Split('-') | ForEach-Object { [byte]"0x$_" }
$hexNew = $new.Split('-') | ForEach-Object { [byte]"0x$_" }

# 7. Byte Search and Replace Process
$patched = $false
for ($i = 0; $i -le $bytes.Length - $hexOld.Length; $i++) {
$match = $true
for ($j = 0; $j -lt $hexOld.Length; $j++) {
if ($bytes[$i + $j] -ne $hexOld[$j]) { 
$match = $false
break 
}
}
if ($match) {
for ($j = 0; $j -lt $hexNew.Length; $j++) {
$bytes[$i + $j] = $hexNew[$j]
}
[System.IO.File]::WriteAllBytes($path, $bytes)
$patched = $true
break
}
}

# 8. Show Execution Results
if ($patched) {
Write-Host " [+] Patch successfully applied to Sublime Text.!" -ForegroundColor Green
} else {
Write-Host " [!] Byte pattern not found. The file may have already been patched, or the version does not match.." -ForegroundColor Yellow
}

Pause 