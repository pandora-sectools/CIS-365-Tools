# 6.5.1 Ensure modern authentication for Exchange Online is enabled (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$OrganizationConfig = Get-OrganizationConfig

Write-Host "OrganizationConfig.OAuth2ClientProfileEnabled: $($OrganizationConfig.OAuth2ClientProfileEnabled)"

if ($OrganizationConfig.OAuth2ClientProfileEnabled -eq $true) {
    Write-Host "** PASS : Modern authentication for Exchange Online is enabled. **"
} else {
    Write-Host "** FAIL : Modern authentication for Exchange Online is disabled. **"
}