# 6.1.2 Ensure mailbox audit actions are configured (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$AdminActions = @(
"ApplyRecord", "Copy", "Create", "FolderBind", "HardDelete",
"MailItemsAccessed", "Move", "MoveToDeletedItems", "SendAs",
"SendOnBehalf", "Send", "SoftDelete", "Update",
"UpdateCalendarDelegation", "UpdateFolderPermissions",
"UpdateInboxRules"
)
$DelegateActions = @(
"ApplyRecord", "Create", "FolderBind", "HardDelete", "Move",
"MailItemsAccessed", "MoveToDeletedItems", "SendAs", "SendOnBehalf",
"SoftDelete", "Update", "UpdateFolderPermissions", "UpdateInboxRules"
)
$OwnerActions = @(
"ApplyRecord", "Create", "HardDelete", "MailboxLogin", "Move",
"MailItemsAccessed", "MoveToDeletedItems", "Send", "SoftDelete",
"Update", "UpdateCalendarDelegation", "UpdateFolderPermissions",
"UpdateInboxRules"
)

$MBXReport = [System.Collections.Generic.List[Object]]::new()
$MBX = Get-EXOMailbox -PropertySets Audit, Minimum -ResultSize Unlimited | Where-Object { $_.RecipientTypeDetails -eq "UserMailbox" }

foreach ($mailbox in $MBX) {

    $AdminMissing = $AdminActions | Where-Object { $_ -notin $mailbox.AuditAdmin }
    $DelegateMissing = $DelegateActions | Where-Object { $_ -notin $mailbox.AuditDelegate }
    $OwnerMissing = $OwnerActions | Where-Object { $_ -notin $mailbox.AuditOwner }

    $Obj = [PSCustomObject]@{
        Mailbox           = $mailbox.UserPrincipalName
        AuditEnabled      = $mailbox.AuditEnabled
        AdminMissing      = "None"
        DelegateMissing   = "None"
        OwnerMissing      = "None"
        AuditState        = "Compliant"
    }

    if ($Obj.AuditEnabled -ne $true) {$Obj.AuditState = "Non-Compliant"}
    if ($AdminMissing.Count -gt 0) {
        $Obj.AdminMissing = $AdminMissing -join ", "
        $Obj.AuditState = "Non-Compliant"
    }
    if ($DelegateMissing.Count -gt 0) {
        $Obj.DelegateMissing = $DelegateMissing -join ", "
        $Obj.AuditState = "Non-Compliant"
    }    
    if ($OwnerMissing.Count -gt 0) {
        $Obj.OwnerMissing = $OwnerMissing -join ", "
        $Obj.AuditState = "Non-Compliant"
    }

    $MBXReport.add($Obj)
}

$FailingMBX = $MBXReport | Where-Object { $_.AuditState -eq "Non-Compliant" }
if (@($FailingMBX).Count -eq 0) {
    Write-Host "** PASS : Mailboxes are compliant. **"
    $MBXReport | Format-List
} else {
    Write-Host "** FAIL : Mailboxes are not Compliant. **"
    $FailingMBX | Format-List
}
