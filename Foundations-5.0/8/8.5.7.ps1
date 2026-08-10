# 8.5.7 Ensure external participants can't give or request control (Automated)
# E3 Level 1
# E5 Level 1

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$ExternalControlStatus = Get-CsTeamsMeetingPolicy -Identity Global
$ExternalControlStatus | Format-List AllowExternalParticipantGiveRequestControl

if ($ExternalControlStatus.AllowExternalParticipantGiveRequestControl) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
