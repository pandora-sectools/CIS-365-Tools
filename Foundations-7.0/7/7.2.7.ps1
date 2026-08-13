# 7.2.7 Ensure link sharing is restricted in SharePoint and OneDrive (Automated)
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

$PassStatus = @(
    "Direct"
    "Internal"
)

$SPOTenant = Get-SPOTenant

Write-Host "SPOTenant.DefaultSharingLinkType: $($SPOTenant.DefaultSharingLinkType)"

if ($PassStatus -contains $SPOTenant.DefaultSharingLinkType) {
    Write-Host "** PASS : Default sharing links are restricted. **"
} else {
    Write-Host "** FAIL : Default sharing links are not restricted. **"
}
