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

Connect-SPOService -Url $SPOAdminUrl

$SPOTenant = Get-SPOTenant

$PassStatus = @(
    "ExternalUserSharingOnly"
    "ExistingExternalUserSharingOnly"
    "Disabled"
)

Write-Host "SPOTenant.SharingCapability: $($SPOTenant.SharingCapability)"

if ($PassStatus -contains $SPOTenant.SharingCapability) {
    Write-Host "** PASS : External content sharing is restricted. **"
} else {
    Write-Host "** FAIL : External content sharing is not restricted. **"
}
