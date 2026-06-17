# 8.2.3 Ensure external Teams users cannot initiate conversations (Automated)
# E3 Level 1
# E5 Level 1

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$ExternalInitStatus = Get-CsExternalAccessPolicy -Identity Global 
$ExternalInitStatus | Format-List EnableTeamsConsumerInbound

if ($ExternalInitStatus.EnableTeamsConsumerInbound) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
