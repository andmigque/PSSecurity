# Remove-App

*Removes AppX packages identified by JSON input.*

## DESCRIPTION

Parses JSON text into package full names and removes each package with
Remove-AppxPackage. Confirmation is requested once per run, for the computer,
not once per package. To keep a package from being installed for new users,
use Remove-ProvisionedApp.

Requires an elevated session, including for -WhatIf. Supports -WhatIf and
-Confirm, and prompts for confirmation by default. Windows only.

## PARAMETERS

### -Json

JSON text containing package full names, for example an array of strings.
Accepts JSON text from the pipeline.

## EXAMPLES

### Example 1

```powershell
Remove-App -Json '["Example.Package_1.0.0.0_x64__publisher"]' -WhatIf
```

Previews the removal.

### Example 2

```powershell
Get-Content -LiteralPath C:\Config\RemoveApps.json -Raw | Remove-App -Confirm:$false
```

Removes the packages listed in a JSON file without prompting.

## INPUTS

System.String. You can pipe JSON text to this function.

## OUTPUTS

None. This function does not return output.

