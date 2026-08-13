# 5.1.5.2 Ensure the admin consent workflow is enabled (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome


$AdminConsentFlowStatus = $(Get-MgPolicyAdminConsentRequestPolicy)
$AdminConsentFlowStatus | Format-List IsEnabled,NotifyReviewers,RemindersEnabled

if ($AdminConsentFlowStatus.IsEnabled) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
