# 5.1.4.3 Ensure the GA role is not added as a local administrator during Entra join (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$DeviceRegistrationPolicy = Invoke-MgGraphRequest `
    -Method GET `
    -Uri "https://graph.microsoft.com/beta/policies/deviceRegistrationPolicy"

$AzureADJoin = $DeviceRegistrationPolicy.azureADJoin
Write-Host "enableGlobalAdmins: $($azureADJoin.localAdmins.enableGlobalAdmins)"

if ($azureADJoin.localAdmins.enableGlobalAdmins) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
