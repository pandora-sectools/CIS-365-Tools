# 8.5.3 Ensure only people in my org can bypass the lobby (Automated)
# E3 Level 1
# E5 Level 1

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$PassStatus = @(
    'InvitedUsers',                      # Only invited users can bypass the lobby.
    'EveryoneInCompanyExcludingGuests',  # Org users can bypass the lobby
    'OrganizerOnly'                      # only organizer can bypass lobby.
)

$OrgBypassStatus = Get-CsTeamsMeetingPolicy -Identity Global 
$OrgBypassStatus | Format-List AutoAdmittedUsers

if ($PassStatus -contains $OrgBypassStatus.AutoAdmittedUsers) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
