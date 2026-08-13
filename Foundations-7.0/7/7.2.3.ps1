# 7.2.3 Ensure external content sharing is restricted (Automated)
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
    "ExternalUserSharingOnly"
    "ExistingExternalUserSharingOnly"
    "Disabled"
)

$SPOTenant = Get-SPOTenant
Write-Host "SPOTenant.SharingCapability: $($SPOTenant.SharingCapability)"

if ($PassStatus -contains $SPOTenant.SharingCapability) {
    Write-Host "** PASS : External content sharing is restricted. **"
} else {
    Write-Host "** FAIL : External content sharing is not restricted. **"
}
