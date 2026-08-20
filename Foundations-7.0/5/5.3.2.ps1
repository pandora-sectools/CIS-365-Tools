# 5.3.2 Ensure 'Access reviews' for guest users are configured (Automated)
# E5 Level 1

Connect-MgGraph -Scopes "AccessReview.Read.All" -NoWelcome

$URI = "https://graph.microsoft.com/v1.0/identityGovernance/accessReviews/definitions"

try {
    $Reviews = (Invoke-MgGraphRequest -Method GET -Uri $URI -ErrorAction Stop).value
}
catch {
    Write-Host "** ERROR : Unable to retrieve access reviews. Check AccessReview.Read.All and the signed-in user's Entra role. **"
    Write-Host $_.Exception.Message
    return
}

$ReviewReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Review in $Reviews) {

    $ResourceQueries = @($Review.scope.resourceScopes.query)
    $ScopeQuery      = $Review.scope.query
    $Reviewers       = @($Review.reviewers)

    $IsGuestReview = (
        ($ResourceQueries -match "userType eq 'Guest'").Count -gt 0 -or
        $ScopeQuery -match "userType eq 'Guest'"
    )

    if (-not $IsGuestReview) { continue }

    $Obj = [PSCustomObject]@{
        DisplayName                     = $Review.displayName
        Status                          = $Review.status
        ScopeQuery                      = $ScopeQuery
        ResourceScopeQueries            = $ResourceQueries -join ", "
        RecurrenceType                  = $Review.settings.recurrence.pattern.type
        RecurrenceRange                 = $Review.settings.recurrence.range.type
        ReviewerCount                   = $Reviewers.Count
        MailNotificationsEnabled        = $Review.settings.mailNotificationsEnabled
        ReminderNotificationsEnabled    = $Review.settings.reminderNotificationsEnabled
        InstanceDurationInDays          = $Review.settings.instanceDurationInDays
        JustificationRequiredOnApproval = $Review.settings.justificationRequiredOnApproval
        AutoApplyDecisionsEnabled       = $Review.settings.autoApplyDecisionsEnabled
        DefaultDecision                 = $Review.settings.defaultDecision
        AuditState                      = "PASS"
    }

    if ($Obj.RecurrenceType -notin @("absoluteMonthly","weekly")) { $Obj.AuditState = "FAIL" }
    if ($Obj.ReviewerCount -lt 1) { $Obj.AuditState = "FAIL" }
    if ($Obj.MailNotificationsEnabled -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.InstanceDurationInDays -gt 14) { $Obj.AuditState = "FAIL" }
    if ($Obj.ReminderNotificationsEnabled -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.JustificationRequiredOnApproval -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.AutoApplyDecisionsEnabled -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.DefaultDecision -ne "Deny") { $Obj.AuditState = "FAIL" }
    if ($Obj.RecurrenceRange -ne "noEnd") { $Obj.AuditState = "FAIL" }

    $ReviewReport.Add($Obj)
}

$PassingReviews = $ReviewReport |
    Where-Object { $_.AuditState -eq "PASS" }

if (@($PassingReviews).Count -gt 0) {
    Write-Host "** PASS : Found a compliant access review for guest users. **"
    $PassingReviews | Format-List
} else {
    Write-Host "** FAIL : No qualifying access review for guest users was found. **"
    $ReviewReport | Format-List
}