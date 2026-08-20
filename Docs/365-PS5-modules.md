# Microsoft 365 Windows PowerShell 5.1 Test Environment Setup


### Install KVM/libVirt drivers

Install via binary installers:

- [.NET Framework 4.7.2 or later](https://dotnet.microsoft.com/en-us/download/dotnet-framework)
- [AzureCLI - We do not use AZ Powershell, it sucks](https://aka.ms/installazurecliwindowsx64)
- [WinFSP - Helpful for Shared Folders](https://winfsp.dev/rel/)
- [VirtIO - Windows Guest Tools](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso)

Can also be installed with Winget:
- `winget install --exact --id Microsoft.DotNet.Framework.DeveloperPack_4 --source winget`
- `winget install --exact --id Microsoft.AzureCLI --source winget`
- `winget install --exact --id RedHat.VirtIO`
- `winget install --exact --id WinFsp.WinFsp`


### Configure Terminal

Scripts will not work by default. Requires setup.

**For PS5, Use Windows PowerShell 5.1 (`powershell.exe`), not PowerShell 7 (`pwsh.exe`).**

- Confirm the shell version:
  - `$PSVersionTable.PSVersion`
- Set the execution policy to bypass restrictions for testing scripts:
  - `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy bypass -Force`
- Ensure TLS 1.2 is enabled before using PowerShell Gallery:
  - `[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12`
- Set PSGallery as trusted:
  - `Set-PSRepository -Name PSGallery -InstallationPolicy Trusted`

### Uninstall ALL PS5 Microsoft 365 PowerShell Modules

Remove old or conflicting module versions before installing the pinned module set.

- Remove all AZ Modules. We use AzureCLI instead, and having both installed causes problems.
  - `Get-InstalledModule -Name Az.* -ErrorAction SilentlyContinue | ForEach-Object { Uninstall-Module -Name $_.Name -AllVersions -Force }`
  - `Uninstall-Module -Name Az -AllVersions -Force`
- Graph modules removal
  - `Get-InstalledModule -Name Microsoft.Graph.* -ErrorAction SilentlyContinue | ForEach-Object { Uninstall-Module -Name $_.Name -AllVersions -Force }`
  - `Uninstall-Module -Name Microsoft.Graph -AllVersions -Force`
- ExchangeOnlineManagement Removal
  - `Uninstall-Module -Name ExchangeOnlineManagement -AllVersions -Force`
- MicrosoftTeams Removal
  - `Uninstall-Module -Name MicrosoftTeams -AllVersions -Force`
- SharePoint Removal
  - `Uninstall-Module -Name Microsoft.Online.SharePoint.PowerShell -AllVersions -Force`
- ExchangePowerShell Removal
  - `Uninstall-Module -Name ExchangePowerShell -AllVersions -Force`
- 365 DSC Removal
  - `Uninstall-Module -Name Microsoft365DSC -AllVersions -Force`


### Reinstall PowerShell Modules

We need to pin Exchange Online, Teams, and Microsoft Graph to the versions compatible with the CIS checks.
This avoids a multitude of bugs caused by the awful Module Code (e.g. Microsoft.IdentityModel conflict)

Do **NOT** reinstall any modules. Pin the given versions **ONLY.** newer versions have bugs and do not work. 

- PSResourceGet
  - `Install-Module -Name PowerShellGet -Force -AllowClobber`
- Exchange Online Management **3.4.0**
  - `Install-Module -Name ExchangeOnlineManagement -RequiredVersion 3.4.0 -Scope CurrentUser -Force`
- Exchange PowerShell
  - `Install-Module -Name ExchangePowerShell -Scope CurrentUser -Force`
- Microsoft Teams **5.6.0**
  - `Install-Module -Name MicrosoftTeams -RequiredVersion 5.6.0 -Scope CurrentUser -Force`
- SharePoint Online
  - `Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force`
- Microsoft 365 DSC
  - `Install-Module -Name Microsoft365DSC -Scope CurrentUser -Force`

Do **NOT** install the `Microsoft.Graph` umbrella module
Install the required Microsoft Graph workload modules individually at **2.25.0**:

- `Install-Module -Name Microsoft.Graph.Authentication -RequiredVersion 2.25.0 -Scope CurrentUser -Force`
- `Install-Module -Name Microsoft.Graph.Applications -RequiredVersion 2.25.0 -Scope CurrentUser -Force`
- `Install-Module -Name Microsoft.Graph.DeviceManagement -RequiredVersion 2.25.0 -Scope CurrentUser -Force`
- `Install-Module -Name Microsoft.Graph.Groups -RequiredVersion 2.25.0 -Scope CurrentUser -Force`
- `Install-Module -Name Microsoft.Graph.Identity.DirectoryManagement -RequiredVersion 2.25.0 -Scope CurrentUser -Force`
- `Install-Module -Name Microsoft.Graph.Identity.Governance -RequiredVersion 2.25.0 -Scope CurrentUser -Force`
- `Install-Module -Name Microsoft.Graph.Identity.SignIns -RequiredVersion 2.25.0 -Scope CurrentUser -Force`
- `Install-Module -Name Microsoft.Graph.Reports -RequiredVersion 2.25.0 -Scope CurrentUser -Force`
- `Install-Module -Name Microsoft.Graph.Users -RequiredVersion 2.25.0 -Scope CurrentUser -Force`
- `Install-Module -Name Microsoft.Graph.DirectoryObjects -RequiredVersion 2.25.0 -Scope CurrentUser -Force`


### Verify Module Versions

- `Get-Module ExchangeOnlineManagement -ListAvailable | Select-Object Name,Version,Path`
- `Get-Module MicrosoftTeams -ListAvailable | Select-Object Name,Version,Path`
- `Get-Module Microsoft.Graph* -ListAvailable | Select-Object Name,Version,Path | Sort-Object Name,Version`

Expected core versions:

- ExchangeOnlineManagement: **3.4.0**
- MicrosoftTeams: **5.6.0**
- Microsoft.Graph workload modules: **2.25.0**


### Test Module Compatibility

Use a new `powershell.exe -NoProfile` session between each test.

Test Exchange Online then Graph. This matches the mixed Exchange / Graph CIS pattern:

- `Connect-ExchangeOnline -ShowBanner:$false`
- `Connect-MgGraph -Scopes "User.Read.All" -NoWelcome`
- `Get-EXOMailbox -RecipientTypeDetails SharedMailbox -ResultSize 1`
- `Get-MgUser -Top 1 -Property DisplayName,UserPrincipalName,AccountEnabled`

Test Graph then Exchange Online:

- `Connect-MgGraph -Scopes "User.Read.All" -NoWelcome`
- `Connect-ExchangeOnline -ShowBanner:$false`
- `Get-MgUser -Top 1`
- `Get-EXOMailbox -ResultSize 1`

Test Teams then Exchange Online:

- `Connect-MicrosoftTeams`
- `Get-CsTeamsMessagingPolicy -Identity Global | Format-List AllowSecurityEndUserReporting`
- `Connect-ExchangeOnline -ShowBanner:$false`
- `Get-ReportSubmissionPolicy | Format-List Report*`

Test Exchange Online then Teams:

- `Connect-ExchangeOnline -ShowBanner:$false`
- `Get-ReportSubmissionPolicy | Format-List Report*`
- `Connect-MicrosoftTeams`
- `Get-CsTeamsMessagingPolicy -Identity Global | Format-List AllowSecurityEndUserReporting`

Test all three modules in the same Windows PowerShell process:

- `Connect-ExchangeOnline -ShowBanner:$false`
- `Connect-MgGraph -Scopes "User.Read.All" -NoWelcome`
- `Connect-MicrosoftTeams`
- `Get-EXOMailbox -ResultSize 1`
- `Get-MgUser -Top 1`
- `Get-CsTeamsMessagingPolicy -Identity Global`

Check Exchange / Defender commands used by the CIS snippets:

- `Get-Command Get-SafeLinksPolicy`
- `Get-Command Get-ReportSubmissionPolicy`
- `Get-Command Get-AntiPhishPolicy`
- `Get-Command Get-MalwareFilterPolicy`

Missing Exchange / Defender commands can also be caused by tenant licensing or RBAC and do not necessarily
indicate a local module compatibility problem.


### Setup 365 Testing Account

Required Roles:

- Global Reader
- Reports Reader
- Security Reader
- Teams Reader
- SharePoint Administrator
- Exchange Administrator
- Identity Governance Administrator
- InTune Administrator / Intune Read Only Operator
- View-Only Organization Management
- Graph Data Connect Administrator

MGGraph Permissions:

- AccessReview.Read.All
- Organization.Read.All
- Directory.Read.All
- Policy.Read.All
- Domain.Read.All
- User.Read.All
- Group.Read.All
- AuditLog.Read.All
- RoleManagement.Read.Directory
- UserAuthenticationMethod.Read.All
- OrgSettings-Forms.Read.All
- OrgSettings-AppsAndServices.Read.All
- DeviceManagementConfiguration.Read.All
- DeviceManagementManagedDevices.Read.All
- DeviceManagementServiceConfig.Read.All
- OnPremDirectorySynchronization.Read.All
