# 7.2.9 Ensure guest access to a site or OneDrive will expire automatically (Automated)
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

$Audit = [PSCustomObject]@{
    ExternalUserExpirationRequired = $SPOTenant.ExternalUserExpirationRequired
    ExternalUserExpireInDays       = $SPOTenant.ExternalUserExpireInDays
}

$Audit | Format-List

if (
    $SPOTenant.ExternalUserExpirationRequired -eq $true -and
    $SPOTenant.ExternalUserExpireInDays -eq 30
) {
    Write-Host "** PASS : Guest access expires automatically after 30 days. **"
} else {
    Write-Host "** FAIL : Guest access expiration is not correctly configured. **"
}