# Measure-OwnerAnomaly

*Counts items whose owner differs from the expected identity.*

## DESCRIPTION

Collects every piped ACL item and compares its Owner property with -Identity.
Items whose owner does not match are anomalies. Returns one summary after the
last item, with both counts and both collections.

## PARAMETERS

### -AclItem

An ACL item object with an Owner property, such as output from Get-AclItem.
Accepts objects from the pipeline.

### -Identity

The expected owner identity, as DOMAIN\User. Defaults to the current
USERDOMAIN\USERNAME.

## EXAMPLES

### Example 1

```powershell
Get-AclItem -LiteralPath C:\Data | Measure-OwnerAnomaly
```

Checks whether the current user owns C:\Data.

### Example 2

```powershell
Get-ChildItem -LiteralPath C:\Data -Recurse | ForEach-Object { Get-AclItem -LiteralPath $_.FullName } |
    Measure-OwnerAnomaly -Identity 'BUILTIN\Administrators'
```

Counts the items under C:\Data that are not owned by Administrators.

### Example 3

```powershell
(Get-AclItem -LiteralPath C:\Data | Measure-OwnerAnomaly).Anomalies | Select-Object -Property FullName, Owner
```

Lists the path and owner of each anomaly.

## INPUTS

System.Management.Automation.PSCustomObject. You can pipe ACL items to this
function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One summary with AclItemCount,
AnomalyCount, AclItems, and Anomalies.

