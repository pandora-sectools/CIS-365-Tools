# 5.2.3.9 Ensure that Account 'Lockout duration in seconds' is at least 60 seconds (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Directory.Read.All" -NoWelcome

$PwRuleSettings = "5cf42378-d67d-4f36-ba46-e8b86229381d"

$PasswordSetting = Get-MgGroupSetting |
    Where-Object { $_.TemplateId -eq $PwRuleSettings }

$LockoutDurationInSeconds = (
    $PasswordSetting.Values |
        Where-Object { $_.Name -eq "LockoutDurationInSeconds" }
).Value

$Audit = [PSCustomObject]@{
    LockoutDurationInSeconds = $LockoutDurationInSeconds
    AuditState               = "PASS"
}

if ([int]$Audit.LockoutDurationInSeconds -lt 60) { $Audit.AuditState = "FAIL" }

$Audit | Format-List

if ($Audit.AuditState -eq "PASS") {
    Write-Host "** PASS : Account lockout duration is at least 60 seconds. **"
} else {
    Write-Host "** FAIL : Account lockout duration is less than 60 seconds. **"
}
