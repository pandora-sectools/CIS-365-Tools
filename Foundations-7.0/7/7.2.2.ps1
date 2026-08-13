# 7.2.2 Ensure SharePoint and OneDrive integration with Azure AD B2B is enabled (Automated)
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

Write-Host "SPOTenant.EnableAzureADB2BIntegration: $($SPOTenant.EnableAzureADB2BIntegration)"

if ($SPOTenant.EnableAzureADB2BIntegration -eq $true) {
    Write-Host "** PASS : SharePoint and OneDrive integration with Azure AD B2B is enabled. **"
} else {
    Write-Host "** FAIL : SharePoint and OneDrive integration with Azure AD B2B is disabled. **"
}
