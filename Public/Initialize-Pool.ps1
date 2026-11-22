#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Initialize-Pool {
    <#
    .SYNOPSIS
        Opens a scheduler runspace for a thread job bag.

    .DESCRIPTION
        Adds the open runspace to the supplied object and returns that same object.

    .PARAMETER InputObject
        The pool state returned by Initialize-ThreadJobBag. Accepts pipeline input.

    .INPUTS
        PSCustomObject from Initialize-ThreadJobBag.

    .OUTPUTS
        PSCustomObject with ConcurrentBag, ThreadJob, and Runspace properties.

    .EXAMPLE
        $pool = Initialize-ThreadJobBag -ThreadJob $threadJobs | Initialize-Pool
        $pool.Runspace.RunspaceStateInfo.State

        Returns Opened.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline,
            HelpMessage = 'Enter the object returned by Initialize-ThreadJobBag.')]
        [PSCustomObject]$InputObject
    )

    process {
        $runspace = [RunspaceFactory]::CreateRunspace()
        try {
            $runspace.Open()
            Add-Member -InputObject $InputObject -NotePropertyName Runspace -NotePropertyValue $runspace -ErrorAction Stop
        }
        catch {
            $runspace.Dispose()
            throw
        }

        $InputObject
    }
}
