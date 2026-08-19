# 2.1.3 Ensure notifications for internal users sending malware is Enabled (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

Write-Host "Get-MalwareFilterPolicy | Where-Object { $_.Name -eq `"Default`" }"
$DefaultPolicy = Get-MalwareFilterPolicy | Where-Object { $_.Name -eq "Default" }

$DefaultPolicy | Format-List Identity, EnableInternalSenderAdminNotifications, InternalSenderAdminAddress
