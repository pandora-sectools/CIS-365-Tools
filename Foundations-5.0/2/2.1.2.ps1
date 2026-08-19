# 2.1.2 Ensure the Common Attachment Types Filter is enabled (Automated)
# E3 Level 1
# E5 Level 1

# connect to exchange if not already connected
Import-Module ExchangeOnlineManagement -RequiredVersion 3.9.2
if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
    Connect-ExchangeOnline -ShowBanner:$false
}

# Create a collection of required extensions
$RequiredExtensions = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)

@(
"ani", "apk", "app", "appx", "arj", "bat", "cab", "cmd", "com", "deb", "dex", "dll", "docm",
"elf", "exe", "hta", "img", "iso", "jar", "jnlp", "kext", "lha", "lib", "library", "lnk", "lzh",
"macho", "msc", "msi", "msix", "msp", "mst", "pif", "ppa", "ppam", "reg", "rev", "scf", "scr",
"sct", "sys", "uif", "vb", "vbe", "vbs", "vxd", "wsc", "wsf", "wsh", "xll", "xz", "z", "ace"
) | ForEach-Object { [void]$RequiredExtensions.Add($_) }

$ConfiguredFileTypes = @()

Write-Host "Get-MalwareFilterPolicy | Where-Object { `$_.Name -eq `"Default`" }"
$DefaultPolicy = Get-MalwareFilterPolicy | Where-Object { $_.Name -eq "Default" }

foreach ($Extension in $DefaultPolicy.FileTypes) {
    [void]$RequiredExtensions.Remove($Extension)
    $ConfiguredFileTypes += ".$Extension"
}


if (-not $DefaultPolicy) {
    Write-Host "** FAIL : Default Malware Filter Policy not found. **"
    return
}

if (-not $DefaultPolicy.EnableFileFilter) {
    Write-Host "** FAIL : EnableFileFilter is disabled. **"
    return
}

if ($RequiredExtensions.Count -gt 0) {
    $MissingExtensions = ($RequiredExtensions | Sort-Object ) -join ', '
    Write-Host "** INFO : Missing Extensions ** `n $MissingExtensions"
    Write-Host "This is not an issue for Foundations 5.0 Compliance"
}

Write-Host "** PASS : Common Attachment Filter is Enabled. **"
