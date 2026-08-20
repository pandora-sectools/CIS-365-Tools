# 1.3.6 Ensure the customer lockbox feature is enabled (Automated)
# E5 Level 2

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$LockboxStatus = Get-OrganizationConfig | Select-Object CustomerLockBoxEnabled
Write-Host "isOfficeStoreEnabled: $($LockboxStatus.CustomerLockBoxEnabled)"

if ($LockboxStatus.CustomerLockBoxEnabled -eq $true) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
