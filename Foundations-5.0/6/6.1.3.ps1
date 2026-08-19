# 6.1.3 Ensure 'AuditBypassEnabled' is not enabled on mailboxes (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$MBXReport = [System.Collections.Generic.List[Object]]::new()
$MBX = Get-MailboxAuditBypassAssociation -ResultSize unlimited | Select-Object Name,AuditBypassEnabled

foreach ($Mailbox in $MBX) {

    $Obj = [PSCustomObject]@{
        Mailbox             = $Mailbox.Name
        AuditBypassEnabled  = $Mailbox.AuditBypassEnabled
        AuditState          = "PASS"
    }

    if ($Obj.AuditBypassEnabled -ne $false) {$Obj.AuditState = "FAIL"}
    $MBXReport.add($Obj)
}

$FailingMBX = $MBXReport | Where-Object { $_.AuditState -eq "FAIL" }
if (@($FailingMBX).Count -eq 0) {
    Write-Host "** PASS : Mailboxes are compliant. **"
    $MBXReport | Format-List
} else {
    Write-Host "** FAIL : Mailboxes are not Compliant. **"
    $FailingMBX | Format-List
}
