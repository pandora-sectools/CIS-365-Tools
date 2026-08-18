# 3.2.2 Ensure DLP policies are enabled for Microsoft Teams (Automated)
# E5 Level 1


# connect to Purview if not already connected
try { Get-RetentionCompliancePolicy -ErrorAction Stop | Out-Null }
catch { Connect-IPPSSession | Out-Null }

$Params = @(
    'Name',
    'Mode',
    'Workload',
    'TeamsLocation',
    'TeamsLocationException'
)

$DLPReport = [System.Collections.Generic.List[Object]]::new()
$DLPCompliancePolicy = Get-DlpCompliancePolicy | Select-Object -Property $Params

foreach ($Policy in $DLPCompliancePolicy) {

    $Obj = [PSCustomObject]@{
        Name                   = $Policy.Name
        Mode                   = $Policy.Mode
        Workload               = $Policy.Workload
        TeamsLocation          = $Policy.TeamsLocation
        TeamsLocationException = $Policy.TeamsLocationException
        AuditState             = "PASS"
    }

    if ($Obj.Workload -notmatch "Teams") { $Obj.AuditState = "FAIL" }
    if ($Obj.Mode -ne "Enable") { $Obj.AuditState = "FAIL" }
    if ($Obj.TeamsLocation -notcontains "All") { $Obj.AuditState = "FAIL" }

    $DLPReport.Add($Obj)
}

$PassingDLPs = $DLPReport | Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingDLPs).Count -gt 0) {
    Write-Host "** PASS : Found a compliant Microsoft Teams DLP Compliance Policy. **"
    $PassingDLPs | Format-List
} else {
    Write-Host "** FAIL : There are no qualifying Microsoft Teams DLP Compliance Policies. **"
    $DLPReport | Format-List
}
