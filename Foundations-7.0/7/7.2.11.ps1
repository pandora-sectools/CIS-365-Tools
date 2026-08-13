# 7.2.11 Ensure the SharePoint default sharing link permission is set (Automated)
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

# connect to SharePoint if not already connected
try {
    Get-SPOTenant -ErrorAction Stop | Out-Null
}
catch {
    # import first as a fix for the terrible module design.
    Import-Module Microsoft.Online.SharePoint.PowerShell -RequiredVersion 16.0.27111.12000
    Connect-SPOService -Url $SPOAdminUrl -UseSystemBrowser $true
}

$SPOTenant = Get-SPOTenant

Write-Host "SPOTenant.DefaultLinkPermission: $($SPOTenant.DefaultLinkPermission)"

if ($SPOTenant.DefaultLinkPermission -eq "View") {
    Write-Host "** PASS : The default sharing link permission is set to View. **"
} else {
    Write-Host "** FAIL : The default sharing link permission is not set to View. **"
}