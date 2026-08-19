# 7.2.9 Ensure guest access to a site or OneDrive will expire automatically (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}


# connect to SharePoint if not already connected
Import-Module Microsoft.Online.SharePoint.PowerShell -RequiredVersion 16.0.27111.12000
try { Get-SPOTenant -ErrorAction Stop | Out-Null }
catch { 
    $TenantDomain = Get-AcceptedDomain |
        Where-Object { $_.DomainName -like "*.onmicrosoft.com" -and $_.IsCoExistenceDomain -eq $false } |
        Select-Object -First 1 -ExpandProperty DomainName

    $TenantName = $TenantDomain.ToString().Split('.')[0]
    $SPOAdminUrl = "https://$TenantName-admin.sharepoint.com"

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
    $SPOTenant.ExternalUserExpireInDays -le 30
) {
    Write-Host "** PASS : Guest access expires automatically within 30 days. **"
} else {
    Write-Host "** FAIL : Guest access expiration is not correctly configured. **"
}
