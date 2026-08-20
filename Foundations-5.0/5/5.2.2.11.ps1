# 5.2.2.11 Ensure sign-in frequency for Intune Enrollment is set to 'Every time' (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$IntuneEnrollmentAppId = "d4ebce55-015a-49b5-a083-c84d1797ae8c"

$URI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"
$Policies = (Invoke-MgGraphRequest -Method GET -Uri $URI).value

$PolicyReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $IncludedUsers   = @($Policy.conditions.users.includeUsers)
    $IncludedApps    = @($Policy.conditions.applications.includeApplications)
    $BuiltIn         = @($Policy.grantControls.builtInControls)
    $AuthStrength    = $Policy.grantControls.authenticationStrength.id
    $SignInFrequency = $Policy.sessionControls.signInFrequency

    $HasMFA = (
        $BuiltIn -contains "mfa" -or
        -not [string]::IsNullOrWhiteSpace($AuthStrength)
    )

    $Obj = [PSCustomObject]@{
        DisplayName            = $Policy.displayName
        State                  = $Policy.state
        IncludeUsers           = $IncludedUsers -join ", "
        IncludeApplications    = $IncludedApps -join ", "
        BuiltInControls        = $BuiltIn -join ", "
        AuthenticationStrength = $AuthStrength
        SignInFrequencyEnabled = $SignInFrequency.isEnabled
        FrequencyInterval      = $SignInFrequency.frequencyInterval
        UserExclusions         = @($Policy.conditions.users.excludeUsers).Count
        AuditState             = "PASS"
    }

    if ($Obj.State -ne "enabled") { $Obj.AuditState = "FAIL" }
    if ($IncludedUsers -notcontains "All") { $Obj.AuditState = "FAIL" }
    if ($IncludedApps -notcontains $IntuneEnrollmentAppId) { $Obj.AuditState = "FAIL" }
    if ($HasMFA -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.SignInFrequencyEnabled -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.FrequencyInterval -ne "everyTime") { $Obj.AuditState = "FAIL" }

    $PolicyReport.Add($Obj)
}

$PassingPolicies = $PolicyReport |
    Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -gt 0) {
    Write-Host "** PASS : Found a compliant Conditional Access policy for Microsoft Intune Enrollment. **"
    $PassingPolicies | Format-List
} else {
    Write-Host "** FAIL : No qualifying Conditional Access policy for Microsoft Intune Enrollment was found. **"
    $PolicyReport | Format-List
}
