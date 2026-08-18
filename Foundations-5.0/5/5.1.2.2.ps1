# 5.1.2.2 (L2) Ensure third party integrated applications are not allowed (Automated)
# E3 Level 2
# E5 Level 2

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$UserAppRegistrationStatus = $(Get-MgPolicyAuthorizationPolicy).DefaultUserRolePermissions
$UserAppRegistrationStatus | Format-List AllowedToCreateApps

if ($UserAppRegistrationStatus.AllowedToCreateApps) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
