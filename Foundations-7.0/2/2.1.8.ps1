# 2.1.8 Ensure that SPF records are published for all Exchange Domains (Automated)
# E3 Level 1
# E5 Level 1


# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

$TenancyNonCompliant = $false


$TenancyDomains = Get-AcceptedDomain | Where-Object {
    $_.IsCoExistenceDomain -eq $false -and
    $_.InitialDomain -eq $false
}

forEach ($Domain in $TenancyDomains) {

    Write-Host "`nTesting Domain: $($Domain.Name)"
    $DomainSPFCompliant = $false

    # Fetch DNS Records
    try {
        $DNS = $(Resolve-DnsName $Domain.DomainName -Type TXT -ErrorAction Stop)
    }
    catch {
        Write-Host "** Records Invalid or irretrievable for $($Domain.Name) **"
        $TenancyNonCompliant = $true
        continue
    }

    ForEach ($Record in $DNS.strings) {
        
        # 1. Must begin with v=spf1
        if ($Record -notmatch '^v=spf1') { continue }

        # 2. Must be directly or indirectly managed
        $DirectlyManaged = $Record -match 'include:spf\.protection\.outlook\.com'
        $IndirectlyManaged = $Record -match '\bredirect=[^\s]+'
        if (-not ($DirectlyManaged -or $IndirectlyManaged)) { continue }

        # 3. Must end with hard fail or soft fail
        $HasFailPolicy = $Record -match '(-all|~all)$'
        if (-not $HasFailPolicy) { continue }


        $DomainSPFCompliant = $true
        break
    }

    if ($DomainSPFCompliant) {
        Write-Host "Identified Valid SPF: $($Record)"
    } else {
        Write-Host "Domain is missing a valid SPF Record."
        $TenancyNonCompliant = $true
    }

}

if ($TenancyNonCompliant) {
    Write-Host "`n** FAIL : Tenancy Domains are missing SPF Records. **"
} else {
    Write-Host "`n** PASS : Tenancy Domains contain valid SPF Records. **"
}
