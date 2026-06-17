# 1.1.3 Ensure that between two and four global admins are designated (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Directory.Read.All" -NoWelcome

# Determine Id of GA role using the immutable RoleTemplateId value.
$GlobalAdminRole = Get-MgDirectoryRole -Filter "RoleTemplateId eq '62e90394-69f5-4237-9190-012177145e10'"
$RoleMembers = Get-MgDirectoryRoleMember -DirectoryRoleId $GlobalAdminRole.Id
$GlobalAdmins = [System.Collections.Generic.List[Object]]::new()

foreach ($object in $RoleMembers)
{
    $Type = $object.AdditionalProperties.'@odata.type'

    # Check for and process role assigned groups
    if ($Type -eq '#microsoft.graph.group')
    {
        $GroupId = $object.Id
        $GroupMembers = (Get-MgGroupMember -GroupId $GroupId).AdditionalProperties
    
        foreach ($member in $GroupMembers)
        {
            if ($member.'@odata.type' -eq '#microsoft.graph.user')
            {
                $GlobalAdmins.Add([PSCustomObject][Ordered]@{
                    DisplayName = $member.displayName
                    UserPrincipalName = $member.userPrincipalName})
            }
        }
    }
    elseif ($Type -eq '#microsoft.graph.user')
    {
        $DisplayName = $object.AdditionalProperties.displayName
        $UPN = $object.AdditionalProperties.userPrincipalName
        $GlobalAdmins.Add([PSCustomObject][Ordered]@{
            DisplayName = $DisplayName
            UserPrincipalName = $UPN})
    }
}

$GlobalAdmins = $($GlobalAdmins | select DisplayName,UserPrincipalName -Unique)
$GlobalAdminCount = @($GlobalAdmins).Count

if ( 2 < $GlobalAdminCount -lt 4) {
    $Result = "FAIL"
} elseif ( $GlobalAdminCount -gt 4) {
    $Result = "FAIL"
} else {
    $Result = "PASS"
}

Write-Host "** $($Result) : There are $($GlobalAdminCount) Global Administrators in the organization. **"
$GlobalAdmins | Format-Table
