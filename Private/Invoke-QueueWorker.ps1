#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Invoke-QueueWorker {
    <#
    .SYNOPSIS
        Takes objects from a shared queue and runs a script block on each one.

    .DESCRIPTION
        The body of one Invoke-ParallelJob worker. Start-QueueWorker runs it inside a
        thread job; it is not meant to be called directly.

        The script block runs as a steppable pipeline: begin runs once, process runs
        for each object taken from the queue, and end runs once when the queue is
        empty. When process throws, the error is written with the object as its
        TargetObject and the script block is restarted, including begin, for the
        remaining objects. When begin throws, the worker stops.

        The worker runs in its own runspace, so it rebuilds the script block from text
        and sets strict mode itself.

    .PARAMETER Queue
        The shared queue. The worker stops when the queue is empty and marked complete.

    .PARAMETER ScriptText
        The script block to run, as text. It must have a process block.

    .PARAMETER ArgumentList
        The arguments to pass to the script block, bound by position.

    .PARAMETER CancellationToken
        Stops the worker from taking more objects when cancelled.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        System.Object. The output of the script block.

    .EXAMPLE
        Invoke-QueueWorker -Queue $queue -ScriptText 'process { $_ * 2 }' -CancellationToken $token

        Doubles every number in $queue until it is empty.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory, HelpMessage = 'Enter the shared queue of objects to process.')]
        [System.Collections.Concurrent.BlockingCollection[object]]$Queue,

        [Parameter(Mandatory, HelpMessage = 'Enter the script block to run, as text.')]
        [string]$ScriptText,

        [Parameter(HelpMessage = 'Enter the arguments to pass to the script block.')]
        [object[]]$ArgumentList = @(),

        [Parameter(Mandatory, HelpMessage = 'Enter the token that stops the worker.')]
        [System.Threading.CancellationToken]$CancellationToken
    )

    Set-StrictMode -Version Latest

    # The wrapper receives the script and its arguments as parameters, so it does
    # not depend on variables from this scope.
    $wrapper = { param($Script, $Arguments) & $Script @Arguments }
    $wrapperArguments = @([scriptblock]::Create($ScriptText), $ArgumentList)
    $origin = [System.Management.Automation.CommandOrigin]::Internal

    $pipeline = $wrapper.GetSteppablePipeline($origin, $wrapperArguments)
    $pipeline.Begin($true)

    foreach ($item in $Queue.GetConsumingEnumerable($CancellationToken)) {
        try {
            $pipeline.Process($item)
        }
        catch {
            Write-Error -Exception $_.Exception.GetBaseException() -TargetObject $item -Category OperationStopped

            # A pipeline that threw cannot be reused.
            $pipeline = $wrapper.GetSteppablePipeline($origin, $wrapperArguments)
            $pipeline.Begin($true)
        }
    }

    $pipeline.End()
}
