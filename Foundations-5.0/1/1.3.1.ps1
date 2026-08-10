# 1.3.1 Ensure the 'Password expiration policy' is set to 'Set passwords to never expire (recommended)' (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Domain.Read.All" -NoWelcome
$NonCompliantDomains = [System.Collections.Generic.List[Object]]::new()
$MgDomains = Get-MgDomain

forEach ($Domain in $MgDomains) {

    if ($Domain.PasswordValidityPeriodInDays -eq 2147483647) { continue }
    $NonCompliantDomains.add($Domain)
}

if (@($NonCompliantDomains).Count -gt 0 ) {
    Write-Host "** FAIL : Expiration is not set to 'Never Expire' (2147483647). **"
    $NonCompliantDomains | Format-Table Id, PasswordValidityPeriodInDays -AutoSize
} else {
    Write-Host "** PASS : Expiration is set to 'Never Expire' (2147483647). **"
    $MgDomains | Format-Table Id, PasswordValidityPeriodInDays -AutoSize
}
