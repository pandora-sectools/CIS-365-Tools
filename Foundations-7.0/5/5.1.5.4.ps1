# 5.1.5.4 Ensure password lifetime for applications does not exceed 180 days (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$PassLifetimePolicy = Invoke-MgGraphRequest `
    -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/policies/defaultAppManagementPolicy"

$Policies = @(
    @{
        Name   = "Application"
        Policy = $PassLifetimePolicy.applicationRestrictions.passwordCredentials
    },
    @{
        Name   = "Service Principal"
        Policy = $PassLifetimePolicy.servicePrincipalRestrictions.passwordCredentials
    }
)

if ( -not $PassLifetimePolicy.isEnabled ) {
    Write-Host "** FAIL ** : Pass Lifetime Policy is disabled. **"
    return
}

$AuditReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $PasswordLifetime = $Policy.Policy | 
        Where-Object { $_.restrictionType -eq "passwordLifetime" }

    $Obj = [PSCustomObject]@{
        Policy            = $Policy.Name
        State             = $PasswordLifetime.state
        MaxLifetime       = $PasswordLifetime.maxLifetime
        MaxLifetimeDays   = $null
        CreatedAfter      = $PasswordLifetime.restrictForAppsCreatedAfterDateTime
        CreatedAfterValid = $false
        AuditState        = "PASS"
    }

    if ($PasswordLifetime.MaxLifetime) {
        $Obj.MaxLifetimeDays = [System.Xml.XmlConvert]::ToTimeSpan( $PasswordLifetime.MaxLifetime ).TotalDays
    }
    
    if ($Obj.CreatedAfter) {
        if ($Obj.CreatedAfter -eq "0001-01-01T00:00:00Z") { $Obj.CreatedAfterValid = $true }
        if ([datetime]$Obj.CreatedAfter -le (Get-Date)) { $Obj.CreatedAfterValid = $true }
    }

    if ( -not $Obj.CreatedAfterValid ) {$Obj.AuditState = "FAIL"}
    if ( -not $PasswordLifetime) {$Obj.AuditState = "FAIL"}
    if ($null -eq $Obj.MaxLifetimeDays) {$Obj.AuditState = "FAIL"}
    if ( $Obj.MaxLifetimeDays -gt 180 ) { $Obj.AuditState = "FAIL" }
    if ( $Obj.State -ne "enabled" ) {$Obj.AuditState = "FAIL"}
    
    $AuditReport.add($Obj)
}

$PassingPolicies = $AuditReport | Where-Object { $_.AuditState -eq "PASS" }
if (@($PassingPolicies).Count -eq @($AuditReport).Count) {
    Write-Host "** PASS : Compliant Password Policy found.**"
    $AuditReport | Format-Table -AutoSize
} else {
    Write-Host "** FAIL : Policy does not implement benchmark requirements.**"
    $AuditReport | Format-Table -AutoSize
}
