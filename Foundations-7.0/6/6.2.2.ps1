# 6.2.2 Ensure mail transport rules do not whitelist specific domains (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$TenancyDomains = Get-AcceptedDomain | Where-Object { $_.IsCoExistenceDomain -eq $false }
$MBXDomains = $TenancyDomains | Select-Object -ExpandProperty DomainName
$MTRReport = [System.Collections.Generic.List[Object]]::new()
$MailTransportRules = Get-TransportRule

foreach ($Rule in $MailTransportRules) {

    $Obj = [PSCustomObject]@{
        Name                = $Rule.Name
        SenderDomainIs      = $Rule.SenderDomainIs | Where-Object {$_ -ne $null}
        SetSCL              = $Rule.SetSCL
        ExternalDomains     = ""
        AuditState          = "PASS"
    }

    $Obj.ExternalDomains = $Obj.SenderDomainIs | Where-Object {($MBXDomains -notcontains $_.ToString())}
    if (@($Obj.SenderDomainIs).Count -gt 0 -and ($Obj.SetSCL -eq -1)) {
        $Obj.AuditState = "FAIL"
    }
    $MTRReport.Add($Obj)
}

$FailingRules = $MTRReport | Where-Object { $_.AuditState -eq "FAIL" }
$PassingRules = $MTRReport | Where-Object { $_.AuditState -eq "PASS"}
$PassWithExternalRules = $PassingRules | Where-Object { @($_.ExternalDomains).Count -gt 0 }
if (@($FailingRules).Count -gt 0) {
    Write-Host "** FAIL : Mail Transport Rules are not Compliant. **"
    $FailingRules | Format-Table Name,AuditState,SetSCL,SenderDomainIs
} elseif (@($PassWithExternalRules).Count -gt 0) {
    Write-Host "** PASS : MAIL Transport Rules are compliant. **"
    Write-Host "** NOTE : Rules Contain external domains. Review if required. **"
    $PassWithExternalRules | Format-Table Name,AuditState,SetSCL,ExternalDomains
} else {
    Write-Host "** PASS : Mail Transport Rules are compliant. **"
    $MTRReport | Format-Table Name,AuditState,SetSCL,SenderDomainIs
}
