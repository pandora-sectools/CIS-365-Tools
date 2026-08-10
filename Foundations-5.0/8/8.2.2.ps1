# 8.2.2 Ensure communication with unmanaged Teams users is disabled (Automated)
# E3 Level 1
# E5 Level 1

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$UnmanagedComsStatus = Get-CsExternalAccessPolicy -Identity Global 
$UnmanagedComsStatus | Format-List EnableTeamsConsumerAccess

if ($UnmanagedComsStatus.EnableTeamsConsumerAccess) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
