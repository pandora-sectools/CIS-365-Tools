# 3.2.3 Ensure DLP policies are published for Copilot users (Automated)
# E5 Level 1


# connect to Purview if not already connected
try { Get-RetentionCompliancePolicy -ErrorAction Stop | Out-Null }
catch { Connect-IPPSSession | Out-Null }

$Params = @(
    'Name',
    'Mode',
    'EnforcementPlanes',
    'LocationInclusions',
    'LocationExclusions'
)

$DLPReport = [System.Collections.Generic.List[Object]]::new()
$DLPCompliancePolicy = Get-DlpCompliancePolicy | Select-Object -Property $Params

foreach ($Policy in $DLPCompliancePolicy) {

    $Obj = [PSCustomObject]@{
        Name               = $Policy.Name
        Mode               = $Policy.Mode
        EnforcementPlanes  = $Policy.EnforcementPlanes
        LocationInclusions = $Policy.LocationInclusions
        LocationExclusions = $Policy.LocationExclusions
        AuditState         = "PASS"
    }

    if ($Obj.EnforcementPlanes -notmatch "CopilotExperiences") { $Obj.AuditState = "FAIL" }
    if ($Obj.Mode -ne "Enable") { $Obj.AuditState = "FAIL" }
    if ($Obj.LocationInclusions -notcontains "All") { $Obj.AuditState = "FAIL" }

    $DLPReport.Add($Obj)
}

$PassingDLPs = $DLPReport | Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingDLPs).Count -gt 0) {
    Write-Host "** PASS : Found a compliant Copilot DLP Compliance Policy. **"
    $PassingDLPs | Format-List
} else {
    Write-Host "** FAIL : There are no qualifying Copilot DLP Compliance Policies. **"
    $DLPReport | Format-List
}
