#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Get-ApplicationSignatureAudit {
        <#
        .SYNOPSIS
            Audits Authenticode signatures of discoverable applications.

        .DESCRIPTION
            Finds every application on the PATH with Get-Command, then checks each
            signature with Get-AuthenticodeSignature on a pool of thread jobs, using
            Enter-ThreadQueue. Applications in WindowsApps are excluded. Each application
            produces a signature record, or an Error record when the check throws.

            Returns one summary with counts by outcome, every record in Results, and the
            inconclusive checks in Errors. Result order is not guaranteed. Windows only.

        .PARAMETER ThrottleLimit
            The maximum number of applications checked at once, from 1 through 255.
            Defaults to 75% of the processors, rounded down, and at least 1.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. One summary with these
            properties:

            - TotalApplications: applications found.
            - AuditedApplications: checks with a conclusive status.
            - ValidApplications: status Valid.
            - UnsignedApplications: status NotSigned.
            - InvalidApplications: status HashMismatch or NotTrusted.
            - FailedApplications: inconclusive statuses and checks that threw.
            - Results: one record per application.
            - Errors: Path and Message of each failed check. Unsigned and invalid
              applications are not errors.

            No applications returns zero counts and empty arrays.

        .EXAMPLE
            $result = Get-ApplicationSignatureAudit
            $result.Results | Where-Object -Property Status -NE 'Valid' | Format-Table Name, Status, Path

            Lists the applications without a valid signature.

        .EXAMPLE
            Get-ApplicationSignatureAudit -ThrottleLimit 8

            Checks up to eight applications at once.

        .EXAMPLE
            (Get-ApplicationSignatureAudit).Errors

            Lists the applications whose signature could not be checked.
        #>
        [CmdletBinding()]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(HelpMessage = 'Enter the maximum number of applications checked at once (1-255).')]
            [ValidateRange(1, 255)]
            [int]$ThrottleLimit
        )

        if (-not $PSBoundParameters.ContainsKey('ThrottleLimit')) {
            $ThrottleLimit = Get-DefaultThrottleLimit
        }

        $applications = @(
            Get-Command -CommandType Application -All |
                Where-Object -Property Source -NotLike '*\AppData\Local\Microsoft\WindowsApps\*' |
                Select-Object -Property Name, Source
        )

        $results = @(
            $applications | Enter-ThreadQueue -ThrottleLimit $ThrottleLimit {
                process {
                    # Inside catch, $_ is the error, so keep the application.
                    $application = $_
                    try {
                        $signature = Get-AuthenticodeSignature -LiteralPath $application.Source -ErrorAction Stop
                        $signer = if ($signature.SignerCertificate) {
                            $signature.SignerCertificate.Subject
                        }
                        else {
                            'Unsigned'
                        }
                        $timeStamper = if ($signature.TimeStamperCertificate) {
                            $signature.TimeStamperCertificate.Subject
                        }
                        else {
                            'None'
                        }

                        [PSCustomObject]@{
                            Name              = $application.Name
                            Path              = $application.Source
                            Status            = $signature.Status.ToString()
                            StatusMessage     = $signature.StatusMessage
                            SignerCertificate = $signer
                            TimeStamper       = $timeStamper
                            IsOSBinary        = $signature.IsOSBinary
                            SignatureType     = $signature.SignatureType.ToString()
                        }
                    }
                    catch {
                        [PSCustomObject]@{
                            Name              = $application.Name
                            Path              = $application.Source
                            Status            = 'Error'
                            StatusMessage     = $_.Exception.Message
                            SignerCertificate = 'Error'
                            TimeStamper       = 'None'
                            IsOSBinary        = $false
                            SignatureType     = 'Unknown'
                        }
                    }
                }
            }
        )

        $conclusiveStatus = 'Valid', 'NotSigned', 'HashMismatch', 'NotTrusted'
        $failures = @($results | Where-Object -Property Status -NotIn $conclusiveStatus)

        [PSCustomObject]@{
            TotalApplications    = $applications.Count
            AuditedApplications  = $applications.Count - $failures.Count
            ValidApplications    = @($results | Where-Object -Property Status -EQ 'Valid').Count
            UnsignedApplications = @($results | Where-Object -Property Status -EQ 'NotSigned').Count
            InvalidApplications  = @($results | Where-Object -Property Status -In 'HashMismatch', 'NotTrusted').Count
            FailedApplications   = $failures.Count
            Results              = $results
            Errors               = @(
                foreach ($failure in $failures) {
                    [PSCustomObject]@{ Path = $failure.Path; Message = $failure.StatusMessage }
                }
            )
        }
    }
}
