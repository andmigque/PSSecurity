# Get-UacConfiguration

*Gets UAC settings and their interpreted values.*

## DESCRIPTION

Reads ConsentPromptBehaviorAdmin, EnableLUA, and PromptOnSecureDesktop from
HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System and describes
each value. The configuration is hardened when UAC is enabled, administrators
are prompted for credentials, and prompts appear on the secure desktop. Use
Set-UacRequirePassword to apply that configuration. Windows only.

## EXAMPLES

### Example 1

```powershell
Get-UacConfiguration
```

Returns the current registry settings and whether they match the hardened
configuration.

### Example 2

```powershell
if (-not (Get-UacConfiguration).Hardened) { Set-UacRequirePassword }
```

Applies the hardened configuration when the current one is not hardened.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One object with each registry
value, its meaning, and whether the configuration is hardened.

