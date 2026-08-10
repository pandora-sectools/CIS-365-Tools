# 8.5.2 Ensure anonymous users and dial-in callers can't start a meeting (Automated)
# E3 Level 1
# E5 Level 1

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$AnonDialStatus = Get-CsTeamsMeetingPolicy -Identity Global 
$AnonDialStatus | Format-List AllowAnonymousUsersToStartMeeting

if ($AnonDialStatus.AllowAnonymousUsersToStartMeeting) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
