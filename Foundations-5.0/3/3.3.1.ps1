# 3.3.1 Ensure Information Protection sensitivity label policies are published (Automated)
# E3 Level 1
# E5 Level 1


# connect to Purview if not already connected
try { Get-RetentionCompliancePolicy -ErrorAction Stop | Out-Null }
catch { Connect-IPPSSession | Out-Null }

$LabelReport = [System.Collections.Generic.List[Object]]::new()

$LabelPolicies = Get-LabelPolicy -WarningAction Ignore |
    Where-Object { $_.Type -eq "PublishedSensitivityLabel" }

foreach ($Policy in $LabelPolicies) {

    $Obj = [PSCustomObject]@{
        Name             = $Policy.Name
        Type             = $Policy.Type
        ExchangeLocation = $Policy.ExchangeLocation
        ModernGroupLocation = $Policy.ModernGroupLocation
        OneDriveLocation = $Policy.OneDriveLocation
        SharePointLocation = $Policy.SharePointLocation
        AuditState       = "PASS"
    }

    $LabelReport.Add($Obj)
}

$PassingPolicies = $LabelReport |
    Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingPolicies).Count -gt 0) {
    Write-Host "** PASS : Found a published sensitivity label policy. **"
    $PassingPolicies | Format-List
} else {
    Write-Host "** FAIL : No published sensitivity label policies were found. **"
}
