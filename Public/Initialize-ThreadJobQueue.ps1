#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Initialize-ThreadJobQueue {
    <#
    .SYNOPSIS
        Creates a bounded collection of thread jobs.

    .DESCRIPTION
        Creates one queue per input. Its capacity equals the resolved thread count.

    .PARAMETER ThreadCount
        Specify 1 through 255 to set the queue capacity. Omit ThreadCount or pass
        0 to use the count calculated by Get-DefaultThreadCount.

    .INPUTS
        System.Int32 or an object with a ThreadCount property.

    .OUTPUTS
        PSCustomObject with Queue and ThreadCount properties.

    .EXAMPLE
        (Initialize-ThreadJobQueue -ThreadCount 8).Queue.BoundedCapacity

        Returns 8.

    .EXAMPLE
        0, 4 | Initialize-ThreadJobQueue

        Creates two queues. The first uses the calculated default. The second has four slots.
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

        [PSCustomObject]@{
            Queue       = [System.Collections.Concurrent.BlockingCollection[ThreadJob.ThreadJob]]::new($count)
            ThreadCount = $count
        }
    }
}
