# 5.2.2.17 Ensure authentication transfer is blocked (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$Policies = Get-MgIdentityConditionalAccessPolicy

$AuditReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $Obj = [PSCustomObject]@{
        PolicyName             = $Policy.DisplayName
        State                  = $Policy.State
        AuthenticationTransfer = $false
        BlockAccess            = $false
        AuditState             = "PASS"
    }

    if ($Policy.Conditions.AuthenticationFlows.TransferMethods -contains "deviceCodeFlow") {
        $Obj.AuthenticationTransfer = $true
    }

    if ($Policy.GrantControls.BuiltInControls -contains "block") {
        $Obj.BlockAccess = $true
    }

    if (-not $Obj.AuthenticationTransfer) { $Obj.AuditState = "FAIL" }
    if (-not $Obj.BlockAccess) { $Obj.AuditState = "FAIL" }
    if ($Obj.State -ne "enabled") { $Obj.AuditState = "FAIL" }

    $AuditReport.Add($Obj)
}

$PassingPolicies = $AuditReport | Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -gt 0) {
    Write-Host "** PASS : Conditional Access Policy found blocking Authentication Transfer. **"
    $PassingPolicies | Format-Table -AutoSize
} else {
    Write-Host "** FAIL : No enabled Conditional Access Policy found blocking Authentication Transfer. **"
    $AuditReport | Format-Table -AutoSize
}
