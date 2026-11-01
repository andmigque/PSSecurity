# Set-AclItemOwner

*Changes an item's owner and returns its updated ACL details.*

## DESCRIPTION

Sets the owner of each piped ACL item with Get-Acl and Set-Acl, then returns the
item's details again from Get-AclItem. The access rules are unchanged.

Requires an elevated session, including for -WhatIf. Supports -WhatIf and
-Confirm. Windows only.

## PARAMETERS

### -AclItem

An ACL item from Get-AclItem, with FullName, Owner, and Name properties.
Accepts objects from the pipeline.

### -Identity

The new owner, as DOMAIN\User. Defaults to the current USERDOMAIN\USERNAME.

## EXAMPLES

### Example 1

```powershell
Get-AclItem -LiteralPath C:\Data | Set-AclItemOwner -Identity 'CONTOSO\Owner' -WhatIf
```

Previews the ownership change.

### Example 2

```powershell
Get-AclItem -LiteralPath C:\Data | Set-AclItemOwner
```

Makes the current user the owner of C:\Data.

### Example 3

```powershell
$anomalies = (Get-ChildItem -LiteralPath C:\Data | ForEach-Object { Get-AclItem -LiteralPath $_.FullName } |
    Measure-OwnerAnomaly -Identity 'BUILTIN\Administrators').Anomalies
$anomalies | Set-AclItemOwner -Identity 'BUILTIN\Administrators'
```

Gives Administrators ownership of every item in C:\Data that it does not own.

## INPUTS

System.Management.Automation.PSCustomObject. You can pipe ACL items from
Get-AclItem to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. The Get-AclItem details of each
changed item. Nothing is returned for -WhatIf.

