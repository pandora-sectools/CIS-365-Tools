# 6.1.1 Ensure 'AuditDisabled' organizationally is set to 'False' (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$OrganizationConfig = Get-OrganizationConfig
$OrganizationConfig | Format-List AuditDisabled

if ($OrganizationConfig.AuditDisabled) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
