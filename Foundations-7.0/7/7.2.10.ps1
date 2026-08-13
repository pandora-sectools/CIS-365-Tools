# 7.2.10 Ensure reauthentication with verification code is restricted (Automated)
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
    EmailAttestationRequired   = $SPOTenant.EmailAttestationRequired
    EmailAttestationReAuthDays = $SPOTenant.EmailAttestationReAuthDays
}

$Audit | Format-List

if (
    $SPOTenant.EmailAttestationRequired -eq $true -and
    $SPOTenant.EmailAttestationReAuthDays -le 15
) {
    Write-Host "** PASS : Reauthentication with verification code is restricted. **"
} else {
    Write-Host "** FAIL : Reauthentication with verification code is not correctly restricted. **"
}