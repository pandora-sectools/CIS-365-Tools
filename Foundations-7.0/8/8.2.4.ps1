# 8.2.4 Ensure the organization cannot communicate with accounts in trial Teams tenants (Automated)
# E3 Level 1
# E5 Level 1

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$TrialComsStatus = Get-CsTenantFederationConfiguration -Identity Global 
$TrialComsStatus | Format-List ExternalAccessWithTrialTenants

if ($TrialComsStatus.ExternalAccessWithTrialTenants -ne "Blocked") {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
