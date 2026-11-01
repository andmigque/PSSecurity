# Invoke-QueueWorker

*Takes objects from a shared queue and runs a script block on each one.*

## DESCRIPTION

The body of one Enter-ThreadQueue worker. Start-QueueWorker runs it inside a
thread job; it is not meant to be called directly.

The script block runs as a steppable pipeline: begin runs once, process runs
for each object taken from the queue, and end runs once when the queue is
empty. When process throws, the error is written with the object as its
TargetObject and the script block is restarted, including begin, for the
remaining objects. When begin throws, the worker stops.

The worker runs in its own runspace, so it rebuilds the script block from text
and sets strict mode itself.

## PARAMETERS

### -Queue

The shared queue. The worker stops when the queue is empty and marked complete.

### -ScriptText

The script block to run, as text. It must have a process block.

### -ArgumentList

The arguments to pass to the script block, bound by position.

### -CancellationToken

Stops the worker from taking more objects when cancelled.

## EXAMPLES

### Example 1

```powershell
Invoke-QueueWorker -Queue $queue -ScriptText 'process { $_ * 2 }' -CancellationToken $token
```

Doubles every number in $queue until it is empty.

## INPUTS

None. This function does not accept pipeline input.

## OUTPUTS

System.Object. The output of the script block.

