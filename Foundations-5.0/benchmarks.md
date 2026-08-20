
```

1 Microsoft 365 admin center

    1.1 Users
            1.1.1      (L1)     Automated     Ensure Administrative accounts are cloud-only
            1.1.2      (L1)     Manual        Ensure two emergency access accounts have been defined
            1.1.3      (L1)     Automated     Ensure that between two and four global admins are designated
            1.1.4      (L1)     Automated     Ensure administrative accounts use licenses with a reduced application footprint

    1.2 Teams & groups
            1.2.1      (L2)     Automated     Ensure that only organizationally managed/approved public groups exist
            1.2.2      (L1)     Automated     Ensure sign-in to shared mailboxes is blocked

    1.3 Settings
            1.3.1      (L1)     Automated     Ensure the 'Password expiration policy' is set to 'Set passwords to never expire (recommended)'
            1.3.2      (L2)     Automated     Ensure 'Idle session timeout' is set to '3 hours (or less)' for unmanaged devices
            1.3.3      (L2)     Automated     Ensure 'External sharing' of calendars is not available
            1.3.4      (L1)     Automated     Ensure 'User owned apps and services' is restricted
            1.3.5      (L1)     Automated     Ensure internal phishing protection for Forms is enabled
            1.3.6      (L2)     Automated     Ensure the customer lockbox feature is enabled
            1.3.7      (L2)     Automated     Ensure 'third-party storage services' are restricted in 'Microsoft 365 on the web'
            1.3.8      (L2)     Manual        Ensure that Sways cannot be shared with people outside of your organization


2 Microsoft 365 Defender

    2.1 Email & collaboration
            2.1.1      (L2)     Automated     Ensure Safe Links for Office Applications is Enabled
            2.1.2      (L1)     Automated     Ensure the Common Attachment Types Filter is enabled
            2.1.3      (L1)     Automated     Ensure notifications for internal users sending malware is Enabled
            2.1.4      (L2)     Automated     Ensure Safe Attachments policy is enabled
            2.1.5      (L2)     Automated     Ensure Safe Attachments for SharePoint, OneDrive, and Microsoft Teams is Enabled
            2.1.6      (L1)     Automated     Ensure Exchange Online Spam Policies are set to notify administrators
            2.1.7      (L2)     Automated     Ensure that an anti-phishing policy has been created
            2.1.8      (L1)     Automated     Ensure that SPF records are published for all Exchange Domains
            2.1.9      (L1)     Automated     Ensure that DKIM is enabled for all Exchange Online Domains
            2.1.10     (L1)     Automated     Ensure DMARC Records for all Exchange Online domains are published
            2.1.11     (L2)     Automated     Ensure comprehensive attachment filtering is applied
            2.1.12     (L1)     Automated     Ensure the connection filter IP allow list is not used
            2.1.13     (L1)     Automated     Ensure the connection filter safe list is off
            2.1.14     (L1)     Automated     Ensure inbound anti-spam policies do not contain allowed domains

    2.2 Cloud apps
            2.2.1      (L1)     Manual        Ensure emergency access account activity is monitored

    2.3 Audit
                    Intentionally Left Blank
 
    2.4 System
            2.4.1      (L1)     Automated     Ensure Priority account protection is enabled and configured
            2.4.2      (L1)     Automated     Ensure Priority accounts have 'Strict protection' presets applied
            2.4.3      (L2)     Manual        Ensure Microsoft Defender for Cloud Apps is enabled and configured
            2.4.4      (L1)     Automated     Ensure Zero-hour auto purge for Microsoft Teams is on


3 Microsoft Purview
    3.1 Audit
            3.1.1      (L1)     Automated     Ensure Microsoft 365 audit log search is Enabled
    3.2 Data loss protection
            3.2.1      (L1)     Automated     Ensure DLP policies are enabled
            3.2.2      (L1)     Automated     Ensure DLP policies are enabled for Microsoft Teams
    3.3 Information Protection
            3.3.1      (L1)     Automated*    Ensure Information Protection sensitivity label policies are published


4 Microsoft Intune admin center
            4.1        (L2)     Automated     Ensure devices without a compliance policy are marked 'not compliant'                                                      
            4.2        (L2)     Manual        Ensure device enrollment for personally owned devices is blocked by default                                                   


5 Microsoft Entra admin center

    5.1 Identity

        5.1.2 Users
            5.1.2.1    (L1)     Automated*    Ensure 'Per-user MFA' is disabled                                                                             (TODO) 
            5.1.2.2    (L2)     Automated     Ensure third party integrated applications are not allowed                                                     
            5.1.2.3    (L1)     Automated     Ensure 'Restrict non-admin users from creating tenants' is set to 'Yes'                                        
            5.1.2.4    (L1)     Manual        Ensure access to the Entra admin center is restricted                                                         (TODO) 
            5.1.2.5    (L2)     Manual        Ensure the option to remain signed in is hidden                                                               (TODO) 
            5.1.2.6    (L2)     Manual        Ensure 'LinkedIn account connections' is disabled                                                             (TODO) 

        5.1.3 Groups
            5.1.3.1    (L1)     Automated     Ensure a dynamic group for guest users is created                                                              

        5.1.5 Applications
            5.1.5.1    (L2)     Automated     Ensure user consent to apps accessing company data on their behalf is not allowed                             (TODO) 
            5.1.5.2    (L1)     Automated     Ensure the admin consent workflow is enabled

        5.1.6 External Identities
            5.1.6.1    (L2)     Manual        Ensure that collaboration invitations are sent to allowed domains only                                        (TODO) 
            5.1.6.2    (L1)     Automated     Ensure that guest user access is restricted                                                                   (TODO) 
            5.1.6.3    (L2)     Automated     Ensure guest user invitations are limited to the Guest Inviter role                                           (TODO) 
   
        5.1.8 Hybrid management
            5.1.8.1    (L1)     Automated*    Ensure that password hash sync is enabled for hybrid deployments                                              (TODO) 


    5.2 Protection

        5.2.2 Conditional Access
            5.2.2.1    (L1)     Automated     Ensure multifactor authentication is enabled for all users in administrative roles
            5.2.2.2    (L1)     Automated     Ensure multifactor authentication is enabled for all users
            5.2.2.3    (L1)     Automated     Enable Conditional Access policies to block legacy authentication
            5.2.2.4    (L1)     Automated     Ensure Sign-in frequency is enabled and browser sessions are not persistent for Administrative users
            5.2.2.5    (L2)     Automated     Ensure 'Phishing-resistant MFA strength' is required for Administrators
            5.2.2.6    (L1)     Automated     Enable Identity Protection user risk policies
            5.2.2.7    (L1)     Automated     Enable Identity Protection sign-in risk policies
            5.2.2.8    (L2)     Automated     Ensure 'sign-in risk' is blocked for medium and high risk                                                     (TODO) 
            5.2.2.9    (L1)     Automated     Ensure a managed device is required for authentication
            5.2.2.10   (L1)     Automated     Ensure a managed device is required to register security information
            5.2.2.11   (L1)     Automated     Ensure sign-in frequency for Intune Enrollment is set to 'Every time'
            5.2.2.12   (L1)     Automated     Ensure the device code sign-in flow is blocked 

        5.2.3 Authentication Methods
            5.2.3.1    (L1)     Automated     Ensure Microsoft Authenticator is configured to protect against MFA fatigue                                   (TODO) 
            5.2.3.2    (L1)     Automated     Ensure custom banned passwords lists are used                                                                 (TODO) 
            5.2.3.3    (L1)     Automated     Ensure password protection is enabled for on-prem Active Directory                                            (TODO) 
            5.2.3.4    (L1)     Automated     Ensure all member users are 'MFA capable'                                                                     (TODO) 
            5.2.3.5    (L1)     Automated     Ensure weak authentication methods are disabled                                                               (TODO) 
            5.2.3.6    (L1)     Automated*    Ensure system-preferred multifactor authentication is enabled                                                 (TODO) 

        5.2.4 Password reset
            5.2.4.1    (L1)     Manual        Ensure 'Self service password reset enabled' is set to 'All'                                                  (TODO) 

    5.3 Identity Governance
            5.3.1      (L2)     Automated     Ensure 'Privileged Identity Management' is used to manage roles 
            5.3.2      (L1)     Automated     Ensure 'Access reviews' for Guest Users are configured
            5.3.3      (L1)     Automated     Ensure 'Access reviews' for privileged roles are configured
            5.3.4      (L1)     Manual        Ensure approval is required for Global Administrator role activation
            5.3.5      (L1)     Manual        Ensure approval is required for Privileged Role Administrator activation


6 Exchange admin center

    6.1 Audit
            6.1.1      (L1)     Automated     Ensure 'AuditDisabled' organizationally is set to 'False'                                                     (TODO) 
            6.1.2      (L1)     Automated     Ensure mailbox audit actions are configured                                                                   (TODO) 
            6.1.3      (L1)     Automated     Ensure 'AuditBypassEnabled' is not enabled on mailboxes                                                       (TODO) 

    6.2 Mail flow
            6.2.1      (L1)     Automated     Ensure all forms of mail forwarding are blocked and/or disabled                                               (TODO) 
            6.2.2      (L1)     Automated     Ensure mail transport rules do not whitelist specific domains                                                 (TODO) 
            6.2.3      (L1)     Automated     Ensure email from external senders is identified                                                                  

    6.3 Roles
            6.3.1      (L2)     Automated     Ensure users installing Outlook add-ins is not allowed                                                        (TODO) 

    6.5 Settings
            6.5.1      (L1)     Automated     Ensure modern authentication for Exchange Online is enabled                                                   (TODO) 
            6.5.2      (L1)     Automated     Ensure MailTips are enabled for end users                                                                     (TODO) 
            6.5.3      (L2)     Automated     Ensure additional storage providers are restricted in Outlook on the web                                      (TODO) 
            6.5.4      (L1)     Automated     Ensure SMTP AUTH is disabled                                                                                  (TODO) 


7 SharePoint admin center

    7.2 Policies
            7.2.1      (L1)     Automated     Ensure modern authentication for SharePoint applications is required  
            7.2.2      (L1)     Automated     Ensure SharePoint and OneDrive integration with Azure AD B2B is enabled  
            7.2.3      (L1)     Automated     Ensure external content sharing is restricted                                                                       
            7.2.4      (L2)     Automated     Ensure OneDrive content sharing is restricted                                                                 (TODO) 
            7.2.5      (L2)     Automated     Ensure that SharePoint guest users cannot share items they don't own                                          (TODO) 
            7.2.6      (L2)     Automated     Ensure SharePoint external sharing is managed through domain whitelist/blacklists                             (TODO) 
            7.2.7      (L1)     Automated     Ensure link sharing is restricted in SharePoint and OneDrive
            7.2.8      (L2)     Manual        Ensure external sharing is restricted by security group                                                       (TODO) 
            7.2.9      (L1)     Automated     Ensure guest access to a site or OneDrive will expire automatically
            7.2.10     (L1)     Automated     Ensure reauthentication with verification code is restricted                                                  (TODO) 
            7.2.11     (L1)     Automated     Ensure the SharePoint default sharing link permission is set                                                  (TODO) 

    7.3 Settings
            7.3.1      (L2)     Automated     Ensure Office 365 SharePoint infected files are disallowed for download                                       (TODO) 
            7.3.2      (L2)     Automated     Ensure OneDrive sync is restricted for unmanaged devices                                                      (TODO) 
            7.3.3      (L1)     Manual        Ensure custom script execution is restricted on personal sites                                                (TODO) 
            7.3.4      (L1)     Automated     Ensure custom script execution is restricted on site collections                                              (TODO) 


8 Microsoft Teams admin center
    8.1 Teams
            8.1.1      (L2)     Automated     Ensure external file sharing in Teams is enabled for only approved cloud storage services                           
            8.1.2      (L1)     Automated     Ensure users can't send emails to a channel email address                                                           

    8.2 Users
            8.2.1      (L2)     Automated     Ensure external domains are restricted in the Teams admin center                                              (TODO) 
            8.2.2      (L1)     Automated     Ensure communication with unmanaged Teams users is disabled                                                   (TODO) 
            8.2.3      (L1)     Automated     Ensure external Teams users cannot initiate conversations                                                     (TODO) 
            8.2.4      (L1)     Automated     Ensure communication with Skype users is disabled                                                             (TODO) 

    8.3 Teams devices
                    Intentionally Left Blank

    8.4 Teams apps
            8.4.1      (L1)     Manual        Ensure app permission policies are configured                                                                 (TODO) 

    8.5 Meetings
            8.5.1      (L2)     Automated     Ensure anonymous users can't join a meeting                                                                   (TODO)
            8.5.2      (L1)     Automated     Ensure anonymous users and dial-in callers can't start a meeting                                              (TODO)
            8.5.3      (L1)     Automated     Ensure only people in my org can bypass the lobby                                                             (TODO)
            8.5.4      (L1)     Automated     Ensure users dialing in can't bypass the lobby                                                                (TODO)
            8.5.5      (L2)     Automated     Ensure meeting chat does not allow anonymous users                                                            (TODO)
            8.5.6      (L2)     Automated     Ensure only organizers and co-organizers can present                                                          (TODO)
            8.5.7      (L1)     Automated     Ensure external participants can't give or request control                                                    (TODO)
            8.5.8      (L2)     Automated     Ensure external meeting chat is off                                                                           (TODO)
            8.5.9      (L2)     Automated     Ensure meeting recording is off by default                                                                    (TODO)

    8.6 Messaging
            8.6.1      (L1)     Automated     Ensure users can report security concerns in Teams


9 Microsoft Fabric
    9.1 Tenant settings
            9.1.1      (L1)     Automated     Ensure guest user access is restricted
            9.1.2      (L1)     Manual        Ensure external user invitations are restricted                                                               (TODO) 
            9.1.3      (L1)     Manual        Ensure guest access to content is restricted                                                                  (TODO) 
            9.1.4      (L1)     Manual        Ensure 'Publish to web' is restricted                                                                         (TODO) 
            9.1.5      (L2)     Manual        Ensure 'Interact with and share R and Python' visuals is 'Disabled'                                           (TODO) 
            9.1.6      (L1)     Manual        Ensure 'Allow users to apply sensitivity labels for content' is 'Enabled'                                     (TODO) 
            9.1.7      (L1)     Manual        Ensure shareable links are restricted                                                                         (TODO) 
            9.1.8      (L1)     Manual        Ensure enabling of external data sharing is restricted                                                        (TODO) 
            9.1.9      (L1)     Manual        Ensure 'Block ResourceKey Authentication' is 'Enabled'                                                        (TODO) 
            9.1.10     (L1)     Manual        Ensure access to APIs by Service Principals is restricted                                                     (TODO) 
            9.1.11     (L1)     Manual        Ensure Service Principals cannot create and use profiles                                                      (TODO) 

```
