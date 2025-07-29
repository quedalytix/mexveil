<#
.SYNOPSIS
    PowerShell module for mexveil - Microsoft Exchange Veil functions

.DESCRIPTION
    This module contains the core functions used by mexveil for creating
    shared mailboxes with random naming and automatic forwarding.

.NOTES
    Part of the mexveil project
    https://github.com/quedalytix/mexveil
#>

function Get-RandomString {
    <#
    .SYNOPSIS
        Generates a random string of specified length
    
    .DESCRIPTION
        Creates a random string using lowercase letters and numbers
    
    .PARAMETER length
        Length of the random string to generate (default: 6)
    
    .EXAMPLE
        Get-RandomString -length 8
        Returns a random 8-character string like "a1b2c3d4"
    #>
    param (
        [int]$length = 6
    )
    $characters = 'abcdefghijklmnopqrstuvwxyz0123456789'
    return -join ((1..$length) | ForEach-Object { $characters[(Get-Random -Maximum $characters.Length)] })
}

function Get-CurrentUserEmail {
    <#
    .SYNOPSIS
        Attempts to auto-detect the current user's email address
    
    .DESCRIPTION
        Uses Azure AD and Azure context to detect the current user's email.
        Designed to work in Azure Cloud Shell environments.
    
    .OUTPUTS
        String. The user's email address, or $null if not found
    
    .EXAMPLE
        $email = Get-CurrentUserEmail
        if ($email) { Write-Host "Found email: $email" }
    #>
    try {
        # Azure AD current user (primary method for Cloud Shell)
        $currentUser = Get-AzADUser -SignedIn -ErrorAction SilentlyContinue
        if ($currentUser -and $currentUser.Mail) {
            return $currentUser.Mail
        }
        if ($currentUser -and $currentUser.UserPrincipalName) {
            return $currentUser.UserPrincipalName
        }
        
        # Fallback: Azure context account ID
        $azContext = Get-AzContext -ErrorAction SilentlyContinue
        if ($azContext -and $azContext.Account.Id -and $azContext.Account.Id.Contains('@')) {
            return $azContext.Account.Id
        }
        
        return $null
    }
    catch {
        return $null
    }
}

function Get-DomainFromEmail {
    <#
    .SYNOPSIS
        Extracts the domain portion from an email address
    
    .DESCRIPTION
        Splits an email address and returns the domain part after the @ symbol
    
    .PARAMETER Email
        The email address to extract the domain from
    
    .OUTPUTS
        String. The domain portion of the email, or $null if invalid
    
    .EXAMPLE
        Get-DomainFromEmail -Email "user@example.com"
        Returns "example.com"
    #>
    param (
        [string]$Email
    )
    
    if ($Email -and $Email.Contains('@')) {
        return $Email.Split('@')[1]
    }
    return $null
}

# Export the functions so they can be used when the module is imported
Export-ModuleMember -Function Get-RandomString, Get-CurrentUserEmail, Get-DomainFromEmail
