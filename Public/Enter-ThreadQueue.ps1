#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Enter-ThreadQueue {
    <#
    .SYNOPSIS
        Runs a script block for each input object on a fixed pool of thread jobs.

    .DESCRIPTION
        Collects the input objects into a shared queue, then starts up to
        -ThrottleLimit thread jobs that each take objects from the queue until it is
        empty. Each worker pipes the objects it takes into its own copy of the script
        block, so begin runs once per worker, process runs once per object, and end runs
        once per worker. Use begin to set up expensive per-worker state, such as
        buffers or connections, once instead of once per object.

        The script block must have a process block. One without, such as { $_ }, is
        rejected before any worker starts.

        Output is streamed as workers produce it and is not in input order. Errors
        written by the script block are passed through. When the script block throws,
        the error is written with the failing object as its TargetObject, and the
        worker restarts the script block, including begin, for the remaining objects.

        Workers run in separate runspaces. Variables, functions, and modules from the
        calling session, including this module's private functions, are not available.
        Pass values with -ArgumentList. Strict mode is set to Latest in every worker.

        Ctrl+C cancels the remaining objects and stops the workers. An object that is
        being processed is not interrupted until the script block returns.

    .PARAMETER InputObject
        The objects to process. Accepts objects from the pipeline. All objects are
        collected before the first worker starts.

    .PARAMETER ScriptBlock
        The script block to run for each object. It must have a process block, where
        the current object is $_. Declare a param() block to receive the values from
        -ArgumentList.

    .PARAMETER ArgumentList
        The arguments to pass to the script block in every worker, bound by position.

    .PARAMETER ThrottleLimit
        The maximum number of workers, from 1 through 255. Defaults to 1. Fewer
        workers are started when there are fewer objects.

    .INPUTS
        System.Object. You can pipe any objects to this function.

    .OUTPUTS
        System.Object. The output of the script block, in the order it is produced.

    .EXAMPLE
        $files | Enter-ThreadQueue { process { Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256 } }

        Hashes each file on one worker thread.

    .EXAMPLE
        $files | Enter-ThreadQueue -ThrottleLimit 8 -ArgumentList $OutPath {
            param($OutPath)
            begin { $buffer = [byte[]]::new(64KB) }
            process { Copy-WithBuffer -LiteralPath $_.FullName -Destination $OutPath -Buffer $buffer }
        }

        Allocates one buffer per worker instead of one per file, and passes $OutPath
        from the calling session into each worker.

    .EXAMPLE
        $result = 1..20 | Enter-ThreadQueue { process { if ($_ % 5 -eq 0) { throw "bad $_" }; $_ } } -ErrorVariable failed
        $failed.TargetObject

        Returns the 16 numbers that succeeded, and lists 5, 10, 15, and 20 as the
        objects that failed.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory, ValueFromPipeline,
            HelpMessage = 'Enter the objects to process. Accepts objects from the pipeline.')]
        [AllowNull()]
        [object]$InputObject,

        [Parameter(Mandatory, Position = 0, HelpMessage = 'Enter the script block to run for each object.')]
        [scriptblock]$ScriptBlock,

        [Parameter(HelpMessage = 'Enter the arguments to pass to the script block.')]
        [object[]]$ArgumentList = @(),

        [Parameter(HelpMessage = 'Enter the maximum number of workers (1-255).')]
        [ValidateRange(1, 255)]
        [int]$ThrottleLimit = 1
    )
    begin {
        if (-not $ScriptBlock.Ast.ProcessBlock) {
            throw 'Enter-ThreadQueue requires a script block with a process block.'
        }

        $scriptText = $ScriptBlock.ToString()
        $queue = [System.Collections.Concurrent.BlockingCollection[object]]::new()
    }
    process {
        $queue.Add($InputObject)
    }
    end {
        # Workers stop once the queue is empty and marked complete.
        $queue.CompleteAdding()
        if ($queue.Count -eq 0) {
            return
        }

        $cancellation = [System.Threading.CancellationTokenSource]::new()
        $jobs = [System.Collections.Generic.List[System.Management.Automation.Job]]::new()
        try {
            $workerParams = @{
                Queue             = $queue
                ScriptText        = $scriptText
                ArgumentList      = $ArgumentList
                CancellationToken = $cancellation.Token
                Count             = [Math]::Min($ThrottleLimit, $queue.Count)
                ThrottleLimit     = $ThrottleLimit
            }
            Start-QueueWorker @workerParams | ForEach-Object { $jobs.Add($_) }

            Receive-Job -Job $jobs -Wait
        }
        finally {
            # Runs on Ctrl+C too: stop workers taking new objects, then remove the jobs.
            $cancellation.Cancel()
            $jobs | Remove-Job -Force
            $cancellation.Dispose()
            $queue.Dispose()
        }
    }
}
