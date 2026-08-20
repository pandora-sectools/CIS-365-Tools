# 5.2.3.2 Ensure custom banned passwords lists are used (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Directory.Read.All" -NoWelcome

$PwRuleSettings = "5cf42378-d67d-4f36-ba46-e8b86229381d"

$PasswordSetting = Get-MgGroupSetting |
    Where-Object { $_.TemplateId -eq $PwRuleSettings }

$EnableBannedPasswordCheck = (
    $PasswordSetting.Values |
        Where-Object { $_.Name -eq "EnableBannedPasswordCheck" }
).Value

$BannedPasswordList = (
    $PasswordSetting.Values |
        Where-Object { $_.Name -eq "BannedPasswordList" }
).Value

$Audit = [PSCustomObject]@{
    EnableBannedPasswordCheck = $EnableBannedPasswordCheck
    BannedPasswordList        = $BannedPasswordList
    AuditState                = "PASS"
}

if ($Audit.EnableBannedPasswordCheck -ne "True") { $Audit.AuditState = "FAIL" }
if ([string]::IsNullOrWhiteSpace($Audit.BannedPasswordList)) { $Audit.AuditState = "FAIL" }

$Audit | Format-List

if ($Audit.AuditState -eq "PASS") {
    Write-Host "** PASS : Custom banned password list is enabled and populated. **"
} else {
    Write-Host "** FAIL : Custom banned password list is not correctly configured. **"
}