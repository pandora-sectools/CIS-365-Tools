# 5.3.3 Ensure 'Access reviews' for privileged roles are configured (Automated)
# E5 Level 1

Connect-MgGraph -Scopes "AccessReview.Read.All" -NoWelcome

$RequiredRoles = @{
    "62e90394-69f5-4237-9190-012177145e10" = "Global Administrator"
    "e8611ab8-c189-46e8-94e1-60213ab1f814" = "Privileged Role Administrator"
    "29232cdf-9323-42fd-ade2-1d097af3e4de" = "Exchange Administrator"
    "f28a1f50-f6e7-4571-818b-6a12f2af6b6c" = "SharePoint Administrator"
    "69091246-20e8-4a56-aa4d-066075b2a7a8" = "Teams Administrator"
    "194ae4cb-b126-40b2-bd5b-6091b380977d" = "Security Administrator"
}

$URI = "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions"
$Reviews = (Invoke-MgGraphRequest -Method GET -Uri $URI).value

$ReviewReport = [System.Collections.Generic.List[Object]]::new()

foreach ($RoleId in $RequiredRoles.Keys) {

    $RoleName = $RequiredRoles[$RoleId]

    $RoleReviews = $Reviews | Where-Object {
        @($_.scope.resourceScopes.query) -match "/directory/roleDefinitions/$RoleId"
    }

    foreach ($Review in $RoleReviews) {

        $PrincipalQueries = @($Review.scope.principalScopes.query)
        $Reviewers = @($Review.reviewers)
        $StartDate = $Review.settings.recurrence.range.startDate

        $Obj = [PSCustomObject]@{
            RoleName                        = $RoleName
            RoleDefinitionId                = $RoleId
            DisplayName                     = $Review.displayName
            RecurrenceType                  = $Review.settings.recurrence.pattern.type
            RecurrenceStartDate             = $StartDate
            ReviewerCount                   = $Reviewers.Count
            MailNotificationsEnabled        = $Review.settings.mailNotificationsEnabled
            ReminderNotificationsEnabled    = $Review.settings.reminderNotificationsEnabled
            JustificationRequiredOnApproval = $Review.settings.justificationRequiredOnApproval
            InstanceDurationInDays          = $Review.settings.instanceDurationInDays
            AutoApplyDecisionsEnabled       = $Review.settings.autoApplyDecisionsEnabled
            DefaultDecision                 = $Review.settings.defaultDecision
            IncludesUsers                   = $PrincipalQueries -match "/v1.0/users"
            IncludesGroups                  = $PrincipalQueries -match "/v1.0/groups"
            AuditState                      = "PASS"
        }

        if ($Obj.RecurrenceType -notin @("absoluteMonthly","weekly")) { $Obj.AuditState = "FAIL" }
        if ([datetime]$Obj.RecurrenceStartDate -gt (Get-Date)) { $Obj.AuditState = "FAIL" }
        if ($Obj.ReviewerCount -lt 1) { $Obj.AuditState = "FAIL" }
        if ($Obj.MailNotificationsEnabled -ne $true) { $Obj.AuditState = "FAIL" }
        if ($Obj.ReminderNotificationsEnabled -ne $true) { $Obj.AuditState = "FAIL" }
        if ($Obj.JustificationRequiredOnApproval -ne $true) { $Obj.AuditState = "FAIL" }
        if ($Obj.InstanceDurationInDays -gt 14) { $Obj.AuditState = "FAIL" }
        if ($Obj.AutoApplyDecisionsEnabled -ne $true) { $Obj.AuditState = "FAIL" }
        if ($Obj.DefaultDecision -ne "None") { $Obj.AuditState = "FAIL" }
        if ($Obj.IncludesUsers -ne $true) { $Obj.AuditState = "FAIL" }
        if ($Obj.IncludesGroups -ne $true) { $Obj.AuditState = "FAIL" }

        $ReviewReport.Add($Obj)
    }
}

$CompliantRoles = $ReviewReport |
    Where-Object { $_.AuditState -eq "PASS" } |
    Select-Object -ExpandProperty RoleDefinitionId -Unique

$MissingRoles = $RequiredRoles.Keys |
    Where-Object { $_ -notin $CompliantRoles }

if (@($MissingRoles).Count -eq 0) {
    Write-Host "** PASS : All required privileged roles have compliant access reviews. **"
    $ReviewReport | Where-Object { $_.AuditState -eq "PASS" } | Format-List
} else {
    Write-Host "** FAIL : One or more required privileged roles do not have a compliant access review. **"

    foreach ($RoleId in $MissingRoles) {
        Write-Host "Missing/Non-compliant: $($RequiredRoles[$RoleId])"
    }

    $ReviewReport | Format-List
}
