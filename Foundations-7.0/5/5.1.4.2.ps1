# 5.1.4.2 Ensure the maximum number of devices per user is limited (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$DeviceRegistrationPolicy = Invoke-MgGraphRequest `
    -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/policies/deviceRegistrationPolicy"

Write-Host "User Device Quota: $($DeviceRegistrationPolicy.userDeviceQuota)"

if ($DeviceRegistrationPolicy.userDeviceQuota -le 10) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
