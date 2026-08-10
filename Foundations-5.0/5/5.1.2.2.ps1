# 5.1.2.2 Ensure users cannot register applications (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$UserAppRegistrationStatus = $(Get-MgPolicyAuthorizationPolicy).DefaultUserRolePermissions
$UserAppRegistrationStatus | Format-List AllowedToCreateApps

if ($UserAppRegistrationStatus.AllowedToCreateApps) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
