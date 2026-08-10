# 8.5.5 Ensure meeting chat does not allow anonymous users (Automated)
# E3 Level 2
# E5 Level 2

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$PassStatus = @(
    'EnabledExceptAnonymous',                    
    'EnabledInMeetingOnlyForAllExceptAnonymous', 
    'Disabled'                                   
)

$AnonChatStatus = Get-CsTeamsMeetingPolicy -Identity Global
$AnonChatStatus | Format-List MeetingChatEnabledType

if ($PassStatus -contains $AnonChatStatus.MeetingChatEnabledType) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
