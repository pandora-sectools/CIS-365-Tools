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

$AuditReport = foreach ($Policy in $Policies) {

    $CertificateLifetime = $Policy.Policy |
        Where-Object { $_.restrictionType -eq "asymmetricKeyLifetime" }

    $MaxLifetimeDays = [System.Xml.XmlConvert]::ToTimeSpan(
        $CertificateLifetime.maxLifetime
    ).TotalDays

    $CreatedAfterValid = (
        $CertificateLifetime.restrictForAppsCreatedAfterDateTime -eq "0001-01-01T00:00:00Z" -or
        [datetime]$CertificateLifetime.restrictForAppsCreatedAfterDateTime -le (Get-Date)
    )

    [PSCustomObject]@{
        Policy            = $Policy.Name
        State             = $CertificateLifetime.state
        MaxLifetime       = $CertificateLifetime.maxLifetime
        MaxLifetimeDays   = $MaxLifetimeDays
        CreatedAfter      = $CertificateLifetime.restrictForAppsCreatedAfterDateTime
        CreatedAfterValid = $CreatedAfterValid
        AuditState        = (
            $CertificateLifetime.state -eq "enabled" -and
            $MaxLifetimeDays -le 180 -and
            $CreatedAfterValid
        )
    }
}

$AuditReport | Format-Table -AutoSize

if (
    $CertificatePolicy.isEnabled -eq $true -and
    ($AuditReport.AuditState -notcontains $false)
) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
