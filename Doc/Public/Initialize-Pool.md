# Initialize-Pool

*Opens a scheduler runspace for a thread job bag.*

## DESCRIPTION

Adds the open runspace to the supplied object and returns that same object.

## PARAMETERS

### -InputObject

The pool state returned by Initialize-ThreadJobBag. Accepts pipeline input.

## EXAMPLES

### Example 1

```powershell
$pool = Initialize-ThreadJobBag -ThreadJob $threadJobs | Initialize-Pool
$pool.Runspace.RunspaceStateInfo.State
```

Returns Opened.

## INPUTS

PSCustomObject from Initialize-ThreadJobBag.

## OUTPUTS

PSCustomObject with ConcurrentBag, ThreadJob, and Runspace properties.

