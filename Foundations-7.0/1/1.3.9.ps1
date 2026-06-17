# 1.3.9 Ensure shared bookings pages are restricted to select users (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$MBXPolicy = Get-OwaMailboxPolicy -Identity OwaMailboxPolicy-Default | Format-List BookingsMailboxCreationEnabled

if ($MBXPolicy.BookingsMailboxCreationEnabled) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}

$MBXPolicy | Format-List AccountEnabled
