# 5.3.1 Ensure 'Privileged Identity Management' is used to manage roles (Automated)
# E5 Level 2
# Entra ID P2

Connect-MgGraph -Scopes "RoleManagement.Read.Directory","RoleAssignmentSchedule.Read.Directory" -NoWelcome

$PrivilegedRoles = @(
    "Application Administrator",
    "Authentication Administrator",
    "Azure Information Protection Administrator",
    "Billing Administrator",
    "Cloud Application Administrator",
    "Cloud Device Administrator",
    "Compliance Administrator",
    "Customer LockBox Access Approver",
    "Exchange Administrator",
    "Fabric Administrator",
    "Global Administrator",
    "HelpDesk Administrator",
    "Intune Administrator",
    "Kaizala Administrator",
    "License Administrator",
    "Microsoft Entra Joined Device Local Administrator",
    "Password Administrator",
    "Privileged Authentication Administrator",
    "Privileged Role Administrator",
    "Security Administrator",
    "SharePoint Administrator",
    "Skype for Business Administrator",
    "Teams Administrator",
    "User Administrator"
)

$RoleURI = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions?`$select=id,displayName"

try {
    $RoleDefinitions = (Invoke-MgGraphRequest -Method GET -Uri $RoleURI -ErrorAction Stop).value
}
catch {
    Write-Host "** ERROR : Unable to retrieve directory role definitions. **"
    return
}

$AssignmentURI = "https://graph.microsoft.com/v1.0/roleManagement/directory/" +
    "roleAssignmentScheduleInstances?`$expand=principal"

try {
    $Assignments = (Invoke-MgGraphRequest -Method GET -Uri $AssignmentURI -ErrorAction Stop).value
}
catch {
    $ErrorText = @(
        $_.Exception.Message
        $_.ErrorDetails.Message
        $_ | Out-String
    ) -join "`n"

    if ($ErrorText -match "AadPremiumLicenseRequired") {
        Write-Host "** N/A : Microsoft Entra ID P2 or Microsoft Entra ID Governance licensing is required. **"
        return
    }

    Write-Host "** ERROR : Unable to retrieve privileged role assignments. **"
    return
}

$RoleReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Assignment in $Assignments) {

    $Role = $RoleDefinitions |
        Where-Object { $_.id -eq $Assignment.roleDefinitionId } |
        Select-Object -First 1

    if ($Role.displayName -notin $PrivilegedRoles) { continue }

    $PrincipalType = $Assignment.principal.'@odata.type'

    if ($PrincipalType -notin @(
        "#microsoft.graph.user",
        "#microsoft.graph.group"
    )) { continue }

    $Obj = [PSCustomObject]@{
        RoleName       = $Role.displayName
        PrincipalName  = $Assignment.principal.displayName
        PrincipalType  = $PrincipalType
        AssignmentType = $Assignment.assignmentType
        EndDateTime    = $Assignment.endDateTime
        AuditState     = "PASS"
    }

    if ($Obj.AssignmentType -eq "Assigned") { $Obj.AuditState = "FAIL" }

    $RoleReport.Add($Obj)
}

$FailingAssignments = $RoleReport |
    Where-Object { $_.AuditState -eq "FAIL" }

if (@($FailingAssignments).Count -gt 0) {
    Write-Host "** FAIL : Permanent privileged role assignments were found. **"
    $FailingAssignments | Format-List
} else {
    Write-Host "** PASS : Privileged role assignments are managed using PIM. **"
    $RoleReport | Format-List
}