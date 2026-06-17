# 2.1.9 Ensure that DKIM is enabled for all Exchange Online Domains (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

# Get-DkimSigningConfig does not display unconfigured
# domains, so we first get all accepted domains and then 
# match them against the DKIM signing configurations.
$DKIMReport = [System.Collections.Generic.List[Object]]::new()
$Domains = Get-AcceptedDomain | Where-Object {
    $_.IsCoExistenceDomain -eq $false -and
    $_.InitialDomain -eq $false
}

# benchmark code is slop - this is cleaner but maybe breakout later
foreach ($Domain in $Domains) {
    $DKIM = Get-DkimSigningConfig | Where-Object { $_.Name -eq $Domain.Name }    
    $DKIMReport.Add([PSCustomObject]@{
        DisplayName       = $Domain.Name
        Enabled           = [bool]$DKIM.Enabled
        Status            = if ($DKIM) { $DKIM.Status } else { "Not Configured"}
        IsCISCompliant    = ($DKIM.Enabled -and $DKIM.Status -eq "Valid")
    })
}

$PassingKDKIM = $DKIMReport | Where-Object { $_.IsCISCompliant -eq $true }
if (@($PassingSLPs).Count -eq  @($DKIMReport).Count) {
    Write-Host "** PASS : DKIM Entries are valid for all domains. **"
    $PassingKDKIM | Format-Table
} else {
    Write-Host "** FAIL : DKIM Entries are not valid for all domains. **"
    $DKIMReport | Format-Table
}

# Optionally, export the report to a CSV file
# $Report | Export-Csv -Path "2_1_9.csv" -NoTypeInformation
