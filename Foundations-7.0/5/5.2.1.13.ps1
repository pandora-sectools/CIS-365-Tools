# 5.2.2.13 Ensure that periodic reauthentication is required for all users (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$URI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"
$Policies = (Invoke-MgGraphRequest -Method GET -Uri $URI).value

$PolicyReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $IncludedUsers   = @($Policy.conditions.users.includeUsers)
    $IncludedApps    = @($Policy.conditions.applications.includeApplications)
    $SignInRisk      = @($Policy.conditions.signInRiskLevels)
    $UserRisk        = @($Policy.conditions.userRiskLevels)
    $SignInFrequency = $Policy.sessionControls.signInFrequency

    $IntervalHours = $null

    if ($SignInFrequency.type -eq "days") {
        $IntervalHours = $SignInFrequency.value * 24
    }
    elseif ($SignInFrequency.type -eq "hours") {
        $IntervalHours = $SignInFrequency.value
    }

    $Obj = [PSCustomObject]@{
        DisplayName            = $Policy.displayName
        State                  = $Policy.state
        IncludeUsers           = $IncludedUsers -join ", "
        IncludeApplications    = $IncludedApps -join ", "
        FrequencyEnabled       = $SignInFrequency.isEnabled
        FrequencyInterval      = $SignInFrequency.frequencyInterval
        FrequencyType          = $SignInFrequency.type
        FrequencyValue         = $SignInFrequency.value
        IntervalHours          = $IntervalHours
        SignInRiskLevels       = $SignInRisk -join ", "
        UserRiskLevels         = $UserRisk -join ", "
        UserExclusions         = @($Policy.conditions.users.excludeUsers).Count
        AuditState             = "PASS"
    }

    if ($SignInRisk.Count -gt 0) { $Obj.AuditState = "EXCLUDED" }
    if ($UserRisk.Count -gt 0) { $Obj.AuditState = "EXCLUDED" }
    if ($Obj.AuditState -ne "EXCLUDED" -and $Obj.State -ne "enabled") { $Obj.AuditState = "FAIL" }
    if ($Obj.AuditState -ne "EXCLUDED" -and $IncludedUsers -notcontains "All") { $Obj.AuditState = "FAIL" }
    if ($Obj.AuditState -ne "EXCLUDED" -and $IncludedApps -notcontains "All") { $Obj.AuditState = "FAIL" }
    if ($Obj.AuditState -ne "EXCLUDED" -and $Obj.FrequencyEnabled -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.AuditState -ne "EXCLUDED" -and $Obj.FrequencyInterval -ne "timeBased") { $Obj.AuditState = "FAIL" }
    if ($Obj.AuditState -ne "EXCLUDED" -and ($null -eq $IntervalHours -or $IntervalHours -gt 168)) { $Obj.AuditState = "FAIL" }

    $PolicyReport.Add($Obj)
}

$PassingPolicies = $PolicyReport |
    Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -gt 0) {
    Write-Host "** PASS : Found a Conditional Access policy requiring periodic reauthentication every 7 days or less. **"
    $PassingPolicies | Format-List
} else {
    Write-Host "** FAIL : No qualifying Conditional Access policy requiring periodic reauthentication every 7 days or less was found. **"
    $PolicyReport | Format-List
}
