# 2.4.2 Ensure Priority accounts have 'Strict protection' presets applied (Automated)
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$ATP = Get-ATPProtectionPolicyRule |
    Where-Object { $_.Identity -eq "Strict Preset Security Policy" }

$EOP = Get-EOPProtectionPolicyRule |
    Where-Object { $_.Identity -eq "Strict Preset Security Policy" }

$PolicyReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Policy in @($ATP, $EOP)) {

    if ($null -eq $Policy) { continue }

    $HasRecipient = (
        @($Policy.SentTo).Count -gt 0 -or
        @($Policy.SentToMemberOf).Count -gt 0 -or
        @($Policy.RecipientDomainIs).Count -gt 0
    )

    $Obj = [PSCustomObject]@{
        Identity          = $Policy.Identity
        State             = $Policy.State
        SentTo            = @($Policy.SentTo) -join ", "
        SentToMemberOf    = @($Policy.SentToMemberOf) -join ", "
        RecipientDomainIs = @($Policy.RecipientDomainIs) -join ", "
        HasRecipient      = $HasRecipient
        AuditState        = "PASS"
    }

    if ($Obj.State -ne "Enabled") { $Obj.AuditState = "FAIL" }
    if ($Obj.HasRecipient -ne $true) { $Obj.AuditState = "FAIL" }

    $PolicyReport.Add($Obj)
}

$ATPStatus = $PolicyReport |
    Where-Object { $_.Identity -eq "Strict Preset Security Policy" } |
    Select-Object -First 1

$ATPPass = (
    $null -ne $ATP -and
    $ATP.State -eq "Enabled" -and
    (@($ATP.SentTo).Count -gt 0 -or @($ATP.SentToMemberOf).Count -gt 0 -or @($ATP.RecipientDomainIs).Count -gt 0)
)

$EOPPass = (
    $null -ne $EOP -and
    $EOP.State -eq "Enabled" -and
    (@($EOP.SentTo).Count -gt 0 -or @($EOP.SentToMemberOf).Count -gt 0 -or @($EOP.RecipientDomainIs).Count -gt 0)
)

if ($ATPPass -and $EOPPass) {
    Write-Host "** PASS : Strict protection presets are applied to Priority accounts. **"
    $PolicyReport | Format-List
} else {
    Write-Host "** FAIL : Strict protection presets are not correctly applied to Priority accounts. **"
    $PolicyReport | Format-List
}
