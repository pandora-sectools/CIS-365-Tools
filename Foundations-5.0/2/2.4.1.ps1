# 2.4.1 Ensure Priority account protection is enabled and configured (Automated)
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

# connect to Purview if not already connected
try { Get-RetentionCompliancePolicy -ErrorAction Stop | Out-Null }
catch { Connect-IPPSSession | Out-Null }

$EmailTenantSettings = Get-EmailTenantSettings
$EmailTenantSettings | Format-List EnablePriorityAccountProtection

if (-not $EmailTenantSettings.EnablePriorityAccountProtection) {
    Write-Host "** FAIL - Priority Account Protection is disabled.**"
    return
}

$PAReport = [System.Collections.Generic.List[Object]]::new()
$ProtectionAlerts = Get-ProtectionAlert | Where-Object { $_.RecipientTags -Match 'Priority account' }

if (@($ProtectionAlerts).Count -lt 1) {
    Write-Host "** FAIL - No Protections Alerts exist.**"
    return
}


foreach ($Alert in $ProtectionAlerts) {
    
    $Obj = [pscustomobject][ordered]@{
        Name                          = $Alert.Name
        Severity                      = $Alert.Severity
        Filter                        = $Alert.Filter
        RecipientTags                 = $Alert.RecipientTags
        NotificationEnabled           = $Alert.NotificationEnabled
        NotifyUser                    = $Alert.NotifyUser
        Disabled                      = $Alert.Disabled
        ThreatType                    = $Alert.ThreatType
        AuditState                    = "PASS"
    }

    if ($Obj.Severity -ne "High") {$Obj.AuditState = "FAIL"}
    if ($Obj.Filter -notmatch "Mail\.Direction\s+-eq\s+'Inbound'") {$Obj.AuditState = "FAIL"}
    if (($Obj.RecipientTags -join ';') -notmatch "Priority account") {$Obj.AuditState = "FAIL"}
    if ($Obj.NotificationEnabled -ne $true ) {$Obj.AuditState = "FAIL"}
    if (($Obj.NotifyUser -join ';') -notmatch "@" ) {$Obj.AuditState = "FAIL"}
    if ($Obj.Disabled -eq $true ) {$Obj.AuditState = "FAIL"}
    if ($Obj.ThreatType -notin @("Phish", "Malware")) { $Obj.AuditState = "FAIL" }
    $PAReport.Add($Obj)
}


$PassingPhish = $PAReport | Where-Object {$_.AuditState -eq "PASS" -and $_.ThreatType -eq "Phish"}
$PassingMalware = $PAReport | Where-Object {$_.AuditState -eq "PASS" -and $_.ThreatType -eq "Malware"}
if (@($PassingPhish).Count -gt 0 -and @($PassingMalware).Count -gt 0) {
    Write-Host "** PASS : Found compliant Priority Account Protection alerts for Phish and Malware. **"
    $PassingPhish | Format-List
    $PassingMalware | Format-List
} else {
    Write-Host "** FAIL : Missing compliant Priority Account Protection alert for Phish and/or Malware. **"
    $PAReport | Format-List
}
