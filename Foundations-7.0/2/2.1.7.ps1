# 2.1.7 Ensure that an anti-phishing policy has been created (Automated)
# E5 Level 2

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$CompliantPolicy = $false
$CompliantRule = $false
$AntiPhishPolicies = Get-AntiPhishPolicy
$AntiPhishRules = Get-AntiPhishRule

ForEach ($Policy in $AntiPhishPolicies) {

    Write-Host "Checking policy: $($Policy.Name)"

    if ($Policy.Enabled -ne $true) { continue }
    if ($Policy.PhishThresholdLevel -ne 3) { continue }
    if ($Policy.EnableTargetedUserProtection -ne $true) { continue }
    if ($Policy.EnableOrganizationDomainsProtection -ne $true) { continue }
    if ($Policy.EnableMailboxIntelligence -ne $true) { continue }
    if ($Policy.EnableMailboxIntelligenceProtection -ne $true) { continue }
    if ($Policy.EnableSpoofIntelligence -ne $true) { continue }
    if ($Policy.TargetedUserProtectionAction -ne "Quarantine") { continue }
    if ($Policy.TargetedDomainProtectionAction -ne "Quarantine") { continue }
    if ($Policy.MailboxIntelligenceProtectionAction -ne "Quarantine") { continue }
    if ($Policy.EnableFirstContactSafetyTips -ne $true) { continue }
    if ($Policy.EnableSimilarUsersSafetyTips -ne $true) { continue }
    if ($Policy.EnableSimilarDomainsSafetyTips -ne $true) { continue }
    if ($Policy.EnableUnusualCharactersSafetyTips -ne $true) { continue }
    if (-not $Policy.TargetedUsersToProtect -or $Policy.TargetedUsersToProtect.Count -eq 0) { continue }
    if ($Policy.HonorDmarcPolicy -ne $true) { continue }

    # Policy passed all checks
    $CompliantPolicy = $Policy
    Write-Host "Found Valid policy!`n Now verify Rule Compliance.."

    foreach ($Rule in $AntiPhishRules) {
        Write-Host "Checking Rule:"
        
        if ($Rule.AntiPhishPolicy -ne $Policy.Name) { continue }
        if ($Rule.State -ne "Enabled") { continue }

        $RuleHasGroups = @($Rule.SentToMemberOf).Count -gt 0
        $RuleHasDomains = @($Rule.RecipientDomainIs).Count -gt 0
        if (-not ($RuleHasGroups -or -not $RuleHasDomains)) { continue }

        # Rule passed all checks
        $CompliantRule = $Rule
    }

    # Skip Testing if valid policy
    if ($CompliantPolicy -and $CompliantRule) { break }
}


if (-not $CompliantPolicy) {
    Write-Host "`n** FAIL : No anti-phishing policy meets all required settings. **"
}
elseif (-not $CompliantRule) {
    Write-Host "`n** FAIL : Compliant anti-phishing policy found, but no valid enforcement rule exists. **"
}
else {
    Write-Host "`n** PASS : Compliant anti-phishing policy found with enforcement rule. **"
    Write-Host "Policy Name: $($CompliantPolicy.Name)"
    Write-Host "Rule Name: $($CompliantRule.Name)"
    Write-Host "Rule Applied to Policy: $($CompliantRule.AntiPhishPolicy)"
    
    Write-Host "Protected Users: $($CompliantPolicy.TargetedUsersToProtect -join ', ')"
    Write-Host "Groups: $($CompliantRule.SentToMemberOf -join ', ')"
    Write-Host "Recipient Domains: $($CompliantRule.RecipientDomainIs -join ', ')"
}
