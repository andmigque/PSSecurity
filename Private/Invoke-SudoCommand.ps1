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
        result. The child emits CLIXML (-OutputFormat xml), which PowerShell deserializes
        back into objects on the success stream. sudo may prompt for a password.

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
        $fullCommand = "Import-Module '$($modulePath.Replace("'", "''"))'; $Command"
        $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($fullCommand))

        $sudoOutput = & sudo $pwshPath -NoLogo -NoProfile -OutputFormat xml -EncodedCommand $encoded
        if ($LASTEXITCODE -ne 0) {
            throw "sudo exited with code $LASTEXITCODE."
        }
        $sudoOutput
    }
}
