#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Initialize-ThreadJobBag {
    <#
    .SYNOPSIS
        Creates a bounded, unordered bag of thread jobs.

    .DESCRIPTION
        Creates one bag per input. A BlockingCollection bounds its capacity at
        the resolved thread count and stores jobs in a ConcurrentBag.

    .PARAMETER ThreadCount
        Specify 1 through 255 to set the bag capacity. Omit ThreadCount or pass
        0 to use the count calculated by Get-DefaultThreadCount.

    .INPUTS
        System.Int32 or an object with a ThreadCount property.

    .OUTPUTS
        PSCustomObject with ConcurrentBag and ThreadCount properties.
        Use the ConcurrentBag property's Add and TryTake methods to submit and take jobs.

    .EXAMPLE
        (Initialize-ThreadJobBag -ThreadCount 8).ConcurrentBag.BoundedCapacity

        Returns 8.

    .EXAMPLE
        0, 4 | Initialize-ThreadJobBag

        Creates two bags. The first uses the calculated default. The second has four slots.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName,
            HelpMessage = 'Enter 1 through 255 for a fixed capacity, or 0 to use the calculated default.')]
        [ValidateRange(0, 255)]
        [int]$ThreadCount = 0
    )

    begin {
        $default = (Get-DefaultThreadCount).ThreadCount
    }

    process {
        $count = $ThreadCount -eq 0 ? $default : $ThreadCount
        $bag = [System.Collections.Concurrent.ConcurrentBag[ThreadJob.ThreadJob]]::new()

        [PSCustomObject]@{
            ConcurrentBag = [System.Collections.Concurrent.BlockingCollection[ThreadJob.ThreadJob]]::new($bag, $count)
            ThreadCount   = $count
        }
    }
}
