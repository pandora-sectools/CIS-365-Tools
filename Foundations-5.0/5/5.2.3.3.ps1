# 5.2.3.3 Ensure password protection is enabled for on-prem Active Directory (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Directory.Read.All" -NoWelcome

$PwRuleSettings = "5cf42378-d67d-4f36-ba46-e8b86229381d"

$PasswordSetting = Get-MgGroupSetting |
    Where-Object { $_.TemplateId -eq $PwRuleSettings }

$EnableOnPrem = (
    $PasswordSetting.Values |
        Where-Object { $_.Name -eq "EnableBannedPasswordCheckOnPremises" }
).Value

$OnPremMode = (
    $PasswordSetting.Values |
        Where-Object { $_.Name -eq "BannedPasswordCheckOnPremisesMode" }
).Value

$Audit = [PSCustomObject]@{
    EnableBannedPasswordCheckOnPremises = $EnableOnPrem
    BannedPasswordCheckOnPremisesMode   = $OnPremMode
    AuditState                          = "PASS"
}

if ($Audit.EnableBannedPasswordCheckOnPremises -ne "True") { $Audit.AuditState = "FAIL" }
if ($Audit.BannedPasswordCheckOnPremisesMode -ne "Enforce") { $Audit.AuditState = "FAIL" }

$Audit | Format-List

if ($Audit.AuditState -eq "PASS") {
    Write-Host "** PASS : Password protection for on-prem Active Directory is enabled and enforced. **"
} else {
    Write-Host "** FAIL : Password protection for on-prem Active Directory is not correctly configured. **"
}