# 5.2.3.10 Ensure Microsoft Authenticator on companion applications is disabled (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$URI = "https://graph.microsoft.com/beta/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/microsoftAuthenticator"
$Authenticator = Invoke-MgGraphRequest -Method GET -Uri $URI

$Audit = [PSCustomObject]@{
    CompanionAppAllowedState = $Authenticator.featureSettings.companionAppAllowedState.state
    AuditState               = "PASS"
}

if ($Audit.CompanionAppAllowedState -ne "disabled") { $Audit.AuditState = "FAIL" }

$Audit | Format-List

if ($Audit.AuditState -eq "PASS") {
    Write-Host "** PASS : Microsoft Authenticator on companion applications is disabled. **"
} else {
    Write-Host "** FAIL : Microsoft Authenticator on companion applications is not disabled. **"
}
