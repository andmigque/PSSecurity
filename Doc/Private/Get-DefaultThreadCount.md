# Get-DefaultThreadCount

*Returns the default thread count.*

## DESCRIPTION

Doubles the module's default throttle limit and caps the result at 255.

## EXAMPLES

### Example 1

```powershell
Get-DefaultThreadCount
```

When the default throttle limit is 6, returns an object with ThreadCount set to 12.

## INPUTS

None.

## OUTPUTS

PSCustomObject with a ThreadCount property.

