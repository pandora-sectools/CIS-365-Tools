# 5.2.3.5 Ensure weak authentication methods are disabled (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$Methods = (Get-MgPolicyAuthenticationMethodPolicy).AuthenticationMethodConfigurations

$MethodReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Method in $Methods | Where-Object { $_.Id -in @("Sms","Voice") }) {

    $Obj = [PSCustomObject]@{
        Id         = $Method.Id
        State      = $Method.State
        AuditState = "PASS"
    }

    if ($Obj.State -ne "disabled") { $Obj.AuditState = "FAIL" }

    $MethodReport.Add($Obj)
}

$SMS = $MethodReport | Where-Object { $_.Id -eq "Sms" }
$Voice = $MethodReport | Where-Object { $_.Id -eq "Voice" }

if (
    $SMS.State -eq "disabled" -and
    $Voice.State -eq "disabled"
) {
    Write-Host "** PASS : SMS and Voice authentication methods are disabled. **"
    $MethodReport | Format-List
} else {
    Write-Host "** FAIL : SMS and/or Voice authentication methods are not disabled. **"
    $MethodReport | Format-List
}
