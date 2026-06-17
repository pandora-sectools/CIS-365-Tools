# 5.1.2.3 Ensure 'Restrict non-admin users from creating tenants' is set to 'Yes' (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$UserTenantCreation = $(Get-MgPolicyAuthorizationPolicy).DefaultUserRolePermissions
$UserTenantCreation | Format-List AllowedToCreateTenants

if ($UserTenantCreation.AllowedToCreateTenants) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
