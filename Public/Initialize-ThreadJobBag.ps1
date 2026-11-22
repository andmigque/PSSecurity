#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Initialize-ThreadJobBag {
    <#
    .SYNOPSIS
        Creates an empty concurrent bag of thread jobs.

    .DESCRIPTION
        Creates one ConcurrentBag per input and returns it with the resolved thread count.

    .PARAMETER ThreadCount
        Specify 1 through 255 to set the thread count. Omit ThreadCount or pass
        0 to use the count calculated by Get-DefaultThreadCount.

    .INPUTS
        System.Int32 or an object with a ThreadCount property.

    .OUTPUTS
        PSCustomObject with ConcurrentBag and ThreadCount properties.
        Use the ConcurrentBag property's Add and TryTake methods to submit and take jobs.

    .EXAMPLE
        (Initialize-ThreadJobBag -ThreadCount 8).ConcurrentBag.Count

        Returns 0 because the new bag is empty.

    .EXAMPLE
        0, 4 | Initialize-ThreadJobBag

        Creates two bags. The first has the default thread count. The second has a thread count of 4.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName,
            HelpMessage = 'Enter a thread count from 1 through 255, or 0 to use the calculated default.')]
        [ValidateRange(0, 255)]
        [int]$ThreadCount = 0
    )

    begin {
        $default = (Get-DefaultThreadCount).ThreadCount
    }

    process {
        $count = $ThreadCount -eq 0 ? $default : $ThreadCount

        [PSCustomObject]@{
            ConcurrentBag = [System.Collections.Concurrent.ConcurrentBag[ThreadJob.ThreadJob]]::new()
            ThreadCount   = $count
        }
    }
}
