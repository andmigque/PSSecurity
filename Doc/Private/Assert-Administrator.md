# Assert-Administrator

*Stops the caller when the current session is not running as an administrator.*

## DESCRIPTION

Throws a terminating error when Test-Administrator returns false, so a
function that needs elevation can check it in one line before changing
anything. Returns nothing when the session is elevated. Windows only.

## EXAMPLES

### Example 1

```powershell
begin { Assert-Administrator }
```

Stops a function before it processes any input when the session is not
elevated.

## INPUTS

None. This function does not accept pipeline input.

## OUTPUTS

None. This function returns no output.

