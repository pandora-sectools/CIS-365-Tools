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

$AuditReport = foreach ($Policy in $Policies) {

    $CustomPasswordPolicy = $Policy.Policy |
        Where-Object { $_.restrictionType -eq "customPasswordAddition" }

    $CreatedAfterValid = (
        $CustomPasswordPolicy.restrictForAppsCreatedAfterDateTime -eq "0001-01-01T00:00:00Z" -or
        [datetime]$CustomPasswordPolicy.restrictForAppsCreatedAfterDateTime -le (Get-Date)
    )

    [PSCustomObject]@{
        Policy            = $Policy.Name
        State             = $CustomPasswordPolicy.state
        CreatedAfter      = $CustomPasswordPolicy.restrictForAppsCreatedAfterDateTime
        CreatedAfterValid = $CreatedAfterValid
        AuditState        = (
            $CustomPasswordPolicy.state -eq "enabled" -and
            $CreatedAfterValid
        )
    }
}

$AuditReport | Format-Table -AutoSize

if (
    $PasswordPolicy.isEnabled -eq $true -and
    ($AuditReport.AuditState -notcontains $false)
) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
