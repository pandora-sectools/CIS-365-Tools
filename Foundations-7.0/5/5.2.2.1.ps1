# 5.2.2.1 Ensure multifactor authentication is enabled for all users in administrative roles (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$RequiredRoles = @(
    "62e90394-69f5-4237-9190-012177145e10" # Global Administrator
    "194ae4cb-b126-40b2-bd5b-6091b380977d" # Security Administrator
    "29232cdf-9323-42fd-ade2-1d097af3e4de" # Exchange Administrator
    "f28a1f50-f6e7-4571-818b-6a12f2af6b6c" # SharePoint Administrator
    "fe930be7-5e62-47db-91af-98c3a49a38b1" # User Administrator
    "729827e3-9c14-49f7-bb1b-9608f156bbb8" # Helpdesk Administrator
    "9360feb5-f418-4baa-8175-e2a00bac4301" # Directory Synchronization Accounts
    "b0f54661-2d74-4c50-afa3-1ec803f12efe" # Billing Administrator
    "3a2c62db-5318-420d-8d74-23affee5d9d5" # Intune Administrator
    "158c047a-c907-4556-b7ef-446551a6b5f7" # Cloud Application Administrator
    "44367163-eba1-44c3-98af-f5787879f96a" # Authentication Administrator
    "7be44c8a-adaf-4e2a-84d6-ab2649e08a13" # Privileged Authentication Administrator
    "e8611ab8-c189-46e8-94e1-60213ab1f814" # Privileged Role Administrator
    "5d6b6bb7-de71-4623-b4af-96380a352509" # Security Reader
    "17315797-102d-40b4-93e0-432062caca18" # Compliance Manager
    "2b745bdf-0803-4d80-aa65-822c4493daac" # Compliance Administrator
    "11648597-926c-4cf3-9c36-bcebb0ba8dcc" # Power Platform Administrator
    "a9ea8996-122f-4c74-9520-8edcd192826c" # Power BI Administrator
    "7698a772-787b-4ac8-901f-60d6b08affd2" # Cloud Device Administrator
    "8424c6f0-a189-499e-bbd0-26c1753c96d4" # Global Reader
    "59d46f88-662b-457b-bceb-5c3809e5908f" # Guest Inviter
    "3edaf663-341e-4475-9f94-5c398ef6c070" # Attribute Definition Administrator
    "74ef975b-6605-40af-a5d2-b9539d836353" # Attribute Assignment Administrator
    "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9" # Conditional Access Administrator
    "9f06204d-73c1-4d4c-880a-6edb90606fd8" # Application Administrator
    "4d6ac14f-3453-41d0-bef9-a3e0c569773a" # License Administrator
    "f023fd81-a637-4b56-95fd-791ac0226033" # Service Support Administrator
    "d37c8bed-0711-4417-ba38-b4abe66ce4c2" # Network Administrator
)

$URI = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies"
$Policies = (Invoke-MgGraphRequest -Method GET -Uri $URI).value

$PolicyReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $Policies) {

    $IncludedRoles = @($Policy.conditions.users.includeRoles)
    $IncludedApps  = @($Policy.conditions.applications.includeApplications)
    $BuiltIn       = @($Policy.grantControls.builtInControls)
    $AuthStrength  = $Policy.grantControls.authenticationStrength.id

    $HasAdminRoles = @(
        $RequiredRoles | Where-Object { $_ -in $IncludedRoles }
    ).Count -gt 0

    $HasMFA = (
        $BuiltIn -contains "mfa" -or
        -not [string]::IsNullOrWhiteSpace($AuthStrength)
    )

    $Obj = [PSCustomObject]@{
        DisplayName            = $Policy.displayName
        State                  = $Policy.state
        IncludesAdminRoles     = $HasAdminRoles
        IncludeApplications    = $IncludedApps -join ", "
        BuiltInControls        = $BuiltIn -join ", "
        AuthenticationStrength = $AuthStrength
        UserExclusions         = @($Policy.conditions.users.excludeUsers).Count
        ApplicationExclusions  = @($Policy.conditions.applications.excludeApplications).Count
        AuditState             = "PASS"
    }

    if ($Obj.State -ne "enabled") {
        $Obj.AuditState = "FAIL"
    }

    if ($Obj.IncludesAdminRoles -ne $true) {
        $Obj.AuditState = "FAIL"
    }

    if ($IncludedApps -notcontains "All") {
        $Obj.AuditState = "FAIL"
    }

    if ($HasMFA -ne $true) {
        $Obj.AuditState = "FAIL"
    }

    $PolicyReport.Add($Obj)
}

$PassingPolicies = $PolicyReport |
    Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -gt 0) {
    Write-Host "** PASS : Found a compliant MFA Conditional Access policy for administrative roles. **"
    $PassingPolicies | Format-List
} else {
    Write-Host "** FAIL : No qualifying MFA Conditional Access policy for administrative roles was found. **"
    $PolicyReport | Format-List
}
