# 7.2.6 Ensure SharePoint external sharing is restricted (Automated)
# E3 Level 2
# E5 Level 2

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


# Organization-approved domains permitted for external sharing
$ApprovedDomains = @(
    "partner.example.com"
    "supplier.example.com"
)

$SPOTenant = Get-SPOTenant

$AllowedDomains = @(
    $SPOTenant.SharingAllowedDomainList -split '\s+' |
        Where-Object { $_ }
)

$UnapprovedDomains = @(
    $AllowedDomains |
        Where-Object { $_ -notin $ApprovedDomains }
)

$Audit = [PSCustomObject]@{
    SharingCapability            = $SPOTenant.SharingCapability
    SharingDomainRestrictionMode = $SPOTenant.SharingDomainRestrictionMode
    SharingAllowedDomainList     = $AllowedDomains -join ", "
    UnapprovedDomains            = $UnapprovedDomains -join ", "
}

$Audit | Format-List

if ($SPOTenant.SharingCapability -eq "Disabled") {
    Write-Host "** PASS : SharePoint external sharing is disabled. **"
}
elseif (
    $SPOTenant.SharingDomainRestrictionMode -eq "AllowList" -and
    $AllowedDomains.Count -gt 0 -and
    $UnapprovedDomains.Count -eq 0
) {
    Write-Host "** PASS : SharePoint external sharing is restricted to approved domains. **"
}
else {
    Write-Host "** FAIL : SharePoint external sharing is not correctly restricted. **"
}
