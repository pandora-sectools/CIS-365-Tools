# 3.1.1 Ensure Microsoft 365 audit log search is Enabled (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$AdminAuditLogStatus = Get-AdminAuditLogConfig
$AdminAuditLogStatus | Format-List UnifiedAuditLogIngestionEnabled

if ($AdminAuditLogStatus.UnifiedAuditLogIngestionEnabled) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
