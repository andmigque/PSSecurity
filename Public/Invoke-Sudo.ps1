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

            PowerShell sends the script block and its arguments to the root process as
            base64 encoded CliXml and deserializes the output, so argument and output
            types are preserved as data, without methods. Variables from the calling
            session are not available; pass them through -ArgumentList instead.

            Arguments are visible in the process list while the command runs. Do not
            pass secrets through -ArgumentList.

        .PARAMETER ScriptBlock
            The script block to run as root. Declare a param() block to receive the
            values from -ArgumentList.

        .PARAMETER ArgumentList
            The arguments to pass to the script block, bound by position.

        .INPUTS
            None. This function does not accept pipeline input.

        .OUTPUTS
            System.Object. The deserialized output of the script block. The type of each
            item depends on the script block, for example System.String for the text
            output of a Linux command.

        .EXAMPLE
            Invoke-Sudo { Get-ChildItem -Path /root }

            Lists the contents of /root as root.

        .EXAMPLE
            Invoke-Sudo { param($Path) Get-ChildItem -LiteralPath $Path } -ArgumentList '/root'

            Lists the contents of the path passed in -ArgumentList as root.
        #>
        [CmdletBinding()]
        [OutputType([object])]
        param(
            [Parameter(Mandatory, HelpMessage = 'Enter the script block to run as root.')]
            [scriptblock]$ScriptBlock,

            [Parameter(HelpMessage = 'Enter the arguments to pass to the script block.')]
            [object[]]$ArgumentList
        )

        $pwsh = Join-Path -Path $PSHOME -ChildPath 'pwsh'
        if ($PSBoundParameters.ContainsKey('ArgumentList')) {
            (sudo $pwsh -NoProfile -Command $ScriptBlock -args $ArgumentList)
        }
        else {
            (sudo $pwsh -NoProfile -Command $ScriptBlock)
        }
    }
}
