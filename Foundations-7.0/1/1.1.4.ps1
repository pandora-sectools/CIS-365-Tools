# 1.1.4 Ensure administrative accounts use licenses with a reduced application footprint (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "RoleManagement.Read.Directory","User.Read.All" -NoWelcome

$DirectoryRoles = Get-MgDirectoryRole

# Get privileged role IDs
$PrivilegedRoles = $DirectoryRoles | Where-Object {
    $_.DisplayName -like "*Administrator*" -or $_.DisplayName -eq "Global Reader"
}

# Get the members of these various roles
$RoleMembers = $PrivilegedRoles | ForEach-Object {
    Get-MgDirectoryRoleMember -DirectoryRoleId $_.Id
} | Select-Object Id -Unique
    
# Retrieve details about the members in these roles
$PrivilegedUsers = $RoleMembers | ForEach-Object {
    Get-MgUser -UserId $_.Id -Property UserPrincipalName, DisplayName, Id
}

$Report = [System.Collections.Generic.List[Object]]::new()
foreach ($Admin in $PrivilegedUsers) {
    $License = (Get-MgUserLicenseDetail -UserId $Admin.id).SkuPartNumber -join ", "
    $Obj = [pscustomobject][ordered]@{
        DisplayName = $Admin.DisplayName
        UserPrincipalName = $Admin.UserPrincipalName
        License = $License
    }

    $Report.Add($Obj)

}

$Report
