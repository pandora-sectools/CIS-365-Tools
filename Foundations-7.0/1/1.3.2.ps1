# 1.3.2 Ensure 'Idle session timeout' is set to '3 hours (or less)' for unmanaged devices (Automated)
# E3 Level 2
# E5 Level 2

Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome

# Stage 1 : get the configured idle session timeout 
$TimeoutPolicy = Get-MgPolicyActivityBasedTimeoutPolicy
$BenchmarkTimeSpan = [TimeSpan]::Parse('03:00:00')

if (-not $TimeoutPolicy) {
    Write-Host "** FAIL : Idle session timeout is not configured. **"
    return
} 

# Stage 2 : Check Timeout meets the benchmark 
$PolicyDefinition = $TimeoutPolicy.Definition | ConvertFrom-Json
$Timeout = $PolicyDefinition.ActivityBasedTimeoutPolicy.ApplicationPolicies[0].WebSessionIdleTimeout
$TimeSpan = [TimeSpan]::Parse($Timeout)
$TimeoutReadable = "{0} days, {1} hours, {2} minutes" -f $TimeSpan.Days, $TimeSpan.Hours, $TimeSpan.Minutes

if ($TimeSpan -gt $BenchmarkTimeSpan) {
    Write-Host "** FAIL : Timeout is too long. It is set to $TimeoutReadable. **"
    return
} else {
    Write-Host "Timeout is set to $TimeoutReadable."
}


# Stage 3 : Filter to policies with "Use app enforced restrictions" 
# enabled, then Loop through policies and generate a per policy report.
$CapReport = [System.Collections.Generic.List[Object]]::new()
$Caps = Get-MgIdentityConditionalAccessPolicy -All | Where-Object {
    $_.SessionControls.ApplicationEnforcedRestrictions.IsEnabled
}

foreach ($Policy in $Caps) {
    
    $Obj = [PSCustomObject]@{
        DisplayName                 = $Policy.DisplayName
        IncludeUsers                = $Policy.Conditions.Users.IncludeUsers
        IncludeApplications         = $Policy.Conditions.Applications.IncludeApplications
        ClientAppTypes              = $Policy.Conditions.ClientAppTypes
        AppEnforcedRestrictions     = $Policy.SessionControls.ApplicationEnforcedRestrictions.IsEnabled
        State                       = $Policy.State
        AuditState                  = "PASS"
    }

    if (@($Obj.IncludeApplications).Count -ne 1) { $Obj.AuditState = "FAIL" }
    if (@($Obj.ClientAppTypes).Count -ne 1) { $Obj.AuditState = "FAIL" }
    if ($Obj.IncludeApplications -ne "Office365") { $Obj.AuditState = "FAIL" }
    if ($Obj.ClientAppTypes -ne "browser") { $Obj.AuditState = "FAIL" }
    if ($Obj.AppEnforcedRestrictions -ne $true) { $Obj.AuditState = "FAIL" }
    if ($Obj.State -ne "enabled") { $Obj.AuditState = "FAIL" }
    $CapReport.Add($Obj)
}

$PassingCaps = $CapReport | Where-Object { $_.AuditState -eq "PASS" }
if (@($PassingCaps).Count -gt 0) {
    Write-Host "** PASS : Found a compliant conditional access policy. **"
    $PassingCaps |Format-List
} else {
    Write-Host "** FAIL : There are no qualifying conditional access policies. **"
    $CapReport |Format-List
}
