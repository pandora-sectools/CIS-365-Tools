# 5.2.2.2 Ensure multifactor authentication is enabled for all users (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$URI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"
$Policies = (Invoke-MgGraphRequest -Method GET -Uri $URI).value

$PolicyReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $IncludedUsers = @($Policy.conditions.users.includeUsers)
    $IncludedApps  = @($Policy.conditions.applications.includeApplications)
    $BuiltIn       = @($Policy.grantControls.builtInControls)
    $AuthStrength  = $Policy.grantControls.authenticationStrength.id

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
        UserExclusions         = @($Policy.conditions.users.excludeUsers).Count
        ApplicationExclusions  = @($Policy.conditions.applications.excludeApplications).Count
        AuditState             = "PASS"
    }

    if ($Obj.State -ne "enabled") {
        $Obj.AuditState = "FAIL"
    }

    if ($IncludedUsers -notcontains "All") {
        $Obj.AuditState = "FAIL"
    }

    if ($IncludedApps -notcontains "All") {
        $Obj.AuditState = "FAIL"
    }

    if ($HasMFA -ne $true) {
        $Obj.AuditState = "FAIL"
    }

    $PolicyReport.Add($Obj)
}

$PassingPolicies = $PolicyReport |
    Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -gt 0) {
    Write-Host "** PASS : Found a compliant MFA Conditional Access policy for all users. **"
    $PassingPolicies | Format-List
} else {
    Write-Host "** FAIL : No qualifying MFA Conditional Access policy for all users was found. **"
    $PolicyReport | Format-List
}
