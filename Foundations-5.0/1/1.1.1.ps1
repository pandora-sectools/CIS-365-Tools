# 1.1.1 Ensure Administrative accounts are cloud-only (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "RoleManagement.Read.Directory","User.Read.All" -NoWelcome

# Get privileged role IDs
$DirectoryRoles = Get-MgDirectoryRole
$PrivilegedRoles = $DirectoryRoles | Where-Object { $_.DisplayName -like "*Administrator*" }
$PrivilegedRoles += $DirectoryRoles | Where-Object { $_.DisplayName -eq "Global Reader" }

# Get Member details for these roles
$RoleMembers = $PrivilegedRoles | ForEach-Object { Get-MgDirectoryRoleMember -DirectoryRoleId $_.Id } | Select-Object Id -Unique
$PrivilegedUsers = $RoleMembers | ForEach-Object { Get-MgUser -UserId $_.Id -Property UserPrincipalName, DisplayName, Id, OnPremisesSyncEnabled}

# Get synced admins
$SyncedPrivilegedUsers = $PrivilegedUsers | Where-Object { $_.OnPremisesSyncEnabled -eq $true }

if (@($SyncedPrivilegedUsers).Count -eq 0) {
    Write-Host "** PASS : All privileged users are Cloud-Only. **"
    $PrivilegedUsers | Format-Table DisplayName,UserPrincipalName,OnPremisesSyncEnabled
}
else {
    Write-Host "** FAIL : $($SyncedPrivilegedUsers.Count) privileged user(s) are synchronized from on-premises. **"
    $SyncedPrivilegedUsers | Format-Table DisplayName,UserPrincipalName,OnPremisesSyncEnabled
}
