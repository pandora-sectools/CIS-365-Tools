# 5.1.6.2 Ensure that guest user access is restricted (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$PassStatus = @(
    "10dae51f-b6af-4016-8d66-8c2a99b929b3"
    "2af84b1e-32c8-42b7-82bc-daa82404023b"
)

$AuthorizationPolicy = Get-MgPolicyAuthorizationPolicy

Write-Host "AuthorizationPolicy.GuestUserRoleId: $($AuthorizationPolicy.GuestUserRoleId)"

if ($PassStatus -contains $AuthorizationPolicy.GuestUserRoleId) {
    Write-Host "** PASS : Guest user access is restricted. **"
} else {
    Write-Host "** FAIL : Guest user access is not sufficiently restricted. **"
}
