# 7.2.8 Ensure external sharing is restricted by security group (Automated)
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


$SPOTenant = Get-SPOTenant

$SecurityGroups = @(
    $SPOTenant.WhoCanShareAuthenticatedGuestAllowList
)

$Audit = [PSCustomObject]@{
    SharingCapability                         = $SPOTenant.SharingCapability
    WhoCanShareAuthenticatedGuestAllowList    = $SecurityGroups -join ", "
}

$Audit | Format-List

if ($SPOTenant.SharingCapability -eq "Disabled") {
    Write-Host "** PASS : External sharing is disabled. **"
}
elseif ($SecurityGroups.Count -gt 0) {
    Write-Host "** PASS : External sharing is restricted by security group. **"
}
else {
    Write-Host "** FAIL : External sharing is not restricted by security group. **"
}
