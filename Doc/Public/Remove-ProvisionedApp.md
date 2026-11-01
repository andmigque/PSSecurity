# Remove-ProvisionedApp

*Removes provisioned AppX packages from the online Windows image.*

## DESCRIPTION

Parses JSON text into provisioned package names and removes each one from the
running Windows image with Remove-AppxProvisionedPackage, for all users. New
user profiles no longer receive the package. Packages already installed for
existing users are not removed; use Remove-App for those. Confirmation is
requested once per run, for the computer, not once per package.

Requires an elevated session, including for -WhatIf. Supports -WhatIf and
-Confirm, and prompts for confirmation by default. Windows only.

## PARAMETERS

### -Json

JSON text containing provisioned package names, for example an array of
strings. Accepts JSON text from the pipeline.

## EXAMPLES

### Example 1

```powershell
Remove-ProvisionedApp -Json '["Example.Package_1.0.0.0_neutral_~_publisher"]' -WhatIf
```

Previews the removal.

### Example 2

```powershell
Get-Content -LiteralPath C:\Config\RemoveProvisionedApps.json -Raw | Remove-ProvisionedApp -Confirm:$false
```

Removes the provisioned packages listed in a JSON file without prompting.

## INPUTS

System.String. You can pipe JSON text to this function.

## OUTPUTS

Microsoft.Dism.Commands.ImageObject. One object per removed package, from
Remove-AppxProvisionedPackage.

