# New-LocalAdminUser

*Creates a local user and adds it to Administrators.*

## DESCRIPTION

Creates a local account with New-LocalUser from the user name and password in
the credential, then adds it to the local Administrators group. Requires an
elevated session, including for -WhatIf. Supports -WhatIf and -Confirm.
Windows only.

## PARAMETERS

### -Credential

Credential containing the new local account name and password. Accepts
credentials from the pipeline; one account is created for each.

### -FullName

Optional display name for the local account.

### -Description

Optional description for the local account.

### -PasswordNeverExpires

Prevents the new account password from expiring when specified.

## EXAMPLES

### Example 1

```powershell
New-LocalAdminUser -Credential (Get-Credential) -WhatIf
```

Previews account creation without creating the account.

### Example 2

```powershell
New-LocalAdminUser -Credential (Get-Credential) -FullName 'Break Glass' -PasswordNeverExpires
```

Creates a local administrator whose password does not expire.

### Example 3

```powershell
Get-Credential | New-LocalAdminUser -Description 'Emergency access'
```

Creates a local administrator from the piped credential.

## INPUTS

System.Management.Automation.PSCredential. You can pipe credentials to this
function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One summary per created account
with the user name, full name, and password expiry setting. Nothing is returned
for -WhatIf.

