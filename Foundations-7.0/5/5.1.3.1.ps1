# 5.1.3.1 Ensure users cannot create security groups (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$UserTenantCreation = $(Get-MgPolicyAuthorizationPolicy).DefaultUserRolePermissions
$UserTenantCreation | Format-List AllowedToCreateSecurityGroups

if ($UserTenantCreation.AllowedToCreateSecurityGroups) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
