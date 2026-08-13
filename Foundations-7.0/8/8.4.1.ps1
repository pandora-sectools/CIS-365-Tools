# 8.2.4 Ensure the organization cannot communicate with accounts in trial Teams tenants (Automated)
# E3 Level 1
# E5 Level 1

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$TrialComsStatus = Get-CsTenantFederationConfiguration -Identity Global

Write-Host "TenantFederationConfiguration.ExternalAccessWithTrialTenants: $($TrialComsStatus.ExternalAccessWithTrialTenants)"

if ($TrialComsStatus.ExternalAccessWithTrialTenants -eq "Blocked") {
    Write-Host "** PASS : Communication with trial Teams tenants is blocked. **"
} else {
    Write-Host "** FAIL : Communication with trial Teams tenants is allowed. **"
}