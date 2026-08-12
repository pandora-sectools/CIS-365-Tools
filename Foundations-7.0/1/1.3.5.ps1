# 1.3.5 Ensure internal phishing protection for Forms is enabled (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "OrgSettings-Forms.Read.All" -NoWelcome

$uri = 'https://graph.microsoft.com/beta/admin/forms/settings'
$Policy = Invoke-MgGraphRequest -Uri $uri | Select-Object isInOrgFormsPhishingScanEnabled
$Policy | Format-List

if ($Policy.isInOrgFormsPhishingScanEnabled -eq $true) {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
