# Start-QueueWorker

*Starts thread jobs that each run Invoke-QueueWorker on a shared queue.*

## DESCRIPTION

Starts -Count thread jobs. Each job runs Invoke-QueueWorker against the same
queue, so the jobs share the objects between them. Jobs are returned as they
start, so a caller that collects them can still clean up if a later job fails
to start.

Thread jobs run in their own runspaces, where this module's functions are not
defined. The job script is built from the text of Invoke-QueueWorker.

## PARAMETERS

### -Queue

The shared queue of objects to process.

### -ScriptText

The script block to run on each object, as text.

### -ArgumentList

The arguments to pass to the script block, bound by position.

### -CancellationToken

Stops the workers from taking more objects when cancelled.

### -Count

The number of workers to start, from 1 through 255.

### -ThrottleLimit

The maximum number of thread jobs that run at once, from 1 through 255. Passed
to Start-ThreadJob, which applies it to all thread jobs in the session.

## EXAMPLES

### Example 1

```powershell
$jobs = Start-QueueWorker -Queue $queue -ScriptText 'process { $_ }' -CancellationToken $token -Count 4 -ThrottleLimit 8
```

Starts four workers on $queue, with up to eight thread jobs running at once.

## INPUTS

None. This function does not accept pipeline input.

## OUTPUTS

ThreadJob.ThreadJob. One job per worker.

