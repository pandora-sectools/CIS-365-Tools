# 2.1.6 Ensure Exchange Online Spam Policies are set to notify administrators (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$Params = @(
    'BccSuspiciousOutboundMail',
    'NotifyOutboundSpam'
)

Write-Host "Get-HostedOutboundSpamFilterPolicy | Where-Object { $_.Name -eq `"Default`" }"
$GetDefaultPolicy = Get-HostedOutboundSpamFilterPolicy | Where-Object { $_.Name -eq "Default" }

if (-not $GetDefaultPolicy) {
    Write-Host "`n** FAIL : Default Hosted Outbound Spam Filter Policy not found. **"
    return
}

# Stage 2 : Check spam policy is valid.
$AntiSpamPolicy = $GetDefaultPolicy | Select-Object -Property $Params
$ASPReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in $AntiSpamPolicy) {

    $Obj = [PSCustomObject]@{
        BccSuspiciousOutboundMail     = $Policy.BccSuspiciousOutboundMail
        NotifyOutboundSpam            = $Policy.NotifyOutboundSpam
        AuditState                    = "FAIL"
    }
    
    if ($Obj.BccSuspiciousOutboundMail -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.NotifyOutboundSpam -ne $true) { $Obj.AuditState = "FAIL" }
    $ASPReport.Add($Obj)
}

$PassingASPs = $ASPReport | Where-Object { $_.AuditState -eq "PASS" }
if (@($PassingASPs).Count -gt 0) {
    Write-Host "** PASS : Found a compliant Default Anti-Spam Policy. **"
    $PassingASPs |Format-List
} else {
    Write-Host "** FAIL : There are no qualifying Default Anti-Spam Policies. **"
    $ASPReport |Format-List
}
