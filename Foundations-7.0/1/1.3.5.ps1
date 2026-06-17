# 1.3.5 Ensure internal phishing protection for Forms is enabled (Automated)
# E3 Level 1
# E5 Level 1

Connect-MgGraph -Scopes "OrgSettings-Forms.Read.All" -NoWelcome

$uri = 'https://graph.microsoft.com/beta/admin/forms/settings'
Invoke-MgGraphRequest -Uri $uri | select isInOrgFormsPhishingScanEnabled
