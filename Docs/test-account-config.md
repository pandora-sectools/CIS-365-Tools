# Test Account setup

**NOTE:** 

To setup a test account, the following permissions are required.

### Required Test User Permissions

Required Roles:
- Global Reader
- Reports Reader
- Security Reader
- Teams Reader
- SharePoint Administrator
- Exchange Administrator
- Fabric Administrator
- InTune Administrator / Intune Read Only Operator
- View-Only Organization Management
- Graph Data Connect Administrator
- Privileged Role Administrator \[1\]

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


\[1\] An annoying issue with mordern CIS testing is the incessant blocking of powershell tools by Entra. There are a couple ways to get around this issue:
- Make the test account a Global Admin. Quite risky.
- Request Admin Consent for every single Entra block. Wastes a ton of time, annoys the admin.
- Make the test account a Privleged Role Administrator. The test account can then self approve

The most convenient choice is to give access to the Admin Conesent Flow. Once permissions are configured, make sure that Test User has access to Application Consent Workflow:

- Go to [https://entra.microsoft.com](https://entra.microsoft.com)
- Select `Enterprise Apps` in the navigation bar 
- `Consent and Permissions` in the sidebar
- Select `Admin Consent Settings`
- Select `Users (Preview)`.
- Search for the test account.
- Add the test account as an Admin Consent reviewer.
