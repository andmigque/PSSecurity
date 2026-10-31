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
            The arguments to pass to the script block, bound by position. Accepts values
            from the pipeline; the script block runs once for each piped value.

        .INPUTS
            System.Object. You can pipe values to this function. Each value is passed to the
            script block as its only argument.

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

        .EXAMPLE
            '/root/.ssh', '/etc/ssh' | Invoke-Sudo { param($Path) Get-ChildItem -LiteralPath $Path -Force }

            Lists the contents of each piped path as root. sudo and pwsh start once per path.
        #>
        [CmdletBinding()]
        [OutputType([object])]
        param(
            [Parameter(Mandatory, HelpMessage = 'Enter the script block to run as root.')]
            [scriptblock]$ScriptBlock,

            [Parameter(ValueFromPipeline,
                HelpMessage = 'Enter the arguments to pass to the script block. Accepts values from the pipeline.')]
            [object[]]$ArgumentList
        )
        begin {
            $pwsh = Join-Path -Path $PSHOME -ChildPath 'pwsh'
        }
        process {
            if ($PSBoundParameters.ContainsKey('ArgumentList')) {
                (sudo $pwsh -NoProfile -Command $ScriptBlock -args $ArgumentList)
            }
            else {
                (sudo $pwsh -NoProfile -Command $ScriptBlock)
            }
        }
    }
}
