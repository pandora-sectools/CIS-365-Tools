# 8.1.2 Ensure users can't send emails to a channel email address (Automated)
# E3 Level 1
# E5 Level 1

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$ChannelAddressStatus = Get-CsTeamsClientConfiguration -Identity Global 
$ChannelAddressStatus | Format-List AllowEmailIntoChannel

if ($ChannelAddressStatus.AllowEmailIntoChannel) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
