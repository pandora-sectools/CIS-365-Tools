# 9.1.1 Ensure guest user access is restricted (Automated)
# E3 Level 1
# E5 Level 1

# Connect to AZ if not already connected
if (-not $(az account show --output json 2>$null | ConvertFrom-Json)) {
    az Login --allow-no-subscriptions --output None
}

# Obtain Fabric access token

$AccessToken = az account get-access-token `
    --resource "https://api.fabric.microsoft.com" `
    --query accessToken `
    -o tsv 2>$null

if (-not $AccessToken) {
    az logout
    az login `
        --allow-no-subscriptions `
        --scope "https://api.fabric.microsoft.com/.default" `
        --output None

    $AccessToken = az account get-access-token `
        --resource "https://api.fabric.microsoft.com" `
        --query accessToken `
        -o tsv
}


try {
    $Headers = @{Authorization = "Bearer $($AccessToken)"}
    $Uri = "https://api.fabric.microsoft.com/v1/admin/tenantsettings"
    $TenantSettings = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers -ErrorAction Stop
} catch {
    switch ($_.Exception.Response.StatusCode.value__) {
        403 {Write-Host "** FAIL : Fabric Access is denied. (need Fabric admin?) **"}
    } return
}
