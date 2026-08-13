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

$AuditReport = foreach ($Policy in $Policies) {

    $PasswordLifetime = $Policy.Policy |
        Where-Object { $_.restrictionType -eq "passwordLifetime" }

    $MaxLifetimeDays = [System.Xml.XmlConvert]::ToTimeSpan(
        $PasswordLifetime.maxLifetime
    ).TotalDays

    $CreatedAfterValid = (
        $PasswordLifetime.restrictForAppsCreatedAfterDateTime -eq "0001-01-01T00:00:00Z" -or
        [datetime]$PasswordLifetime.restrictForAppsCreatedAfterDateTime -le (Get-Date)
    )

    $AuditState = (
        $PasswordLifetime.state -eq "enabled" -and
        $MaxLifetimeDays -le 180 -and
        $CreatedAfterValid
    )

    [PSCustomObject]@{
        Policy            = $Policy.Name
        State             = $PasswordLifetime.state
        MaxLifetime       = $PasswordLifetime.maxLifetime
        MaxLifetimeDays   = $MaxLifetimeDays
        CreatedAfter      = $PasswordLifetime.restrictForAppsCreatedAfterDateTime
        CreatedAfterValid = $CreatedAfterValid
        AuditState        = $AuditState
    }
}

$AuditReport | Format-Table -AutoSize

if (
    $PassLifetimePolicy.isEnabled -eq $true -and
    ($AuditReport.AuditState -notcontains $false)
) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
