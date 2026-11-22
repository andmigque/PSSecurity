#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Initialize-ThreadJobBag {
    <#
    .SYNOPSIS
        Creates a bounded bag containing the supplied thread jobs.

    .PARAMETER ThreadJob
        The array of thread jobs to place in the bag.

    .OUTPUTS
        A PSCustomObject containing the original ThreadJob array and the
        populated ConcurrentBag wrapped in a bounded BlockingCollection.

    .EXAMPLE
        Initialize-ThreadJobBag -ThreadJob $threadJobs |
            Initialize-Pool |
            Start-ThreadJobPool
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(HelpMessage = 'Enter the thread jobs to place in the bag.')]
        [ThreadJob.ThreadJob[]]$ThreadJob = @()
    )

    if ($ThreadJob.Length -eq 0) {
        throw 'At least one thread job is required.'
    }

    $bag = [System.Collections.Concurrent.ConcurrentBag[ThreadJob.ThreadJob]]::new($ThreadJob)

    [PSCustomObject]@{
        ThreadJob     = $ThreadJob
        ConcurrentBag = [System.Collections.Concurrent.BlockingCollection[ThreadJob.ThreadJob]]::new(
            $bag,
            $ThreadJob.Length
        )
    }
}
