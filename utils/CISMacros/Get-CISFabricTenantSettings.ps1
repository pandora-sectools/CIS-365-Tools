function Get-CISFabricTenantSettings {
    # <#
    # .DESCRIPTION
    # Collects Microsoft Fabric tenant settings via Fabric REST API.
    # .PARAMETER TenantParams
    # Hashtable containing service principal authentication parameters
    # (ApplicationId, TenantId, CertificateThumbprint)
    # .PARAMETER Interactive
    # Switch to use interactive user authentication
    # #>

    [CmdletBinding(DefaultParameterSetName = 'ServicePrincipal')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'ServicePrincipal')]
        [hashtable]$TenantParams,
        [Parameter(Mandatory = $true, ParameterSetName = 'Interactive')]
        [switch]$Interactive
    )

    try {
        if ($Interactive) {
            # Interactive user authentication
            $null = Connect-AzAccount -ErrorAction Stop
        }
        else {
            # Service principal authentication
            $null = Connect-AzAccount `
                -CertificateThumbprint $TenantParams.CertificateThumbprint `
                -ApplicationId $TenantParams.ApplicationId `
                -TenantId $TenantParams.TenantId `
                -ServicePrincipal `
                -ErrorAction Stop
        }

        # Get access token
        $ResourceURL = 'https://api.fabric.microsoft.com'
        $AccessToken = Get-AzAccessToken -ResourceUrl $ResourceURL -AsSecureString

    } catch {
        Write-Error "Failed to connect or retrieve access token: $_"
        return $null
    } finally {
        [void](Disconnect-AzAccount -ErrorAction SilentlyContinue)
    }

    # Collect Fabric tenant settings
    if ($AccessToken) {
        $SettingsFilter = @(
            'AllowGuestUserToAccessSharedContent'
            'ExternalSharingV2'
            'ElevatedGuestsTenant'
            'PublishToWeb'
            'RScriptVisual'
            'EimInformationProtectionEdit'
            'ShareLinkToEntireOrg'
            'EnableDatasetInPlaceSharing'
            'BlockResourceKeyAuthentication'
            'ServicePrincipalAccessPermissionAPIs'
            'AllowServicePrincipalsCreateAndUseProfiles'
            'ServicePrincipalAccessGlobalAPIs'
        )
        try {
            $Uri = 'https://api.fabric.microsoft.com/v1/admin/tenantsettings'
            $params = @{
                Uri = $Uri
                Method = 'Get'
                Authentication = 'Bearer'
                Token = $AccessToken.Token
            }

            $TenantSettings = (Invoke-RestMethod @params).tenantsettings | Where-Object { $_.settingName -in $SettingsFilter }
            return $TenantSettings
        } catch {
            Write-Error "Failed to retrieve Fabric tenant settings: $_"
            return $null
        } finally {
            # Clean up
            Clear-Variable -Name AccessToken, params -ErrorAction SilentlyContinue
        }
    }
}