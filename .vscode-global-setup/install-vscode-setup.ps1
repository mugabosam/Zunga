# Install recommended VS Code extensions and optionally apply user settings
# Usage: Run in PowerShell as Administrator or normal user:
#   ./install-vscode-setup.ps1

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$settingsSource = Join-Path $scriptDir 'vscode-user-settings.json'
$extensionsList = Join-Path $scriptDir 'extensions-list.txt'

# Check for 'code' CLI
$codeCmd = Get-Command code -ErrorAction SilentlyContinue
if (-not $codeCmd) {
    Write-Host "The 'code' CLI was not found in PATH. Please open VS Code, press Ctrl+Shift+P and run 'Shell Command: Install 'code' command in PATH' (if available), or ensure code is on your PATH." -ForegroundColor Yellow
}

# Prompt before overwriting settings
$proceed = Read-Host "This script can install extensions and optionally overwrite your global VS Code settings (backing them up first). Proceed? (y/n)"
if ($proceed -ne 'y') { Write-Host 'Aborted.'; exit }

# Install extensions
if (Test-Path $extensionsList) {
    $exts = Get-Content $extensionsList | Where-Object { $_ -and -not ($_ -like '#*') }
    foreach ($ext in $exts) {
        Write-Host "Installing extension: $ext"
        & code --install-extension $ext --force
    }
} else {
    Write-Host "Extensions list not found at $extensionsList" -ForegroundColor Yellow
}

# Apply settings.json
$userSettingsDir = Join-Path $env:APPDATA 'Code\User'
$userSettingsPath = Join-Path $userSettingsDir 'settings.json'
if (Test-Path $settingsSource) {
    # backup
    if (-not (Test-Path $userSettingsDir)) { New-Item -ItemType Directory -Path $userSettingsDir -Force | Out-Null }
    if (Test-Path $userSettingsPath) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $backup = "$userSettingsPath.backup.$timestamp"
        Copy-Item $userSettingsPath $backup -Force
        Write-Host "Backed up existing settings to $backup"
    }
    Copy-Item $settingsSource $userSettingsPath -Force
    Write-Host "Applied settings to $userSettingsPath"
} else {
    Write-Host "Settings source not found at $settingsSource" -ForegroundColor Yellow
}

Write-Host "Done. Open VS Code and verify Settings Sync or sign in to sync across machines if desired." -ForegroundColor Green
