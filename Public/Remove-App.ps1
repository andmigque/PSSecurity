using namespace System
using namespace System.Collections.Generic
using namespace System.Management.Automation

Set-StrictMode -Version Latest

if ($IsWindows) {
    function Remove-App {
        [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
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