# 5.1.2.1 Ensure 'Per-user MFA' is disabled (Manual)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "User.Read.All","Policy.Read.All" -NoWelcome

$Users = Get-MgUser -All
$MFAReport = [System.Collections.Generic.List[Object]]::new()

foreach ($User in $Users) {

    $URI = "https://graph.microsoft.com/beta/users/$($User.Id)/authentication/requirements"
    $MFAState = Invoke-MgGraphRequest -Method GET -Uri $URI

    $Obj = [PSCustomObject]@{
        DisplayName       = $User.DisplayName
        UserPrincipalName = $User.UserPrincipalName
        PerUserMfaState   = $MFAState.perUserMfaState
        AuditState        = "PASS"
    }

    if ($Obj.PerUserMfaState -ne "disabled") { $Obj.AuditState = "FAIL" }
    $MFAReport.Add($Obj)
}

$FailingUsers = $MFAReport |
    Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingUsers).Count -gt 0) {
    Write-Host "** FAIL : Per-user MFA is enabled or enforced for one or more users. **"
    $FailingUsers | Format-List
} else {
    Write-Host "** PASS : Per-user MFA is disabled for all users. **"
    $MFAReport | Format-List
}