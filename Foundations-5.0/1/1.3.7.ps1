# 1.3.7 Ensure 'third-party storage services' are restricted in 'Microsoft 365 on the web' (Automated)
# E3 Level 2
# E5 Level 2

Connect-MgGraph -Scopes "Application.Read.All" -NoWelcome

$ServicePrincipal = Get-MgServicePrincipal -Filter "appId eq 'c1f33bc0-bdb4-4248-ba9b-096807ddb43e'"

if ((-not $ServicePrincipal) -or $ServicePrincipal.AccountEnabled) {
    Write-Host "** FAIL **"
} else {
    Write-Host "** PASS **"
}

$ServicePrincipal | Format-List AccountEnabled
