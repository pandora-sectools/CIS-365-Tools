# 6.2.3 Ensure email from external senders is identified (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

# Organization-approved addresses/domains permitted to bypass external tagging
$ApprovedAllowList = @(
    "trusted@example.com"
    "partner.example.com"
)

$Identities = Get-ExternalInOutlook
$IdentityReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Identity in $Identities) {

    $Obj = [PSCustomObject]@{
        Enabled           = $Identity.Enabled
        AllowList         = $Identity.AllowList
        UnapprovedEntries = $Identity.AllowList | Where-Object { $_ -notin $ApprovedAllowList }
        AuditState        = "PASS"
    }

    if ($Obj.Enabled -ne $true) { $Obj.AuditState = "FAIL" }
    if (@($Obj.UnapprovedEntries).Count -gt 0) { $Obj.AuditState = "FAIL" }
    
    $IdentityReport.Add($Obj)
}

$IdentityReport | Format-List

$FailingIdentities = $IdentityReport |
    Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingIdentities).Count -gt 0) {
    Write-Host "** FAIL : External sender identification is not correctly configured. **"
} else {
    Write-Host "** PASS : External sender identification is enabled and the AllowList only contains approved entries. **"
}