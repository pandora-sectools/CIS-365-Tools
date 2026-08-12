# 1.1.4 Ensure administrative accounts use licenses with a reduced application footprint (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "RoleManagement.Read.Directory","User.Read.All" -NoWelcome

$DirectoryRoles = Get-MgDirectoryRole

# Get privileged role IDs
$PrivilegedRoles = $DirectoryRoles | Where-Object {
    $_.DisplayName -like "*Administrator*" -or $_.DisplayName -eq "Global Reader"
}

# Get Member details for these roles
$RoleMembers = $PrivilegedRoles | ForEach-Object {
    Get-MgDirectoryRoleMember -DirectoryRoleId $_.Id
} | Sort-Object Id -Unique

# Retrieve users represented by those role members
$PrivilegedUsers = foreach ($RoleMember in $RoleMembers) {

    $DirectoryObject = Get-MgDirectoryObject -DirectoryObjectId $RoleMember.Id
    $ObjectType = $DirectoryObject.AdditionalProperties['@odata.type']

    if ($ObjectType -eq '#microsoft.graph.user') {
        Get-MgUser -UserId $RoleMember.Id -Property UserPrincipalName,DisplayName,Id
    }

    if ($ObjectType -eq '#microsoft.graph.group') {
        Get-MgGroupTransitiveMemberAsUser -GroupId $RoleMember.Id -All `
            -Property UserPrincipalName,DisplayName,Id
    }
}

$PrivilegedUsers = $PrivilegedUsers | Sort-Object Id -Unique

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
