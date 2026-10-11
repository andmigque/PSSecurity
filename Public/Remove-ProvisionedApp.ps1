Set-StrictMode -Version Latest

if ($IsWindows) {
    function Remove-ProvisionedApp {
        <#
        .SYNOPSIS
            Removes provisioned AppX packages from the online Windows image.

        .PARAMETER Json
            JSON text containing provisioned package names, for example an array of strings. Accepts pipeline input.

        .EXAMPLE
            Remove-ProvisionedApp -Json '["Example.Package_1.0.0.0_neutral_~_publisher"]' -WhatIf

            Previews removal of the listed provisioned packages for all users. Requires elevation.
        #>
        [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(Mandatory = $true, ValueFromPipeline = $true,
                HelpMessage = 'JSON text containing provisioned package names, for example an array of strings. Accepts pipeline input.')]
            [ValidateNotNullOrEmpty()]
            [string]$Json
        )

        begin {

            Assert-Administrator

            $removeApproved = $PSCmdlet.ShouldProcess(
                [Environment]::MachineName,
                'Remove provisioned app packages for all users'
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
                    Remove-AppxProvisionedPackage -PackageName $_ -AllUsers -Online
                })
        }
    }
}