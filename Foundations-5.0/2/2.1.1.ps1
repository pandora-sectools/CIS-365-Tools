# 2.1.1 Ensure Safe Links for Office Applications is Enabled (Automated)
# E5 Level 2

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$Params = @(
    'Identity',
    'EnableSafeLinksForEmail',
    'EnableSafeLinksForTeams',
    'EnableSafeLinksForOffice',
    'TrackClicks',
    'AllowClickThrough',
    'ScanUrls',
    'EnableForInternalSenders',
    'DeliverMessageAfterScan',
    'DisableUrlRewrite'
)


# Stage 2 : Filter to policies with "Use app enforced restrictions" 
# enabled, then Loop through policies and generate a per policy report.
$SLPReport = [System.Collections.Generic.List[Object]]::new()
$SLPs = Get-SafeLinksPolicy | Select-Object -Property $Params

foreach ($policy in $SLPs) {

    $Obj = [PSCustomObject]@{
        Identity                   = $Policy.Identity
        EnableSafeLinksForEmail    = $Policy.EnableSafeLinksForEmail
        EnableSafeLinksForTeams    = $Policy.EnableSafeLinksForTeams
        EnableSafeLinksForOffice   = $Policy.EnableSafeLinksForOffice
        TrackClicks                = $Policy.TrackClicks
        AllowClickThrough          = $Policy.AllowClickThrough
        ScanUrls                   = $Policy.ScanUrls
        EnableForInternalSenders   = $Policy.EnableForInternalSenders
        DeliverMessageAfterScan    = $Policy.DeliverMessageAfterScan
        DisableUrlRewrite          = $Policy.DisableUrlRewrite
        AuditState                  = "PASS"
    }

    if ($Obj.EnableSafeLinksForEmail -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.EnableSafeLinksForTeams -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.EnableSafeLinksForOffice -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.TrackClicks -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.AllowClickThrough -ne $false) { $Obj.AuditState = "FAIL" }
    if ($Obj.ScanUrls -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.EnableForInternalSenders -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.DeliverMessageAfterScan -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.DisableUrlRewrite -ne $false) { $Obj.AuditState = "FAIL" }
    $SLPReport.Add($Obj)
}

$PassingSLPs = $SLPReport | Where-Object { $_.AuditState -eq "PASS" }
if (@($PassingSLPs).Count -gt 0) {
    Write-Host "** PASS : Found a compliant Safe Links Policy. **"
    $PassingSLPs |Format-List
} else {
    Write-Host "** FAIL : There are no qualifying Safe Links Policies. **"
    $SLPReport |Format-List
}
