# 5.1.5.5 Ensure new application passwords are system-generated (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$PasswordPolicy = Invoke-MgGraphRequest `
    -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/policies/defaultAppManagementPolicy"

$Policies = @(
    @{
        Name   = "Application"
        Policy = $PasswordPolicy.applicationRestrictions.passwordCredentials
    },
    @{
        Name   = "Service Principal"
        Policy = $PasswordPolicy.servicePrincipalRestrictions.passwordCredentials
    }
)

if (-not $PasswordPolicy.isEnabled) {
    Write-Host "** FAIL ** : Password Policy is disabled. **"
    return
}

$AuditReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $CustomPasswordPolicy = $Policy.Policy |
        Where-Object { $_.restrictionType -eq "customPasswordAddition" }

    $Obj = [PSCustomObject]@{
        Policy            = $Policy.Name
        State             = $CustomPasswordPolicy.state
        CreatedAfter      = $CustomPasswordPolicy.restrictForAppsCreatedAfterDateTime
        CreatedAfterValid = $false
        AuditState        = "PASS"
    }

    if ($Obj.CreatedAfter) {
        if ($Obj.CreatedAfter -eq "0001-01-01T00:00:00Z") {
            $Obj.CreatedAfterValid = $true
        }

        if ([datetime]$Obj.CreatedAfter -le (Get-Date)) {
            $Obj.CreatedAfterValid = $true
        }
    }

    if (-not $CustomPasswordPolicy) { $Obj.AuditState = "FAIL" }
    if (-not $Obj.CreatedAfterValid) { $Obj.AuditState = "FAIL" }
    if ($Obj.State -ne "enabled") { $Obj.AuditState = "FAIL" }

    $AuditReport.Add($Obj)
}

$PassingPolicies = $AuditReport | Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -eq @($AuditReport).Count) {
    Write-Host "** PASS : Compliant Password Policy found. **"
    $AuditReport | Format-Table -AutoSize
} else {
    Write-Host "** FAIL : Policy does not implement benchmark requirements. **"
    $AuditReport | Format-Table -AutoSize
}
