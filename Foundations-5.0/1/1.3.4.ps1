# 1.3.4 Ensure 'User owned apps and services' is restricted (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "OrgSettings-AppsAndServices.Read.All" -NoWelcome

$AuditState = "PASS"
$Uri = "https://graph.microsoft.com/beta/admin/appsAndServices/settings"
$AppsAndServicesStatus = Invoke-MgGraphRequest -Uri $Uri

Write-Host "isOfficeStoreEnabled: $($AppsAndServicesStatus.isOfficeStoreEnabled)"
if ($AppsAndServicesStatus.isOfficeStoreEnabled -eq $null) {
    Write-Host "** ERROR : Unable to retrieve User owned apps and services settings. **"
    return
} if ($AppsAndServicesStatus.isOfficeStoreEnabled -eq $true) {
    $AuditState = "FAIL"
} else {
    Write-Host "** PASS **"
}

Write-Host "isAppAndServicesTrialEnabled: $($AppsAndServicesStatus.isAppAndServicesTrialEnabled)"
if ($AppsAndServicesStatus.isAppAndServicesTrialEnabled -eq $null) {
    Write-Host "** ERROR : Unable to retrieve User owned apps and services settings. **"
    return
} elseif ($AppsAndServicesStatus.isAppAndServicesTrialEnabled -eq $true) {
    $AuditState = "FAIL"
} else {
    Write-Host "** PASS **"
}


