# 1.2.1 Ensure that only organizationally managed/approved public groups exist (Automated)
# E3 Level 2
# E5 Level 2

Connect-MgGraph -Scopes "Group.Read.All" -NoWelcome

$Groups = Get-MgGroup -All -Filter "groupTypes/any(c:c eq 'Unified')" -Property Id,DisplayName,Visibility,GroupTypes

# Displays the groups to the console for review
$Groups | ForEach-Object {
    if ($_.Visibility -ne "Private") {
        [PSCustomObject]@{
            Id          = $_.Id
            DisplayName = $_.DisplayName
            Visibility  = $_.Visibility
        }
    }
} | Format-Table -AutoSize
