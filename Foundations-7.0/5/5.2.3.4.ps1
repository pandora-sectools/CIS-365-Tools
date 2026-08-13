# 5.2.3.4 Ensure all member users are 'MFA capable' (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "UserAuthenticationMethod.Read.All","AuditLog.Read.All" -NoWelcome

$Users = Get-MgReportAuthenticationMethodUserRegistrationDetail `
    -Filter "IsMfaCapable eq false and UserType eq 'Member'"

$MFAReport = [System.Collections.Generic.List[Object]]::new()

foreach ($User in $Users) {

    $Obj = [PSCustomObject]@{
        UserPrincipalName = $User.UserPrincipalName
        IsMfaCapable      = $User.IsMfaCapable
        IsAdmin           = $User.IsAdmin
        AuditState        = "PASS"
    }

    if ($Obj.IsMfaCapable -ne $true) { $Obj.AuditState = "FAIL" }

    $MFAReport.Add($Obj)
}

$FailingUsers = $MFAReport |
    Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingUsers).Count -eq 0) {
    Write-Host "** PASS : All member users are MFA capable. **"
} else {
    Write-Host "** FAIL : Found member users that are not MFA capable. **"
    $FailingUsers | Format-List
}
