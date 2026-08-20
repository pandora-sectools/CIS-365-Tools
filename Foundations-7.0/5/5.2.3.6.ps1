# 5.2.3.6 Ensure system-preferred multifactor authentication is enabled (Manual)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.AuthenticationMethod" -NoWelcome

$URI = "https://graph.microsoft.com/beta/policies/authenticationMethodsPolicy"

try {
    $SystemCredentialPreferences = (Invoke-MgGraphRequest -Method GET -Uri $URI -ErrorAction Stop).systemCredentialPreferences
}
catch {
    Write-Host "** ERROR : Unable to retrieve system-preferred multifactor authentication settings. **"
    return
}

$Audit = [PSCustomObject]@{
    State          = $SystemCredentialPreferences.state
    IncludeTargets = @($SystemCredentialPreferences.includeTargets).id -join ", "
    AuditState     = "PASS"
}

if ($null -eq $SystemCredentialPreferences.state) {
    Write-Host "** ERROR : Unable to retrieve system-preferred multifactor authentication state. **"
    return
}

if ($Audit.State -ne "enabled") { $Audit.AuditState = "FAIL" }
if ($Audit.IncludeTargets -ne "all_users") { $Audit.AuditState = "FAIL" }

$Audit | Format-List

if ($Audit.AuditState -eq "PASS") {
    Write-Host "** PASS : System-preferred multifactor authentication is enabled for all users. **"
} else {
    Write-Host "** FAIL : System-preferred multifactor authentication is not enabled for all users. **"
}
