#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Remove-ProvisionedApp {
        <#
        .SYNOPSIS
            Removes provisioned AppX packages from the online Windows image.

        .DESCRIPTION
            Parses JSON text into provisioned package names and removes each one from the
            running Windows image with Remove-AppxProvisionedPackage, for all users. New
            user profiles no longer receive the package. Packages already installed for
            existing users are not removed; use Remove-App for those. Confirmation is
            requested once per run, for the computer, not once per package.

            Requires an elevated session, including for -WhatIf. Supports -WhatIf and
            -Confirm, and prompts for confirmation by default. Windows only.

        .PARAMETER Json
            JSON text containing provisioned package names, for example an array of
            strings. Accepts JSON text from the pipeline.

        .INPUTS
            System.String. You can pipe JSON text to this function.

        .OUTPUTS
            Microsoft.Dism.Commands.ImageObject. One object per removed package, from
            Remove-AppxProvisionedPackage.

        .EXAMPLE
            Remove-ProvisionedApp -Json '["Example.Package_1.0.0.0_neutral_~_publisher"]' -WhatIf

            Previews the removal.

        .EXAMPLE
            Get-Content -LiteralPath C:\Config\RemoveProvisionedApps.json -Raw | Remove-ProvisionedApp -Confirm:$false

            Removes the provisioned packages listed in a JSON file without prompting.
        #>
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
        [OutputType('Microsoft.Dism.Commands.ImageObject')]
        param(
            [Parameter(Mandatory, ValueFromPipeline,
                HelpMessage = 'JSON text containing provisioned package names, for example an array of strings. Accepts pipeline input.')]
            [ValidateNotNullOrEmpty()]
            [string]$Json
        )
        begin {
            Assert-Administrator

            $removeApproved = $PSCmdlet.ShouldProcess(
                [System.Environment]::MachineName,
                'Remove provisioned app packages for all users'
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
                    Remove-AppxProvisionedPackage -PackageName $application -AllUsers -Online
                }
            }
        }
    }
}
