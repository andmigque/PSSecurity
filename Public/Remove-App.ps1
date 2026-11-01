#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Remove-App {
        <#
        .SYNOPSIS
            Removes AppX packages identified by JSON input.

        .DESCRIPTION
            Parses JSON text into package full names and removes each package with
            Remove-AppxPackage. Confirmation is requested once per run, for the computer,
            not once per package. To keep a package from being installed for new users,
            use Remove-ProvisionedApp.

            Requires an elevated session, including for -WhatIf. Supports -WhatIf and
            -Confirm, and prompts for confirmation by default. Windows only.

        .PARAMETER Json
            JSON text containing package full names, for example an array of strings.
            Accepts JSON text from the pipeline.

        .INPUTS
            System.String. You can pipe JSON text to this function.

        .OUTPUTS
            None. This function does not return output.

        .EXAMPLE
            Remove-App -Json '["Example.Package_1.0.0.0_x64__publisher"]' -WhatIf

            Previews the removal.

        .EXAMPLE
            Get-Content -LiteralPath C:\Config\RemoveApps.json -Raw | Remove-App -Confirm:$false

            Removes the packages listed in a JSON file without prompting.
        #>
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
        param(
            [Parameter(Mandatory, ValueFromPipeline,
                HelpMessage = 'JSON text containing package full names, for example an array of strings. Accepts pipeline input.')]
            [ValidateNotNullOrEmpty()]
            [string]$Json
        )
        begin {
            Assert-Administrator

            $removeApproved = $PSCmdlet.ShouldProcess(
                [System.Environment]::MachineName,
                'Remove configured AppX packages for all users'
            )
        }
        process {
            if ($removeApproved) {
                try {
                    $applications = @(ConvertFrom-Json -InputObject $Json -AsHashtable -Depth 10)
                }
                catch {
                    throw "Unable to parse the JSON input: $($_.Exception.Message)"
                }

                foreach ($application in $applications) {
                    Remove-AppxPackage -Package $application
                }
            }
        }
    }
}
