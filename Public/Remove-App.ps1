Set-StrictMode -Version Latest

if ($IsWindows) {
    function Remove-App {
        <#
        .SYNOPSIS
            Removes AppX packages identified by JSON input.

        .PARAMETER Json
            JSON text containing package full names, for example an array of strings. Accepts pipeline input.

        .EXAMPLE
            Remove-App -Json '["Example.Package_1.0.0.0_x64__publisher"]' -WhatIf

            Previews the removal operation. Requires elevation and is defined on Windows.
        #>
        [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(Mandatory = $true, ValueFromPipeline = $true,
                HelpMessage = 'JSON text containing package full names, for example an array of strings. Accepts pipeline input.')]
            [ValidateNotNullOrEmpty()]
            [string]$Json
        )

        begin {

            Assert-Administrator

            $removeApproved = $PSCmdlet.ShouldProcess(
                [Environment]::MachineName,
                'Remove configured AppX packages for all users'
            )
        }

        process {
            if (-not $removeApproved) {
                return
            }

            try {
                $applications = @(ConvertFrom-Json -InputObject $Json -AsHashtable -Depth 10)
            }
            catch {
                Write-Error "Unable to parse json file: $($_.ErrorDetails)"
                throw
            }

            $applications.ForEach({
                    Remove-AppxPackage -Package $_
                })
        }
    }
}