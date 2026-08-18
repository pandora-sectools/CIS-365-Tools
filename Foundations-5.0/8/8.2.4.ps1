# 8.2.4 Ensure communication with Skype users is disabled (Automated)
# E3 Level 1
# E5 Level 1

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

try {
    $FederationConfig = Get-CsTenantFederationConfiguration -Identity Global -ErrorAction Stop

    $Audit = [PSCustomObject]@{
        AllowPublicUsers = $FederationConfig.AllowPublicUsers
        AuditState       = "PASS"
    }

    if ($Audit.AllowPublicUsers -eq $true) { $Audit.AuditState = "FAIL" }
    if ($Audit.AllowPublicUsers -eq $null) { $Audit.AuditState = "NOTAPPLICABLE"} 
    $Audit | Format-List
}
catch {
    Write-Host "** PASS : Skype communication setting is no longer available in this tenant. **"
    return
}

if ($Audit.AuditState -eq "PASS") {
    Write-Host "** PASS : Communication with Skype users is disabled. **"
}elseif ($Audit.AuditState -eq "NOTAPPLICABLE") {
    Write-Host "** PASS : Skype communication setting is no longer available in this tenant. **"
} else {
    Write-Host "** FAIL : Communication with Skype users is enabled. **"
}
