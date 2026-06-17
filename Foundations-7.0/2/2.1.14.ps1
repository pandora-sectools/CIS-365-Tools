# 2.1.14 Ensure inbound anti-spam policies do not contain allowed domains (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$InboundSpamPolicy = Get-HostedContentFilterPolicy -Identity Default
$InboundSpamPolicy | Format-Table Identity,AllowedSenderDomains

if (@($InboundSpamPolicy.AllowedSenderDomains).Count -gt 0) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}
