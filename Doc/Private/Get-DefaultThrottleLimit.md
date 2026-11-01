# Get-DefaultThrottleLimit

*Returns the default number of parallel workers: 75% of the processors.*

## DESCRIPTION

Multiplies the processor count by 0.75 and rounds down, so the workers never
use more than 75% of the processors. The result is at least 1, so a
single-processor machine still gets a worker, and at most 255, the upper limit
of -ThrottleLimit.

## EXAMPLES

### Example 1

```powershell
Get-DefaultThrottleLimit
```

Returns 6 on an 8-processor machine, 3 on a 5-processor machine, and 1 on a
1- or 2-processor machine.

## INPUTS

None. This function does not accept pipeline input.

## OUTPUTS

System.Int32. The number of workers, from 1 through 255.

