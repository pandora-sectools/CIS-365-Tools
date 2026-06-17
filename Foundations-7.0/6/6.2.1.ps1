# 6.2.1 Ensure all forms of mail forwarding are blocked and/or disabled (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$TenancyDomains = Get-AcceptedDomain | Where-Object { $_.IsCoExistenceDomain -eq $false }
$MBXDomains = $TenancyDomains | Select-Object -ExpandProperty DomainName
$MTRReport = [System.Collections.Generic.List[Object]]::new()
$MailTransportRules = Get-TransportRule

foreach ($Rule in $MailTransportRules) {

    $Obj = [PSCustomObject]@{
        Rule                = $Rule.Name
        Enabled             = $Rule.State
        RedirectMessageTo   = $Rule.RedirectMessageTo
        AuditState          = "PASS"
    }

    if ($Obj.RedirectMessageTo) {
        $RedirectsExternally = $($Obj.RedirectMessageTo -split "@")[-1] -notin $MBXDomains
        if ($RedirectsExternally) { $Obj.AuditState = "FAIL"; break }
        else { $Obj.AuditState = "PARTIAL" }
    }

    $MTRReport.Add($Obj)
}

$FailingRules = $MTRReport | Where-Object { $_.AuditState -eq "FAIL" }
$PartialRules = $MTRReport | Where-Object { $_.AuditState -eq "PARTIAL" }
if (@($FailingRules).Count -gt 0) {
    Write-Host "** FAIL : Mailboxes are not Compliant. **"
    $FailingRules | Format-List
} elseif (@($PartialRules).Count -gt 0) {
    Write-Host "** FAIL : Mailboxes are not Compliant. **"
    $PartialRules | Format-List
} else {
    Write-Host "** PASS : Mailboxes are compliant. **"
    $MTRReport | Format-List
}
