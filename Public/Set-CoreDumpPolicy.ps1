#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsLinux) {
    function Set-CoreDumpPolicy {
        <#
        .SYNOPSIS
            Disables core dumps through PAM limits and systemd-coredump.

        .DESCRIPTION
            Writes a limits.d file that sets the hard core limit to 0 for every account and
            for root. On hosts running systemd, also writes a coredump.conf.d drop-in with
            Storage=none and ProcessSizeMax=0, then runs systemctl daemon-reload. Each file is
            read back after writing to verify it. A file that already holds the policy is
            left alone.

            Implements the file portion of CIS 1.5.1. The kernel setting fs.suid_dumpable=0
            belongs to Set-SysctlHardening.

        .PARAMETER Path
            The limits.d file to write.

        .PARAMETER CoredumpPath
            The systemd coredump.conf.d drop-in to write.

        .INPUTS
            None. This function does not accept pipeline input.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. Path and Status for each policy file.
            Status is Compliant, Preview, Hardened, Failed, or NotApplicable.

        .EXAMPLE
            Set-CoreDumpPolicy -WhatIf

            Previews the two policy files.

        .EXAMPLE
            Invoke-Sudo { Import-Module PSSecurity; Set-CoreDumpPolicy }

            Writes the policy files as root.

        .NOTES
            Run as root. PAM limits apply to sessions started after the change; running
            processes keep their current limits.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([pscustomobject])]
        param(
            [Parameter(HelpMessage = 'Enter the limits.d file to write.')]
            [ValidateNotNullOrEmpty()]
            [string]$Path = '/etc/security/limits.d/99-pssecurity-core.conf',

            [Parameter(HelpMessage = 'Enter the systemd coredump drop-in to write.')]
            [ValidateNotNullOrEmpty()]
            [string]$CoredumpPath = '/etc/systemd/coredump.conf.d/99-pssecurity-core.conf'
        )

        # pam_limits never applies the '*' wildcard to root, so root needs its own line.
        $policies = @(
            [pscustomobject]@{ Path = $Path; Content = "* hard core 0`nroot hard core 0`n"; Reload = $false }
        )

        # /run/systemd/system exists only while systemd is the running init, the same test
        # sd_booted() uses. A systemd binary on disk does not mean systemd-coredump handles
        # crashes on this host, as in containers.
        if (Test-Path -LiteralPath '/run/systemd/system' -PathType Container) {
            $policies += [pscustomobject]@{ Path = $CoredumpPath; Content = "[Coredump]`nStorage=none`nProcessSizeMax=0`n"; Reload = $true }
        }
        else {
            [pscustomobject]@{ Path = $CoredumpPath; Status = 'NotApplicable' }
        }

        foreach ($policy in $policies) {
            $result = [pscustomobject]@{ Path = $policy.Path; Status = 'Compliant' }

            try {
                $existing = Get-Item -LiteralPath $policy.Path -Force -ErrorAction Ignore

                # Writing through a symlink as root overwrites whatever file the link points at.
                if ($existing -and $existing.LinkType) {
                    throw "$($policy.Path) is a symbolic link."
                }

                if ($existing -and (Get-Content -LiteralPath $policy.Path -Raw -ErrorAction Stop) -ceq $policy.Content) {
                    $result
                    continue
                }

                if (-not $PSCmdlet.ShouldProcess($policy.Path, 'Write core dump policy')) {
                    $result.Status = 'Preview'
                    $result
                    continue
                }

                [void][System.IO.Directory]::CreateDirectory((Split-Path -Path $policy.Path -Parent))
                Set-Content -LiteralPath $policy.Path -Value $policy.Content -NoNewline -ErrorAction Stop

                if ((Get-Content -LiteralPath $policy.Path -Raw -ErrorAction Stop) -cne $policy.Content) {
                    throw "$($policy.Path) did not match the policy after writing."
                }

                # The CIS remediation reloads systemd after changing the coredump drop-in.
                if ($policy.Reload) {
                    systemctl daemon-reload
                    if ($LASTEXITCODE -ne 0) { throw 'systemctl daemon-reload failed.' }
                }

                $result.Status = 'Hardened'
                $result
            }
            catch {
                $result.Status = 'Failed'
                $result
                Write-Error -ErrorRecord $_
            }
        }
    }
}
