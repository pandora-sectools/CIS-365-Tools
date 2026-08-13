# 5.1.4.5 Ensure Local Administrator Password Solution is enabled (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$DeviceRegistrationPolicy = Invoke-MgGraphRequest `
    -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/policies/deviceRegistrationPolicy"

$AzureADJoin = $DeviceRegistrationPolicy.localAdminPassword
Write-Host "LocalAdminPassword Enabled: $($AzureADJoin.isEnabled)"

if ($AzureADJoin.isEnabled -eq $true) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
