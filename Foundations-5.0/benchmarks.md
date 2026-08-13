
```

1 Microsoft 365 admin center

    1.1 Users
        1.1.1  (L1) Ensure Administrative accounts are cloud-only (Automated)
        1.1.2  (L1) Ensure two emergency access accounts have been defined (Manual)                                                                (TODO)
        1.1.3  (L1) Ensure that between two and four global admins are designated (Automated)
        1.1.4  (L1) Ensure administrative accounts use licenses with a reduced application footprint (Automated)

    1.2 Teams & groups
        1.2.1  (L2) Ensure that only organizationally managed/approved public groups exist (Automated)
        1.2.2  (L1) Ensure sign-in to shared mailboxes is blocked (Automated)

    1.3 Settings
        1.3.1  (L1) Ensure the 'Password expiration policy' is set to 'Set passwords to never expire (recommended)' (Automated)
        1.3.2  (L2) Ensure 'Idle session timeout' is set to '3 hours (or less)' for unmanaged devices (Automated)
        1.3.3  (L2) Ensure 'External sharing' of calendars is not available (Automated)
        1.3.4  (L1) Ensure 'User owned apps and services' is restricted (Automated)
        1.3.5  (L1) Ensure internal phishing protection for Forms is enabled (Automated)
        1.3.6  (L2) Ensure the customer lockbox feature is enabled (Automated)
        1.3.7  (L2) Ensure 'third-party storage services' are restricted in 'Microsoft 365 on the web' (Automated)
        1.3.8  (L2) Ensure that Sways cannot be shared with people outside of your organization (Manual)                                           (TODO)

2 Microsoft 365 Defender

    2.1 Email & collaboration
        2.1.1  (L2) Ensure Safe Links for Office Applications is Enabled (Automated)
        2.1.2  (L1) Ensure the Common Attachment Types Filter is enabled (Automated)
        2.1.3  (L1) Ensure notifications for internal users sending malware is Enabled (Automated)
        2.1.4  (L2) Ensure Safe Attachments policy is enabled (Automated)
        2.1.5  (L2) Ensure Safe Attachments for SharePoint, OneDrive, and Microsoft Teams is Enabled (Automated)
        2.1.6  (L1) Ensure Exchange Online Spam Policies are set to notify administrators (Automated)
        2.1.7  (L2) Ensure that an anti-phishing policy has been created (Automated)
        2.1.8  (L1) Ensure that SPF records are published for all Exchange Domains (Automated)
        2.1.9  (L1) Ensure that DKIM is enabled for all Exchange Online Domains (Automated)
        2.1.10 (L1) Ensure DMARC Records for all Exchange Online domains are published (Automated)
        2.1.11 (L2) Ensure comprehensive attachment filtering is applied (Automated)
        2.1.12 (L1) Ensure the connection filter IP allow list is not used (Automated)
        2.1.13 (L1) Ensure the connection filter safe list is off (Automated)
        2.1.14 (L1) Ensure inbound anti-spam policies do not contain allowed domains (Automated)

    2.2 Cloud apps
        2.2.1  (L1) Ensure emergency access account activity is monitored (Manual)                                                                 (TODO)

    2.3 Audit

    2.4 System
        2.4.1  (L1) Ensure Priority account protection is enabled and configured (Automated)
        2.4.2  (L1) Ensure Priority accounts have 'Strict protection' presets applied (Automated)
        2.4.3  (L2) Ensure Microsoft Defender for Cloud Apps is enabled and configured (Manual)                                                    (TODO)
        2.4.4  (L1) Ensure Zero-hour auto purge for Microsoft Teams is on (Automated)




3 Microsoft Purview
    3.1 Audit
        3.1.1  (L1) Ensure Microsoft 365 audit log search is Enabled (Automated)
    3.2 Data loss protection
        3.2.1  (L1) Ensure DLP policies are enabled (Manual)
        3.2.2  (L1) Ensure DLP policies are enabled for Microsoft Teams (Automated)                                                                (TODO)
    3.3 Information Protection
        3.3.1  (L1) Ensure Information Protection sensitivity label policies are published (Manual)




4 Microsoft Intune admin center
    4.1  (L2) Ensure devices without a compliance policy are marked 'not compliant' (Automated)
    4.2  (L2) Ensure device enrollment for personally owned devices is blocked by default (Manual)




5 Microsoft Entra admin center

    5.1 Identity

        5.1.2 Users
            5.1.2.1  (L1) Ensure 'Per-user MFA' is disabled (Automated)                                                                            (TODO)
            5.1.2.2  (L2) Ensure third party integrated applications are not allowed (Automated)
            5.1.2.3  (L1) Ensure 'Restrict non-admin users from creating tenants' is set to 'Yes' (Automated)
            5.1.2.4  (L1) Ensure access to the Entra admin center is restricted (Manual)                                                           (TODO)
            5.1.2.5  (L2) Ensure the option to remain signed in is hidden (Manual)                                                                 (TODO)
            5.1.2.6  (L2) Ensure 'LinkedIn account connections' is disabled (Manual)                                                               (TODO)

        5.1.3 Groups
            5.1.3.1  (L1) Ensure a dynamic group for guest users is created (Automated)

        5.1.5 Applications
            5.1.5.1  (L2) Ensure user consent to apps accessing company data on their behalf is not allowed (Automated)                            (TODO)
            5.1.5.2  (L1) Ensure the admin consent workflow is enabled (Automated)                                                                 (TODO)

        5.1.6 External Identities
            5.1.6.1  (L2) Ensure that collaboration invitations are sent to allowed domains only (Manual)                                          (TODO)
            5.1.6.2  (L1) Ensure that guest user access is restricted (Automated)                                                                  (TODO)
            5.1.6.3  (L2) Ensure guest user invitations are limited to the Guest Inviter role (Automated) .                                        (TODO)

        5.1.8 Hybrid management
            5.1.8.1  (L1) Ensure that password hash sync is enabled for hybrid deployments (Manual)                                                (TODO)

    5.2 Protection

        5.2.2 Conditional Access
            5.2.2.1  (L1) Ensure multifactor authentication is enabled for all users in administrative roles (Automated)                          (TODO)
            5.2.2.2  (L1) Ensure multifactor authentication is enabled for all users (Automated)                                                  (TODO)
            5.2.2.3  (L1) Enable Conditional Access policies to block legacy authentication (Automated)                                           (TODO)
            5.2.2.4  (L1) Ensure Sign-in frequency is enabled and browser sessions are not persistent for Administrative users (Automated)        (TODO)
            5.2.2.5  (L2) Ensure 'Phishing-resistant MFA strength' is required for Administrators (Automated)                                     (TODO)
            5.2.2.6  (L1) Enable Identity Protection user risk policies (Automated)                                                               (TODO)
            5.2.2.7  (L1) Enable Identity Protection sign-in risk policies (Automated)                                                            (TODO)
            5.2.2.8  (L2) Ensure 'sign-in risk' is blocked for medium and high risk (Automated)                                                   (TODO)
            5.2.2.9  (L1) Ensure a managed device is required for authentication (Automated)                                                      (TODO)
            5.2.2.10 (L1) Ensure a managed device is required to register security information (Automated)                                        (TODO)
            5.2.2.11 (L1) Ensure sign-in frequency for Intune Enrollment is set to 'Every time' (Automated)                                       (TODO)
            5.2.2.12 (L1) Ensure the device code sign-in flow is blocked (Automated)                                                              (TODO)

        5.2.3 Authentication Methods
            5.2.3.1  (L1) Ensure Microsoft Authenticator is configured to protect against MFA fatigue (Automated)                                 (TODO)
            5.2.3.2  (L1) Ensure custom banned passwords lists are used (Automated)                                                               (TODO)
            5.2.3.3  (L1) Ensure password protection is enabled for on-prem Active Directory (Automated)                                          (TODO)
            5.2.3.4  (L1) Ensure all member users are 'MFA capable' (Automated)                                                                   (TODO)
            5.2.3.5  (L1) Ensure weak authentication methods are disabled (Automated)                                                             (TODO)
            5.2.3.6  (L1) Ensure system-preferred multifactor authentication is enabled (Manual)                                                  (TODO)

        5.2.4 Password reset
            5.2.4.1  (L1) Ensure 'Self service password reset enabled' is set to 'All' (Manual)                                                   (TODO)

    5.3 Identity Governance
        5.3.1  (L2) Ensure 'Privileged Identity Management' is used to manage roles (Automated)                                                   (TODO)
        5.3.2  (L1) Ensure 'Access reviews' for Guest Users are configured (Automated)                                                            (TODO)
        5.3.3  (L1) Ensure 'Access reviews' for privileged roles are configured (Automated)                                                       (TODO)
        5.3.4  (L1) Ensure approval is required for Global Administrator role activation (Manual)                                                 (TODO)
        5.3.5  (L1) Ensure approval is required for Privileged Role Administrator activation (Manual)                                             (TODO)




6 Exchange admin cente

    6.1 Audit
        6.1.1  (L1) Ensure 'AuditDisabled' organizationally is set to 'False' (Automated)                                                         (TODO)
        6.1.2  (L1) Ensure mailbox audit actions are configured (Automated)                                                                       (TODO)
        6.1.3  (L1) Ensure 'AuditBypassEnabled' is not enabled on mailboxes (Automated)                                                           (TODO)

    6.2 Mail flow
        6.2.1  (L1) Ensure all forms of mail forwarding are blocked and/or disabled (Automated)                                                   (TODO)
        6.2.2  (L1) Ensure mail transport rules do not whitelist specific domains (Automated)                                                     (TODO)
        6.2.3  (L1) Ensure email from external senders is identified (Automated)

    6.3 Roles
        6.3.1  (L2) Ensure users installing Outlook add-ins is not allowed (Automated)                                                            (TODO)

    6.5 Settings
        6.5.1  (L1) Ensure modern authentication for Exchange Online is enabled (Automated)                                                       (TODO)
        6.5.2  (L1) Ensure MailTips are enabled for end users (Automated)                                                                         (TODO)
        6.5.3  (L2) Ensure additional storage providers are restricted in Outlook on the web (Automated)                                          (TODO)
        6.5.4  (L1) Ensure SMTP AUTH is disabled (Automated)                                                                                      (TODO)




7 SharePoint admin center

    7.2 Policies
        7.2.1  (L1) Ensure modern authentication for SharePoint applications is required (Automated)
        7.2.2  (L1) Ensure SharePoint and OneDrive integration with Azure AD B2B is enabled (Automated)
        7.2.3  (L1) Ensure external content sharing is restricted (Automated)
        7.2.4  (L2) Ensure OneDrive content sharing is restricted (Automated)                                                                     (TODO)
        7.2.5  (L2) Ensure that SharePoint guest users cannot share items they don't own (Automated)                                              (TODO)
        7.2.6  (L2) Ensure SharePoint external sharing is managed through domain whitelist/blacklists (Automated)                                 (TODO)
        7.2.7  (L1) Ensure link sharing is restricted in SharePoint and OneDrive (Automated)                                                      (TODO)
        7.2.8  (L2) Ensure external sharing is restricted by security group (Manual)                                                              (TODO)
        7.2.9  (L1) Ensure guest access to a site or OneDrive will expire automatically (Automated)                                               (TODO)
        7.2.10 (L1) Ensure reauthentication with verification code is restricted (Automated)                                                      (TODO)
        7.2.11 (L1) Ensure the SharePoint default sharing link permission is set (Automated)                                                      (TODO)

    7.3 Settings
        7.3.1  (L2) Ensure Office 365 SharePoint infected files are disallowed for download (Automated)                                           (TODO)
        7.3.2  (L2) Ensure OneDrive sync is restricted for unmanaged devices (Automated)                                                          (TODO)
        7.3.3  (L1) Ensure custom script execution is restricted on personal sites (Manual)                                                       (TODO)
        7.3.4  (L1) Ensure custom script execution is restricted on site collections (Automated)                                                  (TODO)




8 Microsoft Teams admin center
    8.1 Teams                                                                                                                                     (TODO)
        8.1.1  (L2) Ensure external file sharing in Teams is enabled for only approved cloud storage services (Automated)
        8.1.2  (L1) Ensure users can't send emails to a channel email address (Automated)

    8.2 Users
        8.2.1  (L2) Ensure external domains are restricted in the Teams admin center (Automated)                                                  (TODO)
        8.2.2  (L1) Ensure communication with unmanaged Teams users is disabled (Automated)                                                       (TODO)
        8.2.3  (L1) Ensure external Teams users cannot initiate conversations (Automated)                                                         (TODO)
        8.2.4  (L1) Ensure communication with Skype users is disabled (Automated)                                                                 (TODO)

    8.3 Teams device

    8.4 Teams apps
        8.4.1  (L1) Ensure app permission policies are configured (Manual)                                                                        (TODO)

    8.5 Meetings
        8.5.1  (L2) Ensure anonymous users can't join a meeting (Automated                                                                        (TODO)
        8.5.2  (L1) Ensure anonymous users and dial-in callers can't start a meeting (Automated)                                                  (TODO)
        8.5.3  (L1) Ensure only people in my org can bypass the lobby (Automated)                                                                 (TODO)
        8.5.4  (L1) Ensure users dialing in can't bypass the lobby (Automated)                                                                    (TODO)
        8.5.5  (L2) Ensure meeting chat does not allow anonymous users (Automated)                                                                (TODO)
        8.5.6  (L2) Ensure only organizers and co-organizers can present (Automated)                                                              (TODO)
        8.5.7  (L1) Ensure external participants can't give or request control (Automated)                                                        (TODO)
        8.5.8  (L2) Ensure external meeting chat is off (Automated)                                                                               (TODO)
        8.5.9  (L2) Ensure meeting recording is off by default (Automated)                                                                        (TODO)

    8.6 Messaging
        8.6.1  (L1) Ensure users can report security concerns in Teams (Automated)




9 Microsoft Fabric
    9.1 Tenant settings
        9.1.1  (L1) Ensure guest user access is restricted (Manual)
        9.1.2  (L1) Ensure external user invitations are restricted (Manual)                                                                      (TODO)
        9.1.3  (L1) Ensure guest access to content is restricted (Manual)                                                                         (TODO)
        9.1.4  (L1) Ensure 'Publish to web' is restricted (Manual)                                                                                (TODO)
        9.1.5  (L2) Ensure 'Interact with and share R and Python' visuals is 'Disabled' (Manual)                                                  (TODO)
        9.1.6  (L1) Ensure 'Allow users to apply sensitivity labels for content' is 'Enabled' (Manual)                                            (TODO)
        9.1.7  (L1) Ensure shareable links are restricted (Manual                                                                                 (TODO)
        9.1.8  (L1) Ensure enabling of external data sharing is restricted (Manual)                                                               (TODO)
        9.1.9  (L1) Ensure 'Block ResourceKey Authentication' is 'Enabled' (Manual)                                                               (TODO)
        9.1.10 (L1) Ensure access to APIs by Service Principals is restricted (Manual)                                                            (TODO)
        9.1.11 (L1) Ensure Service Principals cannot create and use profiles (Manual)                                                             (TODO)

```
