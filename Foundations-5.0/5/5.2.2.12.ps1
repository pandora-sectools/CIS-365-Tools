# 5.2.2.12 Ensure the device code sign-in flow is blocked (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$URI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"
$Policies = (Invoke-MgGraphRequest -Method GET -Uri $URI).value

$PolicyReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $IncludedUsers   = @($Policy.conditions.users.includeUsers)
    $IncludedApps    = @($Policy.conditions.applications.includeApplications)
    $TransferMethods = @($Policy.conditions.authenticationFlows.transferMethods)
    $BuiltIn         = @($Policy.grantControls.builtInControls)

    $Obj = [PSCustomObject]@{
        DisplayName         = $Policy.displayName
        State               = $Policy.state
        IncludeUsers        = $IncludedUsers -join ", "
        IncludeApplications = $IncludedApps -join ", "
        TransferMethods     = $TransferMethods -join ", "
        BuiltInControls     = $BuiltIn -join ", "
        UserExclusions      = @($Policy.conditions.users.excludeUsers).Count
        AuditState          = "PASS"
    }

    if ($Obj.State -ne "enabled") { $Obj.AuditState = "FAIL" }
    if ($IncludedUsers -notcontains "All") { $Obj.AuditState = "FAIL" }
    if ($IncludedApps -notcontains "All") { $Obj.AuditState = "FAIL" }
    if ($TransferMethods -notcontains "deviceCodeFlow") { $Obj.AuditState = "FAIL" }
    if ($BuiltIn -notcontains "block") { $Obj.AuditState = "FAIL" }

    $PolicyReport.Add($Obj)
}

$PassingPolicies = $PolicyReport |
    Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -gt 0) {
    Write-Host "** PASS : Found a Conditional Access policy blocking device code flow. **"
    $PassingPolicies | Format-List
} else {
    Write-Host "** FAIL : No qualifying Conditional Access policy blocking device code flow was found. **"
    $PolicyReport | Format-List
}
