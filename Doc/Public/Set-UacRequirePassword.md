# Set-UacRequirePassword

*Sets the administrator UAC credential policy to value 1.*

## DESCRIPTION

Sets ConsentPromptBehaviorAdmin under
HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System to 1:
administrators must enter credentials on the secure desktop to elevate. This
is the hardened value that Get-UacConfiguration checks for. Other UAC settings
are unchanged.

Requires an elevated session, including for -WhatIf. Supports -WhatIf and
-Confirm. Windows only.

## EXAMPLES

### Example 1

```powershell
Set-UacRequirePassword -WhatIf
```

Previews the registry change.

### Example 2

```powershell
if (-not (Get-UacConfiguration).Hardened) { Set-UacRequirePassword }
```

Requires credentials for elevation when the current configuration is not
hardened.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One object with the setting name,
its value before and after, and the resulting policy. Nothing is returned for
-WhatIf.

