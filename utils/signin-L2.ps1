
Connect-ExchangeOnline
Connect-MgGraph -Scopes `
    "Domain.Read.All", `
    "Directory.Read.All", `
    "Policy.Read.All", `
    "Group.Read.All", `
    "User.Read.All", `
    "Application.Read.All", `
    "RoleManagement.Read.Directory", `
    "OrgSettings-AppsAndServices.Read.All", `
    "OrgSettings-Forms.Read.All"
