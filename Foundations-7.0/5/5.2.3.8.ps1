# 5.2.3.8 Ensure that Account 'Lockout threshold' is '10' or less (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Directory.Read.All" -NoWelcome

$PwRuleSettings = "5cf42378-d67d-4f36-ba46-e8b86229381d"

$PasswordSetting = Get-MgGroupSetting |
    Where-Object { $_.TemplateId -eq $PwRuleSettings }

$LockoutThreshold = (
    $PasswordSetting.Values |
        Where-Object { $_.Name -eq "LockoutThreshold" }
).Value

$Audit = [PSCustomObject]@{
    LockoutThreshold = $LockoutThreshold
    AuditState       = "PASS"
}

if ([int]$Audit.LockoutThreshold -gt 10) { $Audit.AuditState = "FAIL" }

$Audit | Format-List

if ($Audit.AuditState -eq "PASS") {
    Write-Host "** PASS : Account lockout threshold is set to 10 or less. **"
} else {
    Write-Host "** FAIL : Account lockout threshold is greater than 10. **"
}
