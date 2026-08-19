# 6.3.2 Ensure the ability to add personal email accounts and calendars is disabled (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$DefaultPolicy = Get-OwaMailboxPolicy |
    Where-Object { $_.IsDefault -eq $true }

$Audit = [PSCustomObject]@{
    Policy                          = $DefaultPolicy.Name
    PersonalAccountsEnabled         = $DefaultPolicy.PersonalAccountsEnabled
    PersonalAccountCalendarsEnabled = $DefaultPolicy.PersonalAccountCalendarsEnabled
}

$Audit | Format-List

if (
    $DefaultPolicy.PersonalAccountsEnabled -eq $false -and
    $DefaultPolicy.PersonalAccountCalendarsEnabled -eq $false
) {
    Write-Host "** PASS : Personal email accounts and calendars are disabled. **"
} else {
    Write-Host "** FAIL : Personal email accounts or calendars are enabled. **"
}
