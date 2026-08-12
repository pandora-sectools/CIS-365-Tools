# CIS-365-Tools - Helper tools for CIS Benchmarking


**NOTE** The scripts in this repoistory are untested and sometimes incomplete. Not all Benchmark versions
have a working published script.

Current Supported CIS benchmark versions:
- **7.0 Level 1**


### Required Testing Tools
CLI Programs:
- Windows Terminal
- Microsoft.AzureCLI

- PowerShell Modules:
    - PnP.PowerShell 3.1.0
    - Packagemangement
    - PowershellGet
    - ExchangePowerShell
    - ExchangeOnlineManagement 3.9.2
    - MicrosoftTeams 7.7.0
    - Microsoft.Online.Sharepoint.PowerShell 16.0.27111.12000
    - Microsoft365DSC
    - Microsoft.Graph
        - Microsoft.Graph.Applications
        - Microsoft.Graph.DeviceManagement
        - Microsoft.Graph.Identity.Governance
        - Microsoft.Graph.Identity.SignIns
        - Microsoft.Graph.Identity.DirectooryManagement
        - Microsoft.Graph.Reports
        - Microsoft.Graph.Users
        - Microsoft.Graph.Authentication
        - Microsoft.Graph.Identity.SignIns

**NOTE** Be sure to remove all Az powershell modules. they conflict with the AzureCLI Tools
and can cause these scripts to not run correctly! Remove with this command:

```powershell
    Get-Module -ListAvailable "Az.*" | ForEach {Uninstall-Module -Name $_.Name}

```


### Required Test User Permissions

Required Roles:
- Global Reader
- Reports Reader
- Security Reader
- Teams Reader
- SharePoint Administrator
- Exchange Administrator
- InTune Administrator / Intune Read Only Operator
- View-Only Organization Management
- Graph Data Connect Administrator
- Privileged Role Administrator

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
