#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Get-DefaultThreadCount {
    <#
    .SYNOPSIS
        Returns the default thread count.

    .DESCRIPTION
        Doubles the module's default throttle limit and caps the result at 255.

    .INPUTS
        None.

    .OUTPUTS
        PSCustomObject with a ThreadCount property.

    .EXAMPLE
        Get-DefaultThreadCount

        When the default throttle limit is 6, returns an object with ThreadCount set to 12.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    [PSCustomObject]@{
        ThreadCount = [Math]::Min(255, 2 * (Get-DefaultThrottleLimit))
    }
}
