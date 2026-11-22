# Start-ThreadJobPool

*Starts the thread job scheduler and returns the started pool.*

## DESCRIPTION

Runs the scheduler asynchronously in the pool's runspace. Summary
returns counts by job state. Status returns the jobs in each state.
Both expose Active (Running), Completed, Failed, and Stopped. Reading
either property takes a fresh snapshot, including after dispatch ends.

## PARAMETERS

### -Pool

The pool returned by Initialize-Pool.

### -ThreadCount

Accepts 0 through 255. Omit ThreadCount or pass 0 to use the default
from Get-DefaultThreadCount. The scheduler uses the smallest of the
resolved request, the default, and the initial job count.

## EXAMPLES

### Example 1

```powershell
$pool = Initialize-ThreadJobBag -ThreadJob $threadJobs |
    Initialize-Pool |
    Start-ThreadJobPool -ThreadCount 8
```

Starts the pool with up to eight concurrent jobs and returns immediately.

### Example 2

```powershell
$pool.Summary
$pool.Status.Active
```

Shows the current counts and the running ThreadJob objects.

### Example 3

```powershell
$pool.ThreadJob | Wait-Job | Receive-Job
```

Waits for the supplied jobs and reads their output.

## INPUTS

PSCustomObject.

## OUTPUTS

The supplied pool with Scheduler, AsyncResult, Summary, and Status
properties.

## NOTES

$global:PSSecurityThreadPool references the started pool.
AsyncResult tracks the scheduler invocation. Its completion means the
scheduler has finished dispatching jobs. Wait-Job on the ThreadJob
array waits for the jobs themselves.

