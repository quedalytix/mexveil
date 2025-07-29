<#
.SYNOPSIS
    Installer for mexveil - Microsoft Exchange Veil

.DESCRIPTION
    Downloads mexveil script and its dependencies from GitHub to the current directory.
    Simple installer that just fetches the files for local use.

.EXAMPLE
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/quedalytix/mexveil/main/install.ps1" -UseBasicParsing | Invoke-Expression
    Downloads mexveil files to current directory

.NOTES
    - Requires internet connection to download files
    - Downloads to current working directory
    - After installation, run: .\mexveil.ps1 -ServiceName "your-service-name"
    
.LINK
    https://github.com/quedalytix/mexveil
#>

# GitHub raw URLs for the required files
$BaseUrl = "https://raw.githubusercontent.com/quedalytix/mexveil/main"
$MainScriptUrl = "$BaseUrl/mexveil.ps1"
$ModuleUrl = "$BaseUrl/mexveil.psm1"

try {
    Write-Host "=== mexveil Installer ===" -ForegroundColor Cyan
    Write-Host "Downloading mexveil files from GitHub..." -ForegroundColor Yellow
    
    # Download main script to current directory
    $MainScriptPath = "mexveil.ps1"
    Write-Host "Downloading mexveil.ps1..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $MainScriptUrl -OutFile $MainScriptPath -UseBasicParsing
    
    # Download module to current directory
    $ModulePath = "mexveil.psm1"
    Write-Host "Downloading mexveil.psm1..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $ModuleUrl -OutFile $ModulePath -UseBasicParsing
    
    Write-Host "`nInstallation completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== Usage Instructions ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To create a shared mailbox, run:" -ForegroundColor White
    Write-Host "  .\mexveil.ps1 -ServiceName " -NoNewline -ForegroundColor Yellow
    Write-Host '"your-service-name"' -ForegroundColor Green
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  .\mexveil.ps1 -ServiceName " -NoNewline -ForegroundColor Yellow
    Write-Host '"support"' -ForegroundColor Green
    Write-Host "  .\mexveil.ps1 -ServiceName " -NoNewline -ForegroundColor Yellow
    Write-Host '"newsletter"' -ForegroundColor Green
    Write-Host "  .\mexveil.ps1 -ServiceName " -NoNewline -ForegroundColor Yellow
    Write-Host '"shopping"' -ForegroundColor Green
    Write-Host ""
    Write-Host "For help: " -NoNewline -ForegroundColor White
    Write-Host ".\mexveil.ps1 -Help" -ForegroundColor Yellow
    Write-Host ""
    
} catch {
    Write-Error "Failed to download mexveil: $($_.Exception.Message)"
    Write-Host "Please check your internet connection and try again." -ForegroundColor Red
    exit 1
}
