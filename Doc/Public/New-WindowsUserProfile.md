# New-WindowsUserProfile

*Creates a local user and its Windows profile directory.*

## DESCRIPTION

Creates a local account with New-LocalUser, adds it to Users, or to
Administrators with -IsAdmin, then creates the profile with the CreateProfile
function in userenv.dll. Windows normally creates a profile at first logon;
this creates it immediately.

When Windows already has a profile registered for the account, the existing
profile is returned instead. Throws when the profile is registered but its
directory is missing.

Requires an elevated session, including for -WhatIf. Supports -WhatIf and
-Confirm. Windows only.

## PARAMETERS

### -UserName

The name of the new local account, without a domain or computer prefix.

### -FullName

The display name of the new local account.

### -Description

The description of the new local account.

### -IsAdmin

Adds the account to Administrators instead of Users.

## EXAMPLES

### Example 1

```powershell
New-WindowsUserProfile -UserName jdoe -FullName 'Jane Doe' -Description 'Analyst'
```

Prompts for a password, creates jdoe as a standard user, and creates the
profile directory.

### Example 2

```powershell
New-WindowsUserProfile -UserName svc-audit -FullName 'Audit Service' -Description 'Audit tasks' -IsAdmin
```

Creates svc-audit as a local administrator with a profile directory.

### Example 3

```powershell
New-WindowsUserProfile -UserName jdoe -FullName 'Jane Doe' -Description 'Analyst' -WhatIf
```

Previews the account and profile creation without making changes.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One object with the account name,
SID, profile path, and whether the profile was created. Nothing is returned for
-WhatIf.

