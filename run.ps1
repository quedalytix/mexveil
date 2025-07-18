<#
.SYNOPSIS
    Remote installer and runner for mexveil - Microsoft Exchange Veil

.DESCRIPTION
    Downloads and executes mexveil script with its dependencies from GitHub.
    Designed for one-line remote execution while maintaining modular code structure.

.PARAMETER ServiceName
    The base name for the service/mailbox. Will be prompted if not provided.

.PARAMETER ForwardingEmail
    Email address to forward messages to. Auto-detected if not specified.

.PARAMETER Domain
    Domain for the shared mailbox. Extracted from ForwardingEmail if not specified.

.PARAMETER RandomLength
    Length of random component added to mailbox name. Default is 6 characters.

.PARAMETER StoreInMailbox
    Whether to also store messages in the shared mailbox. Default is $false (forward only).

.PARAMETER Help
    Display mexveil help information.

.PARAMETER KeepFiles
    Keep downloaded files after execution. Default is $false (cleanup).

.EXAMPLE
    curl https://raw.githubusercontent.com/quedalytix/mexveil/run.ps1 | pwsh
    Downloads and runs mexveil interactively

.EXAMPLE
    curl https://raw.githubusercontent.com/quedalytix/mexveil/run.ps1 | pwsh -Command "& {$input} -ServiceName 'support'"
    Downloads and runs mexveil with specified service name

.NOTES
    - Requires internet connection to download files
    - Downloads to temporary directory and cleans up by default
    - Maintains full functionality of the original mexveil script
    
.LINK
    https://github.com/quedalytix/mexveil
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ServiceName,
    
    [Parameter(Mandatory=$false)]
    [string]$ForwardingEmail,
    
    [Parameter(Mandatory=$false)]
    [string]$Domain,
    
    [Parameter(Mandatory=$false)]
    [ValidateRange(2, 20)]
    [int]$RandomLength = 6,
    
    [Parameter(Mandatory=$false)]
    [bool]$StoreInMailbox = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help,
    
    [Parameter(Mandatory=$false)]
    [switch]$KeepFiles
)

# GitHub raw URLs for the required files
$BaseUrl = "https://raw.githubusercontent.com/quedalytix/mexveil/main"
$MainScriptUrl = "$BaseUrl/mexveil.ps1"
$ModuleUrl = "$BaseUrl/mexveil.psm1"

try {
    Write-Host "=== mexveil Remote Installer ===" -ForegroundColor Cyan
    Write-Host "Downloading mexveil from GitHub..." -ForegroundColor Yellow
    
    # Create temporary directory
    $TempDir = Join-Path ([System.IO.Path]::GetTempPath()) "mexveil-$(Get-Random)"
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    Write-Host "Using temporary directory: $TempDir" -ForegroundColor Gray
    
    # Download main script
    $MainScriptPath = Join-Path $TempDir "mexveil.ps1"
    Write-Host "Downloading mexveil.ps1..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $MainScriptUrl -OutFile $MainScriptPath -UseBasicParsing
    
    # Download module
    $ModulePath = Join-Path $TempDir "mexveil.psm1"
    Write-Host "Downloading mexveil.psm1..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $ModuleUrl -OutFile $ModulePath -UseBasicParsing
    
    Write-Host "Download completed successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Prepare arguments to pass to the main script
    $ScriptArgs = @{}
    if ($ServiceName) { $ScriptArgs.ServiceName = $ServiceName }
    if ($ForwardingEmail) { $ScriptArgs.ForwardingEmail = $ForwardingEmail }
    if ($Domain) { $ScriptArgs.Domain = $Domain }
    if ($PSBoundParameters.ContainsKey('RandomLength')) { $ScriptArgs.RandomLength = $RandomLength }
    if ($PSBoundParameters.ContainsKey('StoreInMailbox')) { $ScriptArgs.StoreInMailbox = $StoreInMailbox }
    if ($Help) { $ScriptArgs.Help = $true }
    
    # Change to temp directory so $PSScriptRoot works correctly in mexveil.ps1
    $OriginalLocation = Get-Location
    Set-Location $TempDir
    
    # Execute the main script
    Write-Host "Executing mexveil..." -ForegroundColor Green
    & $MainScriptPath @ScriptArgs
    $ExitCode = $LASTEXITCODE
    
    # Return to original location
    Set-Location $OriginalLocation
    
} catch {
    Write-Error "Failed to download or execute mexveil: $($_.Exception.Message)"
    Write-Host "Please check your internet connection and try again." -ForegroundColor Red
    $ExitCode = 1
} finally {
    # Cleanup unless KeepFiles is specified
    if (-not $KeepFiles -and (Test-Path $TempDir)) {
        try {
            Write-Host "Cleaning up temporary files..." -ForegroundColor Gray
            Remove-Item $TempDir -Recurse -Force
        } catch {
            Write-Warning "Could not clean up temporary directory: $TempDir"
        }
    } elseif ($KeepFiles -and (Test-Path $TempDir)) {
        Write-Host "Files kept in: $TempDir" -ForegroundColor Yellow
    }
}

# Exit with the same code as the main script
if ($ExitCode) {
    exit $ExitCode
}
