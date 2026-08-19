# 1.3.3 Ensure 'External sharing' of calendars is not available (Automated)
# E3 Level 2
# E5 Level 2

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$CalenderShareStatus = Get-SharingPolicy -Identity "Default Sharing Policy"
$CalenderShareStatus | Format-Table Name,Enabled

if ($CalenderShareStatus.Enabled) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
