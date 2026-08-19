# 2.1.14 Ensure inbound anti-spam policies do not contain allowed domains (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
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
