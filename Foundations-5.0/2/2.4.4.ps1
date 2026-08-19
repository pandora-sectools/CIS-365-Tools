# 2.4.4 Ensure Zero-hour auto purge for Microsoft Teams is on (Automated)
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$ZapPolicy = Get-TeamsProtectionPolicy
$ZapPolicy | Format-List ZapEnabled
$ZapExceptions = Get-TeamsProtectionPolicyRule | Select-Object ExceptIf*

if ($ZapPolicy.ZapEnabled -ne $true) {
    Write-Host "** FAIL : Zero-Hour AutoPurge is disabled on the Tenancy."
} elseif (@($ZapExceptions).Count -gt 0) {
    Write-Host "** PARTIAL : Please review ZAP exceptions. **"
    $ZapExceptions | Format-List
} else {
    Write-Host "** PASS : Zero-Hour AutoPurge is enabled without exceptions."
}
