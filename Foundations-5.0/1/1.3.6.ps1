# 1.3.6 Ensure the customer lockbox feature is enabled (Automated)
# E5 Level 2

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$LockboxStatus = Get-OrganizationConfig | Select-Object CustomerLockBoxEnabled
$LockboxStatus | Format-List AccountEnabled


if ($LockboxStatus) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
