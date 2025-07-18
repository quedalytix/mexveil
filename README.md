# mexveil

**Microsoft Exchange Shared Mailbox Creator with Privacy Protection**

A PowerShell tool that creates shared mailboxes in Microsoft 365 with automatic forwarding and random naming components to protect your privacy and prevent spam from reaching your primary inbox.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Exchange Online](https://img.shields.io/badge/Exchange-Online-green.svg)](https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell)

## 🛡️ Privacy & Anti-Spam Protection

mexveil creates **isolated shared mailboxes** that act as privacy shields for your main email account. Perfect for newsletter signups, online shopping, service registrations, and any situation where you want to protect your primary inbox from potential spam.

### 📧 Why Shared Mailboxes Beat Email Aliases

| Feature | Shared Mailbox (mexveil) | Email Alias | Personal Email |
|---------|---------------------------|-------------|----------------|
| **Separate Storage** | ✅ Completely isolated | ❌ Mixed with personal | ❌ All in one place |
| **Hidden Original Email** | ✅ Sender never sees your real email | ❌ Visible in email headers | ❌ Fully exposed |
| **Easy Cleanup** | ✅ Delete entire mailbox instantly | ❌ Must clean personal inbox | ❌ Permanent inbox pollution |
| **Spam Isolation** | ✅ Contained, no impact on main account | ❌ Affects main account storage | ❌ Direct spam delivery |
| **Management Visibility** | ✅ Clear audit trail of all messages | ❌ Buried in personal email | ❌ Mixed with important emails |
| **Independent Permissions** | ✅ Granular access control | ❌ Tied to main account | ❌ Full account access |


## 🔧 Prerequisites

- **Microsoft 365 subscription** with Exchange Online
- **Domain ownership** and administrative access
- **PowerShell 5.1+** (included in Azure Cloud Shell)
- **Exchange Online permissions**:
  - Mail Recipients management
  - Mailbox creation rights
  - Permission assignment capabilities

## 🚀 Usage

### Quick Start (Remote Execution)

Open https://admin.cloud.microsoft/exchange#/mailboxes, click on cloud shell (top right button, next to a bell) and copy the following command:

```bash
# Interactive mode - will prompt for service name and auto-detect your email
curl https://raw.githubusercontent.com/quedalytix/mexveil/run.ps1 | pwsh
```

### Traditional Usage

```powershell
# Download and run locally
git clone https://github.com/quedalytix/mexveil.git
cd mexveil

# Simple usage with auto-detection
.\mexveil.ps1 -ServiceName "support"

# Specify all parameters
.\mexveil.ps1 -ServiceName "newsletter" -ForwardingEmail "me@mydomain.com" -RandomLength 8
```

### Advanced Examples

```powershell
# Create a shopping-specific mailbox with longer random component
.\mexveil.ps1 -ServiceName "shopping" -RandomLength 12

# Business inquiries with custom domain and storage
.\mexveil.ps1 -ServiceName "business" -Domain "company.com" -StoreInMailbox $true

# API notifications with shorter random component
.\mexveil.ps1 -ServiceName "api-alerts" -RandomLength 4 -ForwardingEmail "devops@company.com"

# Get help
.\mexveil.ps1 -Help
```

## 📖 Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ServiceName` | String | *Interactive* | Base name for the service/mailbox |
| `ForwardingEmail` | String | *Auto-detected* | Your email address (stays private) |
| `Domain` | String | *Auto-detected* | Domain for the shared mailbox |
| `RandomLength` | Integer | `6` | Length of privacy component (2-20 chars) |
| `StoreInMailbox` | Boolean | `$false` | Whether to store messages (forward-only default) |
| `Help` | Switch | - | Display detailed help information |

### 🤖 Auto-Detection (Cloud Shell Optimized)

mexveil automatically detects your email using multiple methods:

1. **Azure AD signed-in user** (works best in Cloud Shell)
2. **Exchange Online session context**  
3. **Azure context account ID**
4. **Interactive prompt** (fallback)

Works seamlessly in both Azure Cloud Shell and local PowerShell environments.

## 💡 Privacy Examples

### Example 1: Newsletter Protection
```powershell
.\mexveil.ps1 -ServiceName "newsletters"
# Creates: newsletters-x7k2m9@yourdomain.com
# Subscribe to newsletters with this address - your real email stays private!
```

### Example 2: Shopping Shield  
```powershell
.\mexveil.ps1 -ServiceName "shopping" -RandomLength 10
# Creates: shopping-a1b2c3d4e5@yourdomain.com
# Use for online purchases - isolate receipts and marketing emails
```

### Example 3: Temporary Project
```powershell
.\mexveil.ps1 -ServiceName "project-alpha" -StoreInMailbox $true
# Creates: project-alpha-m8n7q2@yourdomain.com
# Project-specific communications with full message storage
```

## 🔒 Security & Privacy Benefits

- **Email Harvesting Protection**: Random components prevent systematic email guessing
- **Sender Privacy**: Recipients never see your real email address
- **Spam Containment**: Bad actors can't directly target your main inbox
- **Easy Disposal**: Delete compromised mailboxes instantly
- **Audit Trail**: Track exactly what services have which addresses
- **Professional Image**: Custom service-specific addresses look professional

## 🛠️ Troubleshooting

### Azure Cloud Shell Issues

1. **Auto-detection fails**:
   ```powershell
   # Ensure you're logged into Azure
   Get-AzContext
   
   # If needed, login again
   Connect-AzAccount
   ```

2. **Exchange Online connection**:
   ```powershell
   # Check existing connections
   Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange"}
   
   # Manual connection if needed
   Connect-ExchangeOnline
   ```

### Common Issues

1. **"Access Denied"**: Verify Exchange Online admin permissions
2. **"Invalid email format"**: Check for typos in email addresses  
3. **"Module not found"**: Script auto-installs required modules
4. **"Domain not found"**: Ensure domain is properly configured in M365

### Getting Help

```powershell
# Built-in help system
Get-Help .\mexveil.ps1 -Detailed
Get-Help .\mexveil.ps1 -Examples

# Parameter-specific help  
Get-Help .\mexveil.ps1 -Parameter ServiceName
```

## ⚠️ Important Disclaimers

> **USE AT YOUR OWN RISK**

- **No Email Verification**: Tool doesn't validate email addresses exist
- **No Warranty**: Provided "AS IS" without guarantees
- **No Responsibility**: Authors not liable for misuse or issues
- **Testing Recommended**: Always test in non-production environment first
- **Compliance**: Verify alignment with organizational IT policies

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.
