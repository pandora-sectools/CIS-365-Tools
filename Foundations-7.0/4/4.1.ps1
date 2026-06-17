# 4.1 Ensure devices without a compliance policy are marked 'not compliant' (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "DeviceManagementConfiguration.Read.All" -NoWelcome
$URI = "https://graph.microsoft.com/v1.0/deviceManagement/settings"

$DeviceManagementSettings = Invoke-MgGraphRequest -Method GET -Uri $URI
$DeviceManagementSettings | Format-List secureByDefault

if ($DeviceManagementSettings.secureByDefault) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
