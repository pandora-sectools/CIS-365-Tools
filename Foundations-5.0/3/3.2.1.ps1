# 3.2.1 Ensure DLP policies are enabled (Automated)
# E3 Level 1
# E5 Level 1


# connect to Purview if not already connected
try { Get-RetentionCompliancePolicy -ErrorAction Stop | Out-Null }
catch { Connect-IPPSSession | Out-Null }

$Params = @(
    'Mode',
    'ExchangeLocation',
    'SharePointLocation',
    'OneDriveLocation',
    'TeamsLocation'
)

$DLPReport = [System.Collections.Generic.List[Object]]::new()
$DLPCompliancePolicy = Get-DlpCompliancePolicy | Select-Object -Property $Params

foreach ($Policy in $DLPCompliancePolicy) {

    $Obj = [PSCustomObject]@{
        Mode               = $Policy.Mode
        HasLocation           = $false
        ExchangeLocation   = $Policy.ExchangeLocation
        SharePointLocation = $Policy.SharePointLocation
        OneDriveLocation   = $Policy.OneDriveLocation
        TeamsLocation      = $Policy.TeamsLocation
        AuditState         = "PASS"
    }
    
    foreach ($Param in $Params | Select-Object -Skip 1) {
        if (@($Obj.$Param).Count -gt 0) {
            $Obj.HasLocation = $true
            break
        }
    }

    if ($Obj.Mode -ne "Enable") { $Obj.AuditState = "FAIL" }
    if ($Obj.HasLocation -ne $true) { $Obj.AuditState = "FAIL" }
    $DLPReport.Add($Obj)
}


$PassingDLPs = $DLPReport | Where-Object { $_.AuditState -eq "PASS" }
if (@($PassingDLPs).Count -gt 0) {
    Write-Host "** PASS : Found a compliant DLP Compliance Policy. **"
    $PassingDLPs |Format-List
} else {
    Write-Host "** FAIL : There are no qualifying DLP Compliance Policies. **"
    $DLPReport |Format-List
}
