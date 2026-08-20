# 5.3.4 Ensure approval is required for Global Administrator role activation (Automated)
# E5 Level 1
# Entra ID P2

Connect-MgGraph -Scopes "RoleManagementPolicy.Read.Directory" -NoWelcome

$RoleDefinitionId = "62e90394-69f5-4237-9190-012177145e10"
$AssignmentURI = "https://graph.microsoft.com/v1.0/policies/roleManagementPolicyAssignments?" +
    "`$filter=scopeId eq '/' and scopeType eq 'DirectoryRole' and " +
    "roleDefinitionId eq '$RoleDefinitionId'&" +
    "`$select=policyId"
    
try {
    $Assignment = (Invoke-MgGraphRequest -Method GET -Uri $AssignmentURI -ErrorAction Stop).value |
        Select-Object -First 1

    if ($null -eq $Assignment) {
        Write-Host "** FAIL : No role management policy assignment was found for Global Administrator. **"
        return
    }
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

    Write-Host "** ERROR : Unable to retrieve the Global Administrator role management policy assignment. **"
    Write-Host $ErrorText
    return
}


$PolicyId = $Assignment.policyId
$ApprovalURI = "https://graph.microsoft.com/v1.0/policies/roleManagementPolicies/$PolicyId/rules/Approval_EndUser_Assignment"

try {
    $Approval = Invoke-MgGraphRequest -Method GET -Uri $ApprovalURI -ErrorAction Stop
}
catch {
    Write-Host "** ERROR : Unable to retrieve the Global Administrator approval rule. **"
    Write-Host $_.Exception.Message
    return
}

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
    Write-Host "** PASS : Approval is required for Global Administrator role activation. **"
} else {
    Write-Host "** FAIL : Approval is not correctly configured for Global Administrator role activation. **"
}
