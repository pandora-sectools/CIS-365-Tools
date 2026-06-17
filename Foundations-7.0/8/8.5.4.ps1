# 8.5.4 Ensure users dialing in can't bypass the lobby (Automated)
# E3 Level 1
# E5 Level 1

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$PSTNDialStatus = Get-CsTeamsMeetingPolicy -Identity Global 
$PSTNDialStatus | Format-List AllowPSTNUsersToBypassLobby

if ($PSTNDialStatus.AllowPSTNUsersToBypassLobby) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
