# 6.5.2 Ensure MailTips are enabled for end users (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$MailTips = Get-OrganizationConfig

$Audit = [PSCustomObject]@{
    MailTipsAllTipsEnabled                = $MailTips.MailTipsAllTipsEnabled
    MailTipsExternalRecipientsTipsEnabled = $MailTips.MailTipsExternalRecipientsTipsEnabled
    MailTipsGroupMetricsEnabled           = $MailTips.MailTipsGroupMetricsEnabled
    MailTipsLargeAudienceThreshold        = $MailTips.MailTipsLargeAudienceThreshold
}

$Audit | Format-List

if (
    $MailTips.MailTipsAllTipsEnabled -eq $true -and
    $MailTips.MailTipsExternalRecipientsTipsEnabled -eq $true -and
    $MailTips.MailTipsGroupMetricsEnabled -eq $true
) {
    Write-Host "** PASS : MailTips are enabled for end users. **"
} else {
    Write-Host "** FAIL : MailTips are not correctly configured. **"
}
