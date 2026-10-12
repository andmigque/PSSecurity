if ($IsLinux) {
    Set-StrictMode -Version Latest

    function Set-CoreDumpPolicy {
        <#
    .SYNOPSIS
        Restricts Linux core dumps through PAM limits and systemd configuration.

    .DESCRIPTION
        Writes a dedicated limits file containing * hard core 0 and root hard core 0.
        When systemd is installed, also writes a coredump drop-in with Storage=none
        and ProcessSizeMax=0, then runs systemctl daemon-reload. Creates missing
        parent directories and verifies each written file. Existing matching files
        are kept. Other configuration files are not evaluated for overrides.

        Implements the file policy portion of CIS 1.5.1. The kernel setting
        fs.suid_dumpable=0 already belongs to SysctlHardening; apply it separately
        with Set-SysctlHardening -Persist. PAM limits affect new sessions using
        pam_limits and do not alter existing processes.

    .PARAMETER Path
        Limits drop-in path. Defaults to /etc/security/limits.d/99-pssecurity-core.conf.

    .PARAMETER OutPath
        systemd coredump drop-in path. Defaults to
        /etc/systemd/coredump.conf.d/99-pssecurity-core.conf.

    .PARAMETER Elevate
        Runs the function as root through the module's existing sudo helper.
        sudo may prompt for a password. Preserves -WhatIf and -Confirm.

    .OUTPUTS
        One summary with Path, OutPath, TotalFiles, HardenedFiles, FailedFiles,
        and Errors. HardenedFiles counts newly written, verified policy files.
        Errors contains Path and Message, including a Missing message for the
        coredump file when systemd is absent. A reload failure counts as a failure.

    .EXAMPLE
        Set-CoreDumpPolicy -WhatIf

    .EXAMPLE
        Set-CoreDumpPolicy -Elevate
    #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([pscustomobject])]
        param(
            [Parameter(HelpMessage = 'Enter the limits drop-in path.')]
            [ValidateNotNullOrEmpty()]
            [string]$Path = '/etc/security/limits.d/99-pssecurity-core.conf',

            [Parameter(HelpMessage = 'Enter the systemd coredump drop-in path.')]
            [ValidateNotNullOrEmpty()]
            [string]$OutPath = '/etc/systemd/coredump.conf.d/99-pssecurity-core.conf',

            [Parameter(HelpMessage = 'Run as root through sudo.')]
            [switch]$Elevate
        )

        $Path = [System.IO.Path]::GetFullPath($Path)
        $OutPath = [System.IO.Path]::GetFullPath($OutPath)
        if ($Path -ceq $OutPath) { throw 'Path and OutPath must be different.' }

        $sessionIsRoot = (& id -u) -eq 0
        if ($Elevate -and -not $sessionIsRoot) {
            $command = "Set-CoreDumpPolicy -Path '$($Path.Replace("'", "''"))' -OutPath '$($OutPath.Replace("'", "''"))'"
            if ($WhatIfPreference) { $command += ' -WhatIf' }
            if ($PSBoundParameters.ContainsKey('Confirm')) { $command += ' -Confirm:$' + [string][bool]$PSBoundParameters['Confirm'] }
            Invoke-SudoCommand -Command $command
            return
        }

        $policyFiles = @(
            @{ Path = $Path; Content = "* hard core 0`nroot hard core 0`n" }
            @{ Path = $OutPath; Content = "[Coredump]`nStorage=none`nProcessSizeMax=0`n" }
        )
        $systemdInstalled = (Test-Path -LiteralPath '/usr/lib/systemd/systemd') -or (Test-Path -LiteralPath '/lib/systemd/systemd')
        $errors = [System.Collections.Generic.List[object]]::new()
        $hardenedFiles = 0

        foreach ($policy in $policyFiles) {
            try {
                if ($policy.Path -ceq $OutPath -and -not $systemdInstalled) {
                    throw 'Missing: systemd is not installed; coredump drop-in was skipped.'
                }

                if (Test-Path -LiteralPath $policy.Path) {
                    $existingFile = Get-Item -LiteralPath $policy.Path -Force -ErrorAction Stop
                    if ($existingFile.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                        throw 'Policy file is a symbolic link.'
                    }
                    $before = Get-Content -LiteralPath $policy.Path -Raw -ErrorAction Stop
                    if ($before -ceq $policy.Content) { continue }
                }

                if ($PSCmdlet.ShouldProcess($policy.Path, 'Write core dump policy')) {
                    $parentPath = Split-Path -Path $policy.Path -Parent
                    [void][System.IO.Directory]::CreateDirectory($parentPath)
                    Set-Content -LiteralPath $policy.Path -Value $policy.Content -NoNewline -Encoding utf8 -ErrorAction Stop
                    $after = Get-Content -LiteralPath $policy.Path -Raw -ErrorAction Stop
                    if ($after -cne $policy.Content) { throw 'Written file did not match the requested policy.' }

                    if ($policy.Path -ceq $OutPath) {
                        & systemctl daemon-reload
                        if ($LASTEXITCODE -ne 0) { throw 'systemctl daemon-reload failed.' }
                    }
                    $hardenedFiles++
                }
            }
            catch {
                $errors.Add([pscustomobject]@{ Path = $policy.Path; Message = $_.Exception.Message })
            }
        }

        [pscustomobject]@{
            Path          = $Path
            OutPath       = $OutPath
            TotalFiles    = $policyFiles.Count
            HardenedFiles = $hardenedFiles
            FailedFiles   = $errors.Count
            Errors        = $errors.ToArray()
        }
    }
}
