# 5.2.3.1 Ensure Microsoft Authenticator is configured to protect against MFA fatigue (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.AuthenticationMethod" -NoWelcome

$URI = "https://graph.microsoft.com/beta/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/MicrosoftAuthenticator"

try {
    $Authenticator = Invoke-MgGraphRequest -Method GET -Uri $URI -ErrorAction Stop
}
catch {
    Write-Host "** ERROR : Unable to retrieve Microsoft Authenticator configuration. **"
    return
}

$FeatureSettings = @($Authenticator.featureSettings)

$NumberMatching = $FeatureSettings |
    Where-Object { $_.feature -eq "numberMatchingRequiredState" } |
    Select-Object -First 1

$ApplicationName = $FeatureSettings |
    Where-Object { $_.feature -eq "displayAppInformationRequiredState" } |
    Select-Object -First 1

$GeographicLocation = $FeatureSettings |
    Where-Object { $_.feature -eq "displayLocationInformationRequiredState" } |
    Select-Object -First 1

$IncludeTargets = @($Authenticator.includeTargets)

$Audit = [PSCustomObject]@{
    State                     = $Authenticator.state
    IncludeTargets            = ($IncludeTargets.id -join ", ")
    NumberMatchingState       = $NumberMatching.state
    NumberMatchingTarget      = ($NumberMatching.includeTarget.id -join ", ")
    ApplicationNameState      = $ApplicationName.state
    ApplicationNameTarget     = ($ApplicationName.includeTarget.id -join ", ")
    GeographicLocationState   = $GeographicLocation.state
    GeographicLocationTarget  = ($GeographicLocation.includeTarget.id -join ", ")
    AuditState                = "PASS"
}

if ($Audit.State -ne "enabled") { $Audit.AuditState = "FAIL" }
if ($Audit.IncludeTargets -ne "all_users") { $Audit.AuditState = "FAIL" }
if ($Audit.NumberMatchingState -ne "enabled") { $Audit.AuditState = "FAIL" }
if ($Audit.NumberMatchingTarget -ne "all_users") { $Audit.AuditState = "FAIL" }
if ($Audit.ApplicationNameState -ne "enabled") { $Audit.AuditState = "FAIL" }
if ($Audit.ApplicationNameTarget -ne "all_users") { $Audit.AuditState = "FAIL" }
if ($Audit.GeographicLocationState -ne "enabled") { $Audit.AuditState = "FAIL" }
if ($Audit.GeographicLocationTarget -ne "all_users") { $Audit.AuditState = "FAIL" }

$Audit | Format-List

if ($Audit.AuditState -eq "PASS") {
    Write-Host "** PASS : Microsoft Authenticator is configured to protect against MFA fatigue. **"
} else {
    Write-Host "** FAIL : Microsoft Authenticator is not correctly configured to protect against MFA fatigue. **"
}