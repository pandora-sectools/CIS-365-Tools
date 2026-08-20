# 5.2.2.10 Ensure a managed device is required to register security information (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$URI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"
$Policies = (Invoke-MgGraphRequest -Method GET -Uri $URI).value

$PolicyReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $IncludedUsers       = @($Policy.conditions.users.includeUsers)
    $IncludedUserActions = @($Policy.conditions.applications.includeUserActions)
    $BuiltIn             = @($Policy.grantControls.builtInControls)
    $Operator            = $Policy.grantControls.operator

    $InvalidControls = @(
        $BuiltIn |
            Where-Object { $_ -notin @("compliantDevice","domainJoinedDevice") }
    )

    $Obj = [PSCustomObject]@{
        DisplayName        = $Policy.displayName
        State              = $Policy.state
        IncludeUsers       = $IncludedUsers -join ", "
        IncludeUserActions = $IncludedUserActions -join ", "
        BuiltInControls    = $BuiltIn -join ", "
        InvalidControls    = $InvalidControls -join ", "
        Operator           = $Operator
        UserExclusions     = @($Policy.conditions.users.excludeUsers).Count
        AuditState         = "PASS"
    }

    if ($Obj.State -ne "enabled") { $Obj.AuditState = "FAIL" }
    if ($IncludedUsers -notcontains "All") { $Obj.AuditState = "FAIL" }
    if ($IncludedUserActions -notcontains "urn:user:registersecurityinfo") { $Obj.AuditState = "FAIL" }
    if ($BuiltIn -notcontains "compliantDevice") { $Obj.AuditState = "FAIL" }
    if ($InvalidControls.Count -gt 0) { $Obj.AuditState = "FAIL" }
    if ($Obj.Operator -ne "OR") { $Obj.AuditState = "FAIL" }

    $PolicyReport.Add($Obj)
}

$PassingPolicies = $PolicyReport |
    Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -gt 0) {
    Write-Host "** PASS : Found a Conditional Access policy requiring a managed device to register security information. **"
    $PassingPolicies | Format-List
} else {
    Write-Host "** FAIL : No qualifying Conditional Access policy requiring a managed device to register security information was found. **"
    $PolicyReport | Format-List
}
