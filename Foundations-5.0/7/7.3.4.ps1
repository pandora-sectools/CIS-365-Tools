# 7.3.4 Ensure custom script execution is restricted on site collections (Automated)
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


$Sites = Get-SPOSite -Limit All |
    Where-Object { $_.Url -notlike "*-my.sharepoint.com/" }

$SiteReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Site in $Sites) {

    $Obj = [PSCustomObject]@{
        Title                      = $Site.Title
        Url                        = $Site.Url
        DenyAddAndCustomizePages   = $Site.DenyAddAndCustomizePages
        AuditState                 = "PASS"
    }

    if ($Obj.DenyAddAndCustomizePages -ne "Enabled") { $Obj.AuditState = "FAIL" }
    $SiteReport.Add($Obj)
}

$FailingSites = $SiteReport |
    Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingSites).Count -gt 0) {
    Write-Host "** FAIL : Custom script execution is not restricted on one or more site collections. **"
    $FailingSites | Format-List
} else {
    Write-Host "** PASS : Custom script execution is restricted on all site collections. **"
    $SiteReport | Format-List
}
