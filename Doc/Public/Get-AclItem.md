# Get-AclItem

*Gets ownership, access rules, and metadata for an item.*

## DESCRIPTION

Reads the security descriptor of an item with Get-Acl and combines it with the
item's file system metadata into one object. Hidden and system items are
included. Audit rules (SACL) are not returned. Windows only.

## PARAMETERS

### -LiteralPath

The path of an existing item. The path is used exactly as typed, so wildcard
characters such as [ and ] are not expanded. Accepts paths from the pipeline.

## EXAMPLES

### Example 1

```powershell
Get-AclItem -LiteralPath C:\Data
```

Returns the item metadata and ACL details for C:\Data.

### Example 2

```powershell
'C:\Data', 'C:\Logs[2026]' | Get-AclItem
```

Returns the ACL details for each piped path. The brackets are read literally.

### Example 3

```powershell
(Get-AclItem -LiteralPath C:\Data).Access | Where-Object -Property IsInherited -EQ $false
```

Lists only the explicit, non-inherited access rules on C:\Data.

## INPUTS

System.String. You can pipe item paths to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One object per item with the
owner, group, access rules, SDDL, timestamps, and attributes.

