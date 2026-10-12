if (-not $IsWindows) {
    Set-StrictMode -Version Latest

    function Invoke-SudoCommand {
        <#
    .SYNOPSIS
        Re-runs a module command as root through sudo and returns its output.

    .DESCRIPTION
        A PowerShell function cannot be invoked through sudo directly, so the public audit
        functions rebuild their invocation and hand it here. This imports the module in the
        child process, runs the given command under sudo pwsh, and returns the rehydrated
        result. Progress records are relayed to Write-Progress in the calling session.
        The result is exported to a temporary CLIXML file, imported by the caller,
        and the file is removed. sudo may prompt for a password.

    .PARAMETER Command
        The function invocation to run as root, for example Get-SuidBinary -Path '/'.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        The object the command emitted on its success stream, typically one PSCustomObject
        report.
    #>
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            # The function invocation to run as root.
            [Parameter(Mandatory = $true, HelpMessage = 'Enter the command to run as root.')]
            [string]$Command
        )

        if (-not (Get-Command -Name sudo -ErrorAction SilentlyContinue)) {
            throw 'sudo was not found on this system. Run as root instead.'
        }

        # Import the module in the child so the re-invoked function and its settings reload.
        $modulePath = $MyInvocation.MyCommand.Module.Path
        $pwshPath = Join-Path -Path $PSHOME -ChildPath 'pwsh'
        $resultPath = [System.IO.Path]::GetTempFileName()
        try {
            # Emit progress as individual lines so the caller can render it immediately.
            $progressRelay = @'
function Write-Progress {
    param(
        [int]$Id, [int]$ParentId, [string]$Activity, [string]$Status,
        [string]$CurrentOperation, [int]$PercentComplete, [switch]$Completed
    )
    $progress = @{} + $PSBoundParameters
    if ($progress.ContainsKey('Completed')) { $progress.Completed = [bool]$Completed }
    [Console]::WriteLine('PSSecurityProgress:' + ($progress | ConvertTo-Json -Compress))
}
'@
            $fullCommand = @"
`$ErrorActionPreference = 'Stop'
Import-Module '$($modulePath.Replace("'", "''"))'
$progressRelay
`$result = @(& { $Command })
Export-Clixml -LiteralPath '$($resultPath.Replace("'", "''"))' -InputObject `$result -Depth 20
"@
            $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($fullCommand))

            & sudo $pwshPath -NoLogo -NoProfile -OutputFormat Text -EncodedCommand $encoded | ForEach-Object {
                if ($_.StartsWith('PSSecurityProgress:', [StringComparison]::Ordinal)) {
                    $progress = $_.Substring('PSSecurityProgress:'.Length) | ConvertFrom-Json -AsHashtable -ErrorAction Stop
                    Write-Progress @progress
                }
                else {
                    $_ | Out-Host
                }
            }
            if ($LASTEXITCODE -ne 0) {
                throw "sudo exited with code $LASTEXITCODE."
            }
            Import-Clixml -LiteralPath $resultPath -ErrorAction Stop
        }
        finally {
            [System.IO.File]::Delete($resultPath)
        }
    }
}
