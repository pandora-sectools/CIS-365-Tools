# 5.1.4.1 Ensure the ability to join devices to Entra is restricted (Automated)
# E3 Level 2
# E5 Level 2

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$PassStatus = @(
    "#microsoft.graph.enumeratedDeviceRegistrationMembership",
    "#microsoft.graph.noDeviceRegistrationMembership"
)

$DeviceRegistrationPolicy = Invoke-MgGraphRequest `
    -Method GET `
    -Uri "https://graph.microsoft.com/beta/policies/deviceRegistrationPolicy"

$AzureADJoin = $DeviceRegistrationPolicy.azureADJoin
$AzureADJoin | Format-List allowedToJoin

if ($PassStatus -contains $azureADJoin.allowedToJoin.'@odata.type') {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
