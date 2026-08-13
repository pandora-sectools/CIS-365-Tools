# 5.2.2.7 Enable Identity Protection sign-in risk policies (Automated)
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$URI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"
$Policies = (Invoke-MgGraphRequest -Method GET -Uri $URI).value

$PolicyReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $IncludedUsers    = @($Policy.conditions.users.includeUsers)
    $IncludedApps     = @($Policy.conditions.applications.includeApplications)
    $SignInRiskLevels = @($Policy.conditions.signInRiskLevels)
    $BuiltIn          = @($Policy.grantControls.builtInControls)
    $AuthStrength     = $Policy.grantControls.authenticationStrength.id
    $SignInFrequency  = $Policy.sessionControls.signInFrequency

    $HasMFA = (
        $BuiltIn -contains "mfa" -or
        -not [string]::IsNullOrWhiteSpace($AuthStrength)
    )

    $IsBlocked = $BuiltIn -contains "block"

    $Obj = [PSCustomObject]@{
        DisplayName            = $Policy.displayName
        State                  = $Policy.state
        IncludeUsers           = $IncludedUsers -join ", "
        IncludeApplications    = $IncludedApps -join ", "
        SignInRiskLevels       = $SignInRiskLevels -join ", "
        BuiltInControls        = $BuiltIn -join ", "
        AuthenticationStrength = $AuthStrength
        SignInFrequencyEnabled = $SignInFrequency.isEnabled
        FrequencyInterval      = $SignInFrequency.frequencyInterval
        UserExclusions         = @($Policy.conditions.users.excludeUsers).Count
        AuditState             = "PASS"
    }

    if ($Obj.State -ne "enabled") { $Obj.AuditState = "FAIL" }
    if ($IncludedUsers -notcontains "All") { $Obj.AuditState = "FAIL" }
    if ($IncludedApps -notcontains "All") { $Obj.AuditState = "FAIL" }
    if ($SignInRiskLevels -notcontains "high") { $Obj.AuditState = "FAIL" }
    if ($SignInRiskLevels -notcontains "medium") { $Obj.AuditState = "FAIL" }
    if (-not $IsBlocked -and $HasMFA -ne $true) { $Obj.AuditState = "FAIL" }
    if (-not $IsBlocked -and $Obj.SignInFrequencyEnabled -ne $true) { $Obj.AuditState = "FAIL" }
    if (-not $IsBlocked -and $Obj.FrequencyInterval -ne "everyTime") { $Obj.AuditState = "FAIL" }

    $PolicyReport.Add($Obj)
}

$PassingPolicies = $PolicyReport |
    Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -gt 0) {
    Write-Host "** PASS : Found a compliant Identity Protection sign-in risk policy. **"
    $PassingPolicies | Format-List
} else {
    Write-Host "** FAIL : No qualifying Identity Protection sign-in risk policy was found. **"
    $PolicyReport | Format-List
}