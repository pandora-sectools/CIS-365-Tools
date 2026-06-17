# Gather all valid Microsoft 365 licenses for a tenancy

# Install if required:
# Install-Module Microsoft.Graph -Scope CurrentUser

Connect-MgGraph -Scopes "Organization.Read.All", "LicenseAssignment.Read.All" -NoWelcome

$LicenseReport = [System.Collections.Generic.List[Object]]::new()
$SubscribedSkus = Get-MgSubscribedSku -All

foreach ($Sku in $SubscribedSkus) {

    $Obj = [PSCustomObject]@{
        SkuPartNumber       = $Sku.SkuPartNumber
        SkuId               = $Sku.SkuId
        AppliesTo           = $Sku.AppliesTo
        CapabilityStatus    = $Sku.CapabilityStatus
        ConsumedUnits       = $Sku.ConsumedUnits
        EnabledUnits        = $Sku.PrepaidUnits.Enabled
        SuspendedUnits      = $Sku.PrepaidUnits.Suspended
        WarningUnits        = $Sku.PrepaidUnits.Warning
        AvailableUnits      = ($Sku.PrepaidUnits.Enabled - $Sku.ConsumedUnits)
        ServicePlans        = ($Sku.ServicePlans.ServicePlanName -join ", ")
        AuditState          = "VALID"
    }

    if ($Sku.CapabilityStatus -ne "Enabled") {
        $Obj.AuditState = "REVIEW"
    }

    $LicenseReport.Add($Obj)
}

$InvalidOrReviewLicenses = $LicenseReport | Where-Object {
    $_.AuditState -ne "VALID"
}

if (@($InvalidOrReviewLicenses).Count -gt 0) {
    Write-Host "** REVIEW : Some licenses are not in an Enabled state. **"
    $InvalidOrReviewLicenses | Format-Table SkuPartNumber,CapabilityStatus,EnabledUnits,ConsumedUnits,AvailableUnits,AuditState
} elseif (@($LicenseReport).Count -eq 0) {
    Write-Host "** INFO : No subscribed SKUs found for this tenancy. **"
} else {
    Write-Host "** INFO : Valid licenses gathered successfully. **"
    $LicenseReport | Format-Table SkuPartNumber,CapabilityStatus,EnabledUnits,ConsumedUnits,AvailableUnits
}

# # Optional export
# $ExportPath = ".\Tenant-License-Report.csv"
# $LicenseReport | Export-Csv -Path $ExportPath -NoTypeInformation

# Write-Host "** INFO : License report exported to $ExportPath **"
