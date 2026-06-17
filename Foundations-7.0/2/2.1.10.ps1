# 2.1.10 Ensure DMARC records for all Exchange Online domains are published (Automated)
# E3 Level 1
# E5 Level 1


# connect to exchange if not already connected
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}
$TenancyNonCompliant = $false
$TenancyDomains = Get-AcceptedDomain | Where-Object {$_.IsCoExistenceDomain -eq $false}

foreach ($Domain in $TenancyDomains) {

    Write-Host "`nTesting Domain: $($Domain.Name)"
    # $DomainSPFCompliant = $false

    # Fetch DNS Records
    try {
        $DNS = $(Resolve-DnsName "_dmarc.$($Domain.DomainName)" -Type TXT -ErrorAction Stop)
    }
    catch {
        Write-Host "** Records Invalid or irretrievable for $($Domain.Name) **"
        $TenancyNonCompliant = $true
        # continue
    }
}
