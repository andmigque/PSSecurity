# Set-UacConsentOnly

*Sets the administrator UAC consent policy to value 5.*

## DESCRIPTION

Sets ConsentPromptBehaviorAdmin under
HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System to 5, the
Windows default: administrators are prompted for consent, not credentials,
for non-Windows binaries. Other UAC settings are unchanged. Use
Set-UacRequirePassword to require credentials instead.

Requires an elevated session, including for -WhatIf. Supports -WhatIf and
-Confirm. Windows only.

## EXAMPLES

### Example 1

```powershell
Set-UacConsentOnly -WhatIf
```

Previews the registry change.

### Example 2

```powershell
Set-UacConsentOnly
```

Sets the consent-only policy and returns the before and after values.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One object with the setting name,
its value before and after, and the resulting policy. Nothing is returned for
-WhatIf.

