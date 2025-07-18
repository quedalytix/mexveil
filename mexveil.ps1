<#
.SYNOPSIS
    Creates shared mailboxes in Microsoft 365 with automatic forwarding and random naming.

.DESCRIPTION
    mexveil creates shared mailboxes that automatically forward to a predefined email address,
    adding a random component to protect against reverse engineering. Designed for domain 
    owners with Microsoft 365/Exchange Online.

.PARAMETER ServiceName
    The base name for the service/mailbox. Required if not provided interactively.

.PARAMETER ForwardingEmail
    Email address to forward messages to. If not specified, attempts to auto-detect current user's email.

.PARAMETER Domain
    Domain for the shared mailbox. If not specified, extracts from ForwardingEmail.

.PARAMETER RandomLength
    Length of random component added to mailbox name. Default is 6 characters.

.PARAMETER StoreInMailbox
    Whether to also store messages in the shared mailbox. Default is $false (forward only).

.PARAMETER Help
    Display this help information.

.EXAMPLE
    .\mexveil.ps1 -ServiceName "support"
    Creates a shared mailbox like "support-a1b2c3d4@yourdomain.com" forwarding to auto-detected email.

.EXAMPLE
    .\mexveil.ps1 -ServiceName "billing" -ForwardingEmail "admin@company.com" -RandomLength 6
    Creates a shared mailbox with 6-character random component forwarding to admin@company.com.

.EXAMPLE
    .\mexveil.ps1 -ServiceName "contact" -StoreInMailbox $true
    Creates a shared mailbox that both forwards and stores messages in the shared mailbox.

.EXAMPLE
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/quedalytix/mexveil/main/mexveil.ps1" -UseBasicParsing | Invoke-Expression
    Direct execution mode - runs interactively, prompting for service name and auto-detecting email.

.NOTES
    - Requires ExchangeOnlineManagement PowerShell module
    - Requires appropriate Exchange Online permissions
    - No email validation is performed - use at your own risk
    - Random component helps protect against reverse engineering
    
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
    [switch]$Help
)


if ($Help) {
    Get-Help $MyInvocation.MyCommand.Definition -Detailed
    return
}

# Import the mexveil module for core functions
$ModulePath = Join-Path $PSScriptRoot "mexveil.psm1"
if (Test-Path $ModulePath) {
    Import-Module $ModulePath -Force
} else {
    Write-Error "mexveil module not found at: $ModulePath"
    Write-Host "Please ensure mexveil.psm1 is in the same directory as this script." -ForegroundColor Red
    exit 1
}

# Main script execution
try {
    Write-Host "=== mexveil - Microsoft Exchange Veil - Shared Mail Generator ===" -ForegroundColor Cyan
    Write-Host "Creating privacy-focused shared mailbox with forwarding..." -ForegroundColor Green
    
    # Yep, this isn't by default in the cloud shell
    if (!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
        Write-Host "Installing Exchange Online Management module..." -ForegroundColor Yellow
        Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber -Scope CurrentUser
    }

    Write-Host "Connecting to Exchange Online..." -ForegroundColor Yellow
    Import-Module ExchangeOnlineManagement
    Connect-ExchangeOnline

    # Get service name if not provided
    if (-not $ServiceName) {
        $ServiceName = Read-Host "Enter the service name"
        if (-not $ServiceName) {
            throw "Service name is required"
        }
    }

    # Auto-detect or get forwarding email
    if (-not $ForwardingEmail) {
        Write-Host "Auto-detecting forwarding email..." -ForegroundColor Yellow
        $ForwardingEmail = Get-CurrentUserEmail
        
        if (-not $ForwardingEmail) {
            $ForwardingEmail = Read-Host "Enter the forwarding email address"
            if (-not $ForwardingEmail) {
                throw "Forwarding email is required"
            }
        } else {
            Write-Host "Auto-detected forwarding email: $ForwardingEmail" -ForegroundColor Green
        }
    }

    # simple validation, could be improved
    if (-not ($ForwardingEmail -match '^[^@]+@[^@]+\.[^@]+$')) {
        throw "Invalid email format: $ForwardingEmail"
    }


    if (-not $Domain) {
        $Domain = Get-DomainFromEmail -Email $ForwardingEmail
        if ($Domain) {
            Write-Host "Auto-detected domain: $Domain" -ForegroundColor Green
        } else {
            $Domain = Read-Host "Enter the domain for the shared mailbox"
            if (-not $Domain) {
                throw "Domain is required"
            }
        }
    }

  
    $randomPart = Get-RandomString -length $RandomLength
    Write-Host "Generated random component: $randomPart" -ForegroundColor Green

    # Using dash for clear separation
    $mailboxName = "$ServiceName-$randomPart".ToLower()
    $fullMailboxAddress = "$mailboxName@$Domain"

    Write-Host "Creating shared mailbox: $fullMailboxAddress" -ForegroundColor Cyan
    New-Mailbox -Shared -Name $mailboxName -DisplayName $mailboxName -PrimarySmtpAddress $fullMailboxAddress

    Write-Host "Configuring forwarding to: $ForwardingEmail" -ForegroundColor Yellow
    Set-Mailbox -Identity $mailboxName -ForwardingAddress $ForwardingEmail -DeliverToMailboxAndForward $StoreInMailbox

    Write-Host "Granting full access permissions..." -ForegroundColor Yellow
    Add-MailboxPermission -Identity $mailboxName -User $ForwardingEmail -AccessRights FullAccess -InheritanceType All

    Write-Host "Granting Send As permissions..." -ForegroundColor Yellow
    Add-RecipientPermission -Identity $mailboxName -Trustee $ForwardingEmail -AccessRights SendAs -Confirm:$false

    Write-Host "`n=== Configuration Summary ===" -ForegroundColor Cyan
    Write-Host "Shared Mailbox: $fullMailboxAddress" -ForegroundColor White
    Write-Host "Forwarding To: $ForwardingEmail" -ForegroundColor White
    Write-Host "Store in Mailbox: $StoreInMailbox" -ForegroundColor White
    Write-Host "Random Length: $RandomLength characters" -ForegroundColor White
    Write-Host "`nShared mailbox has been created and configured successfully!" -ForegroundColor Green

    Write-Host "`nDisconnecting from Exchange Online..." -ForegroundColor Yellow
    Disconnect-ExchangeOnline -Confirm:$false

} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    Write-Host "Please check your parameters and try again." -ForegroundColor Red
    
    # Ensure we disconnect even on error
    try {
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    } catch {
        # Ignore disconnect errors
    }
    
    exit 1
}
