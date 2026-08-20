# 5.1.8.1 Ensure that password hash sync is enabled for hybrid deployments (Automated)*
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "OnPremDirectorySynchronization.Read.All" -NoWelcome

$URI = "https://graph.microsoft.com/v1.0/directory/onPremisesSynchronization"

try {
    $OnPremSync = (Invoke-MgGraphRequest -Method GET -Uri $URI -ErrorAction Stop).value
}
catch {
    Write-Host "** FAIL : Unable to query on-premises synchronization configuration. **"
    Write-Host $_.Exception.Message
    return
}

$SyncReport = [System.Collections.Generic.List[Object]]::new()

foreach ($Sync in $OnPremSync) {

    $Obj = [PSCustomObject]@{
        PasswordSyncEnabled = $Sync.features.passwordSyncEnabled
        AuditState          = "PASS"
    }

    if ($Obj.PasswordSyncEnabled -ne $true) {
        $Obj.AuditState = "FAIL"
    }

    $SyncReport.Add($Obj)
}

$FailingSync = $SyncReport |
    Where-Object { $_.AuditState -eq "FAIL" }

if (@($SyncReport).Count -eq 0) {
    Write-Host "** N/A : No on-premises synchronization configuration was found. **"
}
elseif (@($FailingSync).Count -gt 0) {
    Write-Host "** FAIL : Password hash synchronization is not enabled. **"
    $SyncReport | Format-List
} else {
    Write-Host "** PASS : Password hash synchronization is enabled. **"
    $SyncReport | Format-List
}