# Test-Administrator

*Tests whether the current session is running as an administrator.*

## DESCRIPTION

Returns true when the current Windows identity is in the built-in
Administrators role, which requires an elevated session when UAC is on.
Windows only.

## EXAMPLES

### Example 1

```powershell
if (-not (Test-Administrator)) { Write-Warning -Message 'Run this from an elevated session.' }
```

Warns when the session is not elevated.

## INPUTS

None. This function does not accept pipeline input.

## OUTPUTS

System.Boolean. True when the session is elevated, otherwise false.

