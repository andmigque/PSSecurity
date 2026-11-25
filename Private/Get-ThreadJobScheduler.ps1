#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Get-ThreadJobScheduler {
    <#
    .SYNOPSIS
        Gets the thread job scheduler script block.

    .DESCRIPTION
        The script block takes the pool's bounded job bag, the original job
        array, and the resolved thread count. It dispatches jobs as slots open
        until the bag is empty.

    .INPUTS
        None.

    .OUTPUTS
        System.Management.Automation.ScriptBlock.

    .EXAMPLE
        $scheduler = Get-ThreadJobScheduler

        Gets the script block for the pool's scheduler runspace.
    #>
    [CmdletBinding()]
    [OutputType([ScriptBlock])]
    param()

    [ScriptBlock]$scheduler = {
        param([System.Collections.Concurrent.BlockingCollection[ThreadJob.ThreadJob]]$Bag, [ThreadJob.ThreadJob[]]$ThreadJob, [int]$ThreadCount)

        do {
            $activeThreadJobCount = $ThreadJob.Where({ $_.State -eq 'Running' }).Count

            for ($i = $activeThreadJobCount; $i -lt $ThreadCount; $i++) {
                if ($Bag.Count -gt 0) {
                    $Bag.Take().StartJob()
                }
            }
        } while ($Bag.Count -gt 0)
    }

    $scheduler
}
