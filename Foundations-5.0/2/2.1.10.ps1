# 2.1.10 Ensure DMARC records for all Exchange Online domains are published (Automated)
# E3 Level 1
# E5 Level 1


# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$TenancyNonCompliant = $false
$TenancyDomains = Get-AcceptedDomain | Where-Object {$_.IsCoExistenceDomain -eq $false}

foreach ($Domain in $TenancyDomains) {

    Write-Host "`nTesting Domain: $($Domain.Name)"

    # Fetch DNS Records
    try {
        $DNS = $(Resolve-DnsName "_dmarc.$($Domain.DomainName)" -Type TXT -ErrorAction Stop)
        $DNS | Format-List
    }
    catch {
        Write-Host "** Records Invalid or irretrievable for $($Domain.Name) **"
        $TenancyNonCompliant = $true
    }
}