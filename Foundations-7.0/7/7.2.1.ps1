# 7.2.1 Ensure modern authentication for SharePoint applications is required (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$TenantDomain = (Get-AcceptedDomain |
    Where-Object { $_.Default -eq $true }).DomainName

$TenantName = $TenantDomain.ToString().Split('.')[0]
$SPOAdminUrl = "https://$TenantName-admin.sharepoint.com"

Connect-SPOService -Url $SPOAdminUrl

Write-Host "SPOTenant.LegacyAuthProtocolsEnabled: $($SPOTenant.LegacyAuthProtocolsEnabled)"

if ($SPOTenant.LegacyAuthProtocolsEnabled -eq $false) {
    Write-Host "** PASS : Modern authentication for SharePoint applications is required. **"
} else {
    Write-Host "** FAIL : Legacy authentication for SharePoint applications is enabled. **"
}
