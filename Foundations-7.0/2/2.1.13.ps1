# 2.1.13 Ensure the connection filter safe list is off (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$ConnectionFilter = Get-HostedConnectionFilterPolicy -Identity Default
$ConnectionFilter | Format-List EnableSafeList

if ($ConnectionFilter.EnableSafeList) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
