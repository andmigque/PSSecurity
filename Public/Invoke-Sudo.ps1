#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsLinux) {
    function Invoke-Sudo {
        <#
        .SYNOPSIS
            Runs a script block as root through sudo.

        .DESCRIPTION
            Passes the script block to the current pwsh binary under sudo with -NoProfile
            and returns its output. sudo may prompt for a password.

        .PARAMETER ScriptBlock
            The script block to run as root.

        .INPUTS
            None. This function does not accept pipeline input.

        .OUTPUTS
            System.String. The text output of the script block.

        .EXAMPLE
            Invoke-Sudo { Get-ChildItem -Path /root }

            Lists the contents of /root as root.
        #>
        [CmdletBinding()]
        [OutputType([string])]
        param(
            [Parameter(Mandatory, HelpMessage = 'Enter the script block to run as root.')]
            [scriptblock]$ScriptBlock
        )

        $pwsh = Join-Path -Path $PSHOME -ChildPath 'pwsh'
        (sudo $pwsh -NoProfile -Command $ScriptBlock)
    }
}