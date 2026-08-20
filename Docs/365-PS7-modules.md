# Microsoft 365 PowerShell 7 Test Environment Setup

### Install KVM/libVirt drivers

Install via binary installers:

- [PS7 - PS5 causes some issues](https://github.com/PowerShell/PowerShell/releases/download/v7.6.4/PowerShell-7.6.4-win-x64.msi)
- [AzureCLI - We do not use AZ Powershell, it sucks](https://aka.ms/installazurecliwindowsx64)
- [WinFSP - Helpful for Shared Folders](https://winfsp.dev/rel/)
- [VirtIO - Windows Guest Tools](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso)

Can also be installed with Winget:

- `winget install --exact --id Microsoft.PowerShell --source winget`
- `winget install --exact --id Microsoft.AzureCLI --source winget`
- `winget install --exact --id RedHat.VirtIO`
- `winget install --exact --id WinFsp.WinFsp`


### Configure Terminal

Scripts will not work by default. Requires setup.

- After installing PowerShell 7, make sure to set it as the default in Windows Terminal.
- Set the execution policy to bypass restrictions for testing scripts:
  - `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy bypass -Force`


### Uninstall ALL PS5 & PS7 Microsoft 365 PowerShell Modules

Remove old or conflicting module versions before installing the pinned module set.

- Remove all AZ Modules. We use AzureCLI instead, and having both installed causes problems.
  - `Get-InstalledPSResource -Name Az.* -ErrorAction SilentlyContinue | ForEach-Object { Uninstall-PSResource -Name $_.Name -Version $_.Version }`
  - `Uninstall-PSResource -Name Az`
- Graph modules removal
  - `Get-InstalledPSResource -Name Microsoft.Graph.* -ErrorAction SilentlyContinue | ForEach-Object { Uninstall-PSResource -Name $_.Name -Version $_.Version }`
  - `Uninstall-PSResource -Name Microsoft.Graph`
- ExchangeOnlineManagement Removal
  - `Get-InstalledPSResource -Name ExchangeOnlineManagement -ErrorAction SilentlyContinue | ForEach-Object { Uninstall-PSResource -Name $_.Name -Version $_.Version }`
- MicrosoftTeams Removal
  - `Get-InstalledPSResource -Name MicrosoftTeams -ErrorAction SilentlyContinue | ForEach-Object { Uninstall-PSResource -Name $_.Name -Version $_.Version }`
- SharePoint Removal
  - `Uninstall-PSResource -Name Microsoft.Online.SharePoint.PowerShell`
- ExchangePowerShell Removal
  - `Uninstall-PSResource -Name ExchangePowerShell`
- 365 DSC Removal
  - `Uninstall-PSResource -Name Microsoft365DSC `


### Reinstall PowerShell Modules

We need to pin Exchange Online, Teams, and Microsoft Graph to the versions used to validate the CIS 7.0 PowerShell snippets.
This avoids a multitude of bugs caused by the awful Module Code (e.g. Microsoft.IdentityModel conflict)

Do **NOT** reinstall any modules. Pin the given versions **ONLY.** newer versions have bugs and do not work. 

- PSResourceGet
  - `Install-PSResource -Name Microsoft.PowerShell.PSResourceGet -Reinstall -TrustRepository -ErrorAction Continue`
- Exchange Online Management **3.9.2**
  - `Install-PSResource -Name ExchangeOnlineManagement -Version 3.9.2 -Scope CurrentUser -TrustRepository -ErrorAction Continue`
- Microsoft Teams **7.7.0**
  - `Install-PSResource -Name MicrosoftTeams -Version 7.7.0 -Scope CurrentUser -TrustRepository -ErrorAction Continue`
- SharePoint Online **16.0.27111.12000**
  - `Install-PSResource -Name Microsoft.Online.SharePoint.PowerShell -Version 16.0.27111.12000 -TrustRepository -ErrorAction Continue`
- Microsoft 365 DSC **1.26.812.1**
  - `Install-PSResource -Name Microsoft365DSC -TrustRepository -ErrorAction Continue`
- Microsoft PnP.Powershell
  - `Install-PSResource -Name PnP.PowerShell -Version 3.1.0 -TrustRepository -ErrorAction Continue`


Do **NOT** install the `Microsoft.Graph` umbrella module
Install the required Microsoft Graph workload modules individually at **2.36.1**:

- `Install-PSResource -Name Microsoft.Graph.Applications -Version 2.36.1 -TrustRepository -ErrorAction Continue`
- `Install-PSResource -Name Microsoft.Graph.Authentication -Version 2.36.1 -TrustRepository -ErrorAction Continue`
- `Install-PSResource -Name Microsoft.Graph.DeviceManagement -Version 2.36.1 -TrustRepository -ErrorAction Continue`
- `Install-PSResource -Name Microsoft.Graph.Groups -Version 2.36.1 -TrustRepository -ErrorAction Continue`
- `Install-PSResource -Name Microsoft.Graph.Identity.DirectoryManagement -Version 2.36.1 -TrustRepository -ErrorAction Continue`
- `Install-PSResource -Name Microsoft.Graph.Identity.Governance -Version 2.36.1 -TrustRepository -ErrorAction Continue`
- `Install-PSResource -Name Microsoft.Graph.Identity.SignIns -Version 2.36.1 -TrustRepository -ErrorAction Continue`
- `Install-PSResource -Name Microsoft.Graph.Reports -Version 2.36.1 -TrustRepository -ErrorAction Continue`
- `Install-PSResource -Name Microsoft.Graph.Users -Version 2.36.1 -TrustRepository -ErrorAction Continue`
- `Install-PSResource -Name Microsoft.Graph.DirectoryObjects -Version 2.36.1 -TrustRepository -ErrorAction Continue`



### Verify Module Versions

- `Get-Module ExchangeOnlineManagement -ListAvailable | Select-Object Name,Version,Path`
- `Get-Module MicrosoftTeams -ListAvailable | Select-Object Name,Version,Path`
- `Get-Module Microsoft.Graph* -ListAvailable | Select-Object Name,Version,Path | Sort-Object Name,Version`

Expected core versions:

- ExchangeOnlineManagement: **3.9.2**
- MicrosoftTeams: **7.7.0**
- Microsoft.Graph workload modules: **2.36.1**


### Test Module Compatibility

Use a new `pwsh -NoProfile` session between each test.

Test Exchange Online then Graph. This matches CIS 1.2.2:

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

Test all three modules in the same PowerShell process:

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

Missing Exchange / Defender commands can also be caused by tenant licensing or RBAC and do not necessarily indicate a local module compatibility problem.


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
