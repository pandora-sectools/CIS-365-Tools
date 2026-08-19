# 1.2.2 Ensure sign-in to shared mailboxes is blocked (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

$MBX = Get-EXOMailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited

$NonCompliant = $MBX | ForEach-Object {
    $User = Get-MgUser -UserId $_.ExternalDirectoryObjectId -Property `
        DisplayName, UserPrincipalName, AccountEnabled

    if ($User.AccountEnabled -eq $true) {
        [PSCustomObject]@{
            DisplayName       = $User.DisplayName
            UserPrincipalName = $User.UserPrincipalName
            AccountEnabled    = $User.AccountEnabled
        }
    }
} 

if ( @($NonCompliant).Count -gt 0) {
    Write-Host "** FAIL : There are $($NonCompliant.Count) Mailboxes with Sign-in Enabled. **"
    $NonCompliant | Format-Table -AutoSize
} else {
    Write-Host "** PASS : Sign-in for all Shared Mailboxes is disabled. **"
}
