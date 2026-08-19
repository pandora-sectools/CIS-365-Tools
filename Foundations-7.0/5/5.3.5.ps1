# 5.3.5 Ensure approval is required for Privileged Role Administrator activation (Automated)
# E5 Level 1

Connect-MgGraph -Scopes "RoleManagementPolicy.Read.Directory" -NoWelcome

$RoleDefinitionId = "e8611ab8-c189-46e8-94e1-60213ab1f814"

$AssignmentURI = "https://graph.microsoft.com/v1.0/policies/roleManagementPolicyAssignments?`$filter=scopeId eq '/' and scopeType eq 'DirectoryRole' and roleDefinitionId eq '$RoleDefinitionId'&`$select=policyId"
$Assignment = (Invoke-MgGraphRequest -Method GET -Uri $AssignmentURI).value |
    Select-Object -First 1

if ($null -eq $Assignment) {
    Write-Host "** FAIL : No role management policy assignment was found for Privileged Role Administrator. **"
    return
}

$PolicyId = $Assignment.policyId

$ApprovalURI = "https://graph.microsoft.com/v1.0/policies/roleManagementPolicies/$PolicyId/rules/Approval_EndUser_Assignment"
$Approval = Invoke-MgGraphRequest -Method GET -Uri $ApprovalURI

$Approvers = @(
    $Approval.setting.approvalStages |
        ForEach-Object { $_.primaryApprovers }
)

$Audit = [PSCustomObject]@{
    PolicyId           = $PolicyId
    IsApprovalRequired = $Approval.setting.isApprovalRequired
    ApproverCount      = $Approvers.Count
    Approvers          = ($Approvers | ForEach-Object { $_.id }) -join ", "
    AuditState         = "PASS"
}

if ($Audit.IsApprovalRequired -ne $true) { $Audit.AuditState = "FAIL" }
if ($Audit.ApproverCount -lt 1) { $Audit.AuditState = "FAIL" }

$Audit | Format-List

if ($Audit.AuditState -eq "PASS") {
    Write-Host "** PASS : Approval is required for Privileged Role Administrator activation. **"
} else {
    Write-Host "** FAIL : Approval is not correctly configured for Privileged Role Administrator activation. **"
}
