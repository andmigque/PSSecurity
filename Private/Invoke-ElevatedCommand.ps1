if ($IsWindows) {
    Set-StrictMode -Version Latest

    function Invoke-ElevatedCommand {
        <#
    .SYNOPSIS
        Re-runs a module command elevated through UAC and returns its output.

    .DESCRIPTION
        The Windows counterpart of Invoke-SudoCommand. A PowerShell function cannot
        re-launch itself elevated with its streams intact, so the public audit
        functions rebuild their invocation and hand it here. This starts a hidden
        elevated pwsh child through UAC, imports the module in the child, runs the
        given command, and serializes the result to a temp file with Export-CliXml,
        which this function imports and returns. A child failure is serialized in
        place of the result so the parent can throw its message. Windows shows a
        UAC consent prompt; canceling it throws.

    .PARAMETER Command
        The function invocation to run elevated, for example Get-SshdConfiguration.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        The object the command emitted on its success stream, typically one
        PSCustomObject report.
    #>
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            # The function invocation to run elevated.
            [Parameter(Mandatory = $true, HelpMessage = 'Enter the command to run elevated.')]
            [string]$Command
        )

        # Import the module in the child so the re-invoked function and its settings
        # reload. A child failure is serialized in place of the result so the parent
        # can throw its message. Depth keeps the nested report arrays intact.
        $modulePath = $MyInvocation.MyCommand.Module.Path
        $pwshPath = (Get-Process -Id $PID).Path
        $outputPath = [System.IO.Path]::GetTempFileName()

        try {
            $moduleArgument = $modulePath.Replace("'", "''")
            $outputArgument = $outputPath.Replace("'", "''")
            $runStatement = "$Command | Export-Clixml -LiteralPath '$outputArgument' -Force -Depth 6"
            $errorStatement = "@{ Error = `$_.Exception.Message } | Export-Clixml -LiteralPath '$outputArgument' -Force"
            $fullCommand = "try { Import-Module '$moduleArgument'; $runStatement } catch { $errorStatement }"
            $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($fullCommand))

            try {
                $childProcess = Start-Process -FilePath $pwshPath `
                    -ArgumentList @('-NoLogo', '-NoProfile', '-NonInteractive', '-EncodedCommand', $encoded) `
                    -Verb RunAs -Wait -PassThru -WindowStyle Hidden
            }
            catch {
                throw "The elevated PowerShell process could not start: $($_.Exception.Message)"
            }

            if ($childProcess.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $outputPath)) {
                throw "The elevated run exited with code $($childProcess.ExitCode) and produced no output."
            }

            $rehydrated = Import-Clixml -LiteralPath $outputPath
            if ($rehydrated -is [hashtable]) {
                throw "The elevated run failed: $($rehydrated.Error)"
            }

            $rehydrated
        }
        finally {
            Remove-Item -LiteralPath $outputPath -Force -ErrorAction SilentlyContinue
        }
    }
}
