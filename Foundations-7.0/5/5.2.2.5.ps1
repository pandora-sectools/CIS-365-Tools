# 5.2.2.5 Ensure 'Phishing-resistant MFA strength' is required for Administrators (Automated)
# E3 Level 2
# E5 Level 2

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$RequiredRoles = @(
    "62e90394-69f5-4237-9190-012177145e10" # Global Administrator
    "194ae4cb-b126-40b2-bd5b-6091b380977d" # Security Administrator
    "29232cdf-9323-42fd-ade2-1d097af3e4de" # Exchange Administrator
    "f28a1f50-f6e7-4571-818b-6a12f2af6b6c" # SharePoint Administrator
    "fe930be7-5e62-47db-91af-98c3a49a38b1" # User Administrator
    "729827e3-9c14-49f7-bb1b-9608f156bbb8" # Helpdesk Administrator
    "b0f54661-2d74-4c50-afa3-1ec803f12efe" # Billing Administrator
    "158c047a-c907-4556-b7ef-446551a6b5f7" # Cloud Application Administrator
    "44367163-eba1-44c3-98af-f5787879f96a" # Authentication Administrator
    "7be44c8a-adaf-4e2a-84d6-ab2649e08a13" # Privileged Authentication Administrator
    "e8611ab8-c189-46e8-94e1-60213ab1f814" # Privileged Role Administrator
    "8424c6f0-a189-499e-bbd0-26c1753c96d4" # Global Reader
    "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9" # Conditional Access Administrator
    "9f06204d-73c1-4d4c-880a-6edb90606fd8" # Application Administrator
)

$AllowedCombinations = @(
    "windowsHelloForBusiness"
    "fido2"
    "x509CertificateMultiFactor"
)

$URI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"
$Policies = (Invoke-MgGraphRequest -Method GET -Uri $URI).value

$PolicyReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $IncludedRoles = @($Policy.conditions.users.includeRoles)
    $IncludedApps = @($Policy.conditions.applications.includeApplications)
    $AuthStrength = $Policy.grantControls.authenticationStrength
    $Combinations = @($AuthStrength.allowedCombinations)

    $HasAdminRoles = @(
        $RequiredRoles | Where-Object { $_ -in $IncludedRoles }
    ).Count -gt 0

    $InvalidCombinations = @(
        $Combinations |
            Where-Object { $_ -notin $AllowedCombinations }
    )

    $Obj = [PSCustomObject]@{
        DisplayName             = $Policy.displayName
        State                   = $Policy.state
        IncludesAdminRoles      = $HasAdminRoles
        IncludeApplications     = $IncludedApps -join ", "
        AuthenticationStrength  = $AuthStrength.id
        AllowedCombinations     = $Combinations -join ", "
        InvalidCombinations     = $InvalidCombinations -join ", "
        UserExclusions          = @($Policy.conditions.users.excludeUsers).Count
        ApplicationExclusions   = @($Policy.conditions.applications.excludeApplications).Count
        AuditState              = "PASS" }

    if ($Obj.State -ne "enabled") { $Obj.AuditState = "FAIL" }
    if ($Obj.IncludesAdminRoles -ne $true) { $Obj.AuditState = "FAIL" }
    if ($IncludedApps -notcontains "All") { $Obj.AuditState = "FAIL" }
    if ([string]::IsNullOrWhiteSpace($Obj.AuthenticationStrength)) { $Obj.AuditState = "FAIL" }
    if ($Combinations.Count -eq 0) { $Obj.AuditState = "FAIL" }
    if ($InvalidCombinations.Count -gt 0) { $Obj.AuditState = "FAIL" }

    $PolicyReport.Add($Obj)
}

$PassingPolicies = $PolicyReport |
    Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -gt 0) {
    Write-Host "** PASS : Found a phishing-resistant MFA Conditional Access policy for Administrators. **"
    $PassingPolicies | Format-List
} else {
    Write-Host "** FAIL : No qualifying phishing-resistant MFA Conditional Access policy for Administrators was found. **"
    $PolicyReport | Format-List
}