#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Start-QueueWorker {
    <#
    .SYNOPSIS
        Starts thread jobs that each run Invoke-QueueWorker on a shared queue.

    .DESCRIPTION
        Starts -Count thread jobs. Each job runs Invoke-QueueWorker against the same
        queue, so the jobs share the objects between them. Jobs are returned as they
        start, so a caller that collects them can still clean up if a later job fails
        to start.

        Thread jobs run in their own runspaces, where this module's functions are not
        defined. The job script is built from the text of Invoke-QueueWorker.

    .PARAMETER Queue
        The shared queue of objects to process.

    .PARAMETER ScriptText
        The script block to run on each object, as text.

    .PARAMETER ArgumentList
        The arguments to pass to the script block, bound by position.

    .PARAMETER CancellationToken
        Stops the workers from taking more objects when cancelled.

    .PARAMETER Count
        The number of workers to start, from 1 through 255.

    .PARAMETER ThrottleLimit
        The maximum number of thread jobs that run at once, from 1 through 255. Passed
        to Start-ThreadJob, which applies it to all thread jobs in the session.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        ThreadJob.ThreadJob. One job per worker.

    .EXAMPLE
        $jobs = Start-QueueWorker -Queue $queue -ScriptText 'process { $_ }' -CancellationToken $token -Count 4 -ThrottleLimit 8

        Starts four workers on $queue, with up to eight thread jobs running at once.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.Job])]
    param(
        [Parameter(Mandatory, HelpMessage = 'Enter the shared queue of objects to process.')]
        [System.Collections.Concurrent.BlockingCollection[object]]$Queue,

        [Parameter(Mandatory, HelpMessage = 'Enter the script block to run, as text.')]
        [string]$ScriptText,

        [Parameter(HelpMessage = 'Enter the arguments to pass to the script block.')]
        [object[]]$ArgumentList = @(),

        [Parameter(Mandatory, HelpMessage = 'Enter the token that stops the workers.')]
        [System.Threading.CancellationToken]$CancellationToken,

        [Parameter(Mandatory, HelpMessage = 'Enter the number of workers to start (1-255).')]
        [ValidateRange(1, 255)]
        [int]$Count,

        [Parameter(Mandatory, HelpMessage = 'Enter the maximum number of thread jobs that run at once (1-255).')]
        [ValidateRange(1, 255)]
        [int]$ThrottleLimit
    )

    $workerText = (Get-Command -Name Invoke-QueueWorker).ScriptBlock.ToString()

    $threadJobParams = @{
        ScriptBlock   = [scriptblock]::Create($workerText)
        ThrottleLimit = $ThrottleLimit
        ArgumentList  = $Queue, $ScriptText, $ArgumentList, $CancellationToken
        ErrorAction   = 'Stop'
    }

    for ($index = 0; $index -lt $Count; $index++) {
        Start-ThreadJob @threadJobParams
    }
}
