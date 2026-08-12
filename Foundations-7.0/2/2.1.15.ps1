# 2.1.14 Ensure outbound anti-spam message limits are in place (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$ShareProviders = @(
    'RecipientLimitExternalPerHour'
    'RecipientLimitInternalPerHour'
    'RecipientLimitPerDay'
    'ActionWhenThresholdReached'
    'NotifyOutboundSpamRecipients'
)

$OSPReport = [System.Collections.Generic.List[Object]]::new()
$OutboundSpamPolicy = Get-HostedOutboundSpamFilterPolicy

foreach ($Policy in $OutboundSpamPolicy) {
    $Obj = [pscustomobject][ordered]@{
        Name                          = $Policy.Name
        RecipientLimitExternalPerHour = $Policy.RecipientLimitExternalPerHour
        RecipientLimitInternalPerHour = $Policy.RecipientLimitInternalPerHour
        RecipientLimitPerDay          = $Policy.RecipientLimitPerDay
        ActionWhenThresholdReached    = $Policy.ActionWhenThresholdReached
        NotifyOutboundSpamRecipients  = $Policy.NotifyOutboundSpamRecipients
        AuditState                    = "PASS"
    }

    if ($Obj.Name -ne "Default") {$Obj.AuditState = "PARTIAL"}
    if ($Obj.RecipientLimitExternalPerHour -gt 500) {$Obj.AuditState = "FAIL"}
    if ($Obj.RecipientLimitExternalPerHour -eq 0) {$Obj.AuditState = "FAIL"}
    if ($Obj.RecipientLimitInternalPerHour -gt 1000) {$Obj.AuditState = "FAIL"}
    if ($Obj.RecipientLimitInternalPerHour -eq 0) {$Obj.AuditState = "FAIL"}
    if ($Obj.RecipientLimitPerDay -gt 1000) {$Obj.AuditState = "FAIL"}
    if ($Obj.RecipientLimitPerDay -eq 0) {$Obj.AuditState = "FAIL"}
    if ($Obj.ActionWhenThresholdReached -ne "BlockUser") {$Obj.AuditState = "FAIL"}
    if ($Obj.NotifyOutboundSpamRecipients -notmatch "@" ) {$Obj.AuditState = "FAIL"}
    $OSPReport.Add($Obj)
}

$PassingOSP = $OSPReport | Where-Object {$_.AuditState -eq "PASS"}
$PartialOSP = $OSPReport | Where-Object {$_.AuditState -eq "PARTIAL"}
if (@($PassingOSP).Count -gt 0) {
    Write-Host "** PASS : Default Outbound Anti-Spam Policy is compliant. **" 
    $PassingOSP | Format-List
} elseif (@($PartialOSP).Count -gt 0) {
    Write-Host "** PARTIAL : A Compliant policy was found but it was not the default. **"
    $PartialOSP
} else {
    Write-Host "** FAIL : No Compliant policy was found. **"
    $OSPReport
}
