# 5.1.4.4 Ensure local administrator assignment is limited during Entra join (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$PassStatus = @(
    "#microsoft.graph.enumeratedDeviceRegistrationMembership",
    "#microsoft.graph.noDeviceRegistrationMembership"
)

$DeviceRegistrationPolicy = Invoke-MgGraphRequest `
    -Method GET `
    -Uri "https://graph.microsoft.com/beta/policies/deviceRegistrationPolicy"

$AzureADJoin = $DeviceRegistrationPolicy.azureADJoin.localAdmins
$AzureADJoin | Format-List registeringUsers

if ($PassStatus -contains $AzureADJoin.registeringUsers.'@odata.type') {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
