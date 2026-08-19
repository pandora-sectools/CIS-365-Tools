# 6.5.4 Ensure SMTP AUTH is disabled (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$TransportConfig = Get-TransportConfig

Write-Host "TransportConfig.SmtpClientAuthenticationDisabled: $($TransportConfig.SmtpClientAuthenticationDisabled)"

if ($TransportConfig.SmtpClientAuthenticationDisabled -eq $true) {
    Write-Host "** PASS : SMTP AUTH is disabled. **"
} else {
    Write-Host "** FAIL : SMTP AUTH is enabled. **"
}
