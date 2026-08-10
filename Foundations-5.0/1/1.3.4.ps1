# 1.3.4 Ensure 'User owned apps and services' is restricted (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "OrgSettings-AppsAndServices.Read.All" -NoWelcome

$Uri = "https://graph.microsoft.com/beta/admin/appsAndServices/settings"
$AppsAndServicesStatus = Invoke-MgGraphRequest -Uri $Uri

if ($AppsAndServicesStatus.isOfficeStoreEnabled  -or $AppsAndServicesStatus.isAppAndServicesTrialEnabled) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}

$AppsAndServicesStatus | Format-Table isOfficeStoreEnabled, isAppAndServicesTrialEnabled -AutoSize
