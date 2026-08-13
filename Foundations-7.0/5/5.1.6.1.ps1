# 5.1.6.1 Ensure that collaboration invitations are sent to allowed domains only (Automated)
# E3 Level 2
# E5 Level 2

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

# Organization-approved domains permitted for collaboration invitations
$ApprovedDomains = @(
    "partner.example.com"
    "supplier.example.com"
)

$URI = "https://graph.microsoft.com/beta/legacy/policies"

$Policies = (Invoke-MgGraphRequest -Method GET -Uri $URI).value |
    Where-Object { $_.type -eq "B2BManagementPolicy" }

$PolicyReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $Definition = $Policy.definition | ConvertFrom-Json
    $DomainsPolicy = $Definition.B2BManagementPolicy.InvitationsAllowedAndBlockedDomainsPolicy

    $AllowedDomains = @($DomainsPolicy.AllowedDomains)
    $BlockedDomains = @($DomainsPolicy.BlockedDomains)
    $UnapprovedDomains = @(
        $AllowedDomains |
            Where-Object { $_ -notin $ApprovedDomains }
    )

    $Obj = [PSCustomObject]@{
        AllowedDomains    = $AllowedDomains -join ", "
        BlockedDomains    = $BlockedDomains -join ", "
        UnapprovedDomains = $UnapprovedDomains -join ", "
        AuditState        = "PASS"
    }

    if ($BlockedDomains.Count -gt 0) {
        $Obj.AuditState = "FAIL"
    }

    if ($UnapprovedDomains.Count -gt 0) {
        $Obj.AuditState = "FAIL"
    }

    $PolicyReport.Add($Obj)
}

$PassingPolicies = $PolicyReport |
    Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -gt 0) {
    Write-Host "** PASS : Collaboration invitations are restricted to allowed domains. **"
    $PassingPolicies | Format-List
} else {
    Write-Host "** FAIL : Collaboration invitations are not restricted to allowed domains. **"
    $PolicyReport | Format-List
}