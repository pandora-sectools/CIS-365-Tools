# CIS-365-Tools - Helper tools for CIS Benchmarking


**NOTE :** The scripts in this repoistory are untested and sometimes incomplete. Not all Benchmark versions
have a working published script.

Current Supported CIS benchmark versions:
- **Foundations 5.0 (L1,L2)**
- **Foundations 7.0 (L1,L2)**


### Required Testing Tools
```
CLI Programs:
- Windows Terminal
- Microsoft.AzureCLI

- PowerShell Modules:
    - PnP.PowerShell                                                         3.1.0
    - Packagemangement
    - PowershellGet
    - ExchangeOnlineManagement                                               3.9.2
    - MicrosoftTeams                                                         7.7.0
    - Microsoft.Online.Sharepoint.PowerShell                      16.0.27111.12000
    - Microsoft365DSC                                                   1.26.812.1
    - Microsoft.Graph.Authentication                                        2.36.1
    - Microsoft.Graph.Applications                                          2.36.1
    - Microsoft.Graph.DeviceManagement                                      2.36.1
    - Microsoft.Graph.Groups                                                2.36.1
    - Microsoft.Graph.Identity.DirectoryManagement                          2.36.1
    - Microsoft.Graph.Identity.Governance                                   2.36.1
    - Microsoft.Graph.Identity.Signins                                      2.36.1
    - Microsoft.Graph.Reports                                               2.36.1
    - Microsoft.Graph.Users                                                 2.36.1
```

**NOTE :** Be sure to remove all Az powershell modules. They conflict with the AzureCLI Tools,
and can cause these scripts to not run correctly! Remove with this command:

```powershell
    Get-Module -ListAvailable "Az.*" | ForEach {Uninstall-Module -Name $_.Name}
```


### Required Test User Permissions
For information on Setup & Configuration of a CIS testing account, please read
[Docs/test-account-config.md](Docs/test-account-config.md)