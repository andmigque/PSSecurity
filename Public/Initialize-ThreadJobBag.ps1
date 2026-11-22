#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Initialize-ThreadJobBag {
    <#
    .SYNOPSIS
        Creates a bounded bag containing the supplied thread jobs.

    .DESCRIPTION
        Prepares an unordered bag for the scheduler. Its capacity equals the
        number of jobs supplied. The original array and the bag refer to the
        same job instances, so the array retains each job after the scheduler
        takes it from the bag.

    .PARAMETER ThreadJob
        One or more caller-created ThreadJob objects awaiting their first start.
        Supply the whole array to -ThreadJob. An empty array raises an error.

    .INPUTS
        Supply jobs by parameter.

    .OUTPUTS
        A PSCustomObject containing the original ThreadJob array and the
        populated ConcurrentBag wrapped in a bounded BlockingCollection.

    .EXAMPLE
        $bag = Initialize-ThreadJobBag -ThreadJob $threadJobs
        $bag.ConcurrentBag.BoundedCapacity

        Returns the number of supplied jobs. Start-ThreadJobPool sets concurrency
        when the bag is passed through Initialize-Pool.
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
