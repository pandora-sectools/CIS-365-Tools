# 5.1.3.1 Ensure a dynamic group for guest users is created (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "Group.Read.All" -NoWelcome

$DynamicGroups = Get-MgGroup -All |
    Where-Object { $_.GroupTypes -contains "DynamicMembership" }

$GuestGroups = $DynamicGroups |
    Where-Object { $_.MembershipRule -match 'user\.userType\s+-eq\s+"Guest"' }

$GroupReport = foreach ($Group in $GuestGroups) {

    [PSCustomObject]@{
        DisplayName                   = $Group.DisplayName
        GroupTypes                    = $Group.GroupTypes -join ", "
        MembershipRule                = $Group.MembershipRule
        MembershipRuleProcessingState = $Group.MembershipRuleProcessingState
    }
}

$GroupReport | Format-List

if (@($GuestGroups).Count -gt 0) {
    Write-Host "** PASS : A dynamic group for guest users exists. **"
} else {
    Write-Host "** FAIL : No dynamic group for guest users was found. **"
}
