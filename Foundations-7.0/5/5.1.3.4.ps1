# 5.1.3.4 Ensure that 'Users can create Microsoft 365 groups in Azure portals, API or PowerShell' is set to 'No' (Automated)
# E3 Level 2
# E5 Level 2

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

$GroupSettings = Invoke-MgGraphRequest `
    -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/groupSettings"

$GroupCreationSettings = $GroupSettings.value | Where-Object {$_.templateId -eq "62375ab9-6b52-47ed-826b-58e47e0e304b"}
$EnableGroupCreation = ($GroupCreationSettings.values | Where-Object {$_.name -eq "EnableGroupCreation" }).value
Write-Host "EnableGroupCreation $($EnableGroupCreation)"

if ($EnableGroupCreation -eq "False") {
    Write-Host "** PASS **"
} else {
    Write-Host "** FAIL **"
}
