# 4.2 Ensure device enrollment for personally owned devices is blocked by default (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "DeviceManagementServiceConfig.Read.All" -NoWelcome

$URI = "https://graph.microsoft.com/beta/deviceManagement/deviceEnrollmentConfigurations"

$Config = (Invoke-MgGraphRequest -Method GET -Uri $URI).value |
    Where-Object {
        $_.id -match "DefaultPlatformRestrictions" -and
        $_.priority -eq 0
    }

$Audit = [PSCustomObject]@{
    Windows        = $Config.windowsRestriction.personalDeviceEnrollmentBlocked
    iOS            = $Config.iosRestriction.personalDeviceEnrollmentBlocked
    AndroidForWork = $Config.androidForWorkRestriction.personalDeviceEnrollmentBlocked
    MacOS          = $Config.macOSRestriction.personalDeviceEnrollmentBlocked
    Android        = $Config.androidRestriction.personalDeviceEnrollmentBlocked
}

$Audit | Format-List

if ($Audit.PSObject.Properties.Value -notcontains $false) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}