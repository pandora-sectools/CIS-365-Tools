# 8.2.1 Ensure external domains are restricted in the Teams admin center (Automated)
# E3 Level 2
# E5 Level 2

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$ExternalAccessPolicy = Get-CsExternalAccessPolicy -Identity Global
$FederationConfig = Get-CsTenantFederationConfiguration -Identity Global

$Audit = [PSCustomObject]@{
    EnableFederationAccess = $ExternalAccessPolicy.EnableFederationAccess
    AllowFederatedUsers    = $FederationConfig.AllowFederatedUsers
    AllowedDomains         = $FederationConfig.AllowedDomains
    AuditState             = "FAIL"
}

if ($Audit.EnableFederationAccess -eq $false) { $Audit.AuditState = "PASS" }
if ($Audit.AllowFederatedUsers -eq $false) { $Audit.AuditState = "PASS" }
if (
    $Audit.AllowFederatedUsers -eq $true -and
    $Audit.AllowedDomains -ne "AllowAllKnownDomains"
) { $Audit.AuditState = "PASS" }

$Audit | Format-List

if ($Audit.AuditState -eq "PASS") {
    Write-Host "** PASS : External domains are restricted. **"
} else {
    Write-Host "** FAIL : External domains are not restricted. **"
}