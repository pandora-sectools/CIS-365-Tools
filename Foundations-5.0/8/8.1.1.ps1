# 8.1.1 Ensure external file sharing in Teams is enabled for only approved cloud storage services (Automated)
# E3 Level 2
# E5 Level 2

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$ShareProviders = @(
    'AllowDropbox',
    'AllowBox',
    'AllowGoogleDrive',
    'AllowShareFile',
    'AllowEgnyte'
)

$FileSharingStatus = Get-CsTeamsClientConfiguration -Identity Global
$FileSharingStatus | Format-List $ShareProviders
$TenancyPartialCompliant = $false

foreach ($Provider in $ShareProviders) {
    if ($FileSharingStatus.$Provider) {
        $TenancyPartialCompliant = $true
        break
    }
}

if ($TenancyPartialCompliant) {
    Write-Host "** PARTIAL : Please review enabled File Sharing platforms. **"
} else {
    Write-Host "** PASS : File Sharing is disabled. **"
}
