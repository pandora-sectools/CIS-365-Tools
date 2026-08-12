# Login
# Select "yes" in response to "sign in everywhere?"
# Select "no" in response to "allow this orginisation to manage this device?"

set-executionpolicy -ExecutionPolicy Bypass -Scope CurrentUser

Az Login
Connect-ExchangeOnline
Connect-IPPSSession
Connect-MicrosoftTeams
Connect-MgGraph -Scopes `
    "Domain.Read.All", `
    "Directory.Read.All", `
    "Policy.Read.All", `
    "Group.Read.All", `
    "User.Read.All", `
    "Application.Read.All", `
    "RoleManagement.Read.Directory", `
    "OrgSettings-AppsAndServices.Read.All", `
    "OrgSettings-Forms.Read.All", `
    "UserAuthenticationMethod.Read.All", `
    "DeviceManagementConfiguration.Read.All"
