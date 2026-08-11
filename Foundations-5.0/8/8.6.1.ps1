# 8.6.1 Ensure users can report security concerns in Teams (Automated)
# E5 Level 1

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

# connect to teams if not already connected
try { Get-CsTenant -ErrorAction Stop | Out-Null }
catch { Connect-MicrosoftTeams | Out-Null }

$UserReportStatus = Get-CsTeamsMessagingPolicy -Identity Global 
$UserReportStatus | Format-List AllowSecurityEndUserReporting

if (-not $UserReportStatus.AllowSecurityEndUserReporting) {
    Write-Host "** FAIL - End user reporting disabled. **"
    return
} else {
    Write-Host "** End User Reporting Enabled. **"
}

$Params = @(
    'ReportJunkToCustomizedAddress',
    'ReportNotJunkToCustomizedAddress',
    'ReportPhishToCustomizedAddress',
    'ReportJunkAddresses',
    'ReportNotJunkAddresses',
    'ReportPhishAddresses',
    'ReportChatMessageEnabled',
    'ReportChatMessageToCustomizedAddressEnabled'
)

# Stage 2 : Fetch all Teams reporting policies that exist, 
# then Loop through policies and generate a per policy report.
Write-Host "** Check for valid policy.. **"
$RSPReport = [System.Collections.Generic.List[Object]]::new()
$ReportSubmissionPolicy = Get-ReportSubmissionPolicy |  Select-Object -Property $Params

foreach ($Policy in $ReportSubmissionPolicy) {

    $Obj = [PSCustomObject]@{
        ReportJunkToCustomizedAddress               = $Policy.ReportJunkToCustomizedAddress
        ReportNotJunkToCustomizedAddress            = $Policy.ReportNotJunkToCustomizedAddress
        ReportPhishToCustomizedAddress              = $Policy.ReportPhishToCustomizedAddress
        ReportJunkAddresses                         = $Policy.ReportJunkAddresses
        ReportNotJunkAddresses                      = $Policy.ReportNotJunkAddresses
        ReportPhishAddresses                        = $Policy.ReportPhishAddresses
        ReportChatMessageEnabled                    = $Policy.ReportChatMessageEnabled
        ReportChatMessageToCustomizedAddressEnabled = $Policy.ReportChatMessageToCustomizedAddressEnabled
        AuditState                                  = "PASS"
    }
    
    if ($Obj.ReportJunkToCustomizedAddress -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.ReportNotJunkToCustomizedAddress -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.ReportPhishToCustomizedAddress -ne $true) { $Obj.AuditState = "FAIL" }
    if (($Obj.ReportJunkAddresses -join ';') -notmatch "@")  { $Obj.AuditState = "FAIL" }
    if (($Obj.ReportNotJunkAddresses -join ';') -notmatch "@")  { $Obj.AuditState = "FAIL" }
    if (($Obj.ReportPhishAddresses -join ';') -notmatch "@")  { $Obj.AuditState = "FAIL" }
    if ($Obj.ReportChatMessageEnabled -ne $false) { $Obj.AuditState = "FAIL" }
    if ($Obj.ReportChatMessageToCustomizedAddressEnabled -ne $true) { $Obj.AuditState = "FAIL" }
    $RSPReport.Add($Obj)
}


$PassingRSPs = $RSPReport | Where-Object { $_.AuditState -eq "PASS" }
if (@($PassingRSPs).Count -gt 0) {
    Write-Host "** PASS : Found a compliant Teams Report Submission Policy. **"
    $PassingRSPs | Format-List
} else {
    Write-Host "** FAIL : There are no qualifying Teams Report Submission Policies. **"
    $RSPReport | Format-List
}
