# 5.2.2.3 Enable Conditional Access policies to block legacy authentication (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$URI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"
$Policies = (Invoke-MgGraphRequest -Method GET -Uri $URI).value

$PolicyReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $IncludedUsers  = @($Policy.conditions.users.includeUsers)
    $IncludedApps   = @($Policy.conditions.applications.includeApplications)
    $ClientAppTypes = @($Policy.conditions.clientAppTypes)
    $BuiltIn        = @($Policy.grantControls.builtInControls)

    $Obj = [PSCustomObject]@{
        DisplayName             = $Policy.displayName
        State                   = $Policy.state
        IncludeUsers            = $IncludedUsers -join ", "
        IncludeApplications     = $IncludedApps -join ", "
        ClientAppTypes          = $ClientAppTypes -join ", "
        BuiltInControls         = $BuiltIn -join ", "
        UserExclusions          = @($Policy.conditions.users.excludeUsers).Count
        ApplicationExclusions   = @($Policy.conditions.applications.excludeApplications).Count
        AuditState              = "PASS"
    }

    if ($Obj.State -ne "enabled") { $Obj.AuditState = "FAIL"}
    if ($IncludedUsers -notcontains "All") { $Obj.AuditState = "FAIL"}
    if ($IncludedApps -notcontains "All") { $Obj.AuditState = "FAIL" }
    if ($ClientAppTypes -notcontains "exchangeActiveSync") { $Obj.AuditState = "FAIL" }
    if ($ClientAppTypes -notcontains "other") { $Obj.AuditState = "FAIL" }
    if ($BuiltIn -notcontains "block") { $Obj.AuditState = "FAIL" }

    $PolicyReport.Add($Obj)
}

$PassingPolicies = $PolicyReport |
    Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -gt 0) {
    Write-Host "** PASS : Found a Conditional Access policy that blocks legacy authentication. **"
    $PassingPolicies | Format-List
} else {
    Write-Host "** FAIL : No qualifying Conditional Access policy blocking legacy authentication was found. **"
    $PolicyReport | Format-List
}
