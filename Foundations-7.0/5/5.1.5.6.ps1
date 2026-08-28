# 5.1.5.6 Ensure maximum certificate lifetime for applications does not exceed 180 days (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$CertificatePolicy = Invoke-MgGraphRequest `
    -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/policies/defaultAppManagementPolicy"

$Policies = @(
    @{
        Name   = "Application"
        Policy = $CertificatePolicy.applicationRestrictions.keyCredentials
    },
    @{
        Name   = "Service Principal"
        Policy = $CertificatePolicy.servicePrincipalRestrictions.keyCredentials
    }
)

if (-not $CertificatePolicy.isEnabled) {
    Write-Host "** FAIL : Certificate Policy is disabled. **"
    return
}

$AuditReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $CertificateLifetime = $Policy.Policy |
        Where-Object { $_.restrictionType -eq "asymmetricKeyLifetime" }

    $Obj = [PSCustomObject]@{
        Policy            = $Policy.Name
        State             = $CertificateLifetime.state
        MaxLifetime       = $CertificateLifetime.maxLifetime
        MaxLifetimeDays   = $null
        CreatedAfter      = $CertificateLifetime.restrictForAppsCreatedAfterDateTime
        CreatedAfterValid = $false
        AuditState        = "PASS"
    }

    if ($CertificateLifetime.maxLifetime) {
        $Obj.MaxLifetimeDays = [System.Xml.XmlConvert]::ToTimeSpan(
            $CertificateLifetime.maxLifetime
        ).TotalDays
    }

    if ($Obj.CreatedAfter) {
        if ($Obj.CreatedAfter -eq "0001-01-01T00:00:00Z") {
            $Obj.CreatedAfterValid = $true
        }

        if ([datetime]$Obj.CreatedAfter -le (Get-Date)) {
            $Obj.CreatedAfterValid = $true
        }
    }

    if (-not $CertificateLifetime) { $Obj.AuditState = "FAIL" }
    if ($null -eq $Obj.MaxLifetimeDays) { $Obj.AuditState = "FAIL" }
    if ($Obj.MaxLifetimeDays -gt 180) { $Obj.AuditState = "FAIL" }
    if (-not $Obj.CreatedAfterValid) { $Obj.AuditState = "FAIL" }
    if ($Obj.State -ne "enabled") { $Obj.AuditState = "FAIL" }

    $AuditReport.Add($Obj)
}

$PassingPolicies = $AuditReport | Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -eq @($AuditReport).Count) {
    Write-Host "** PASS : Compliant Certificate Policy found. **"
    $AuditReport | Format-Table -AutoSize
} else {
    Write-Host "** FAIL : Policy does not implement benchmark requirements. **"
    $AuditReport | Format-Table -AutoSize
}
