#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsLinux) {
    function Deploy-LinuxConfiguration {
        <#
        .SYNOPSIS
            Copies the PSSecurity Linux hardening files from Config/Linux into place.

        .DESCRIPTION
            Config/Linux mirrors the root of the file system, so each file is copied to the
            same path under /. For example, Config/Linux/etc/sysctl.d/99-pssecurity-hardening.conf
            is copied to /etc/sysctl.d/99-pssecurity-hardening.conf. Missing directories are
            created. Every copied file gets mode 0644, whatever the mode of its source. A file
            whose destination already has the same content and mode 0644 is skipped, so a
            run also repairs the mode of files deployed earlier.

            The files are drop-ins in standard locations: kernel parameters in sysctl.d,
            the kernel module blacklist in modprobe.d, and the core dump policy in
            security/limits.d and systemd/coredump.conf.d. Edit the files in Config/Linux to
            change the policy.

            After a sysctl.d file is copied, runs sysctl --system to apply it without a
            reboot. Keys the running kernel does not support, common in containers and WSL,
            are reported as a warning; the file is still deployed and applies at boot on
            kernels that support them.

            Requires root. Supports -WhatIf and -Confirm. Linux only.

        .PARAMETER Name
            File names to deploy, such as 99-pssecurity-hardening.conf. Wildcards are
            accepted. Defaults to every file in Config/Linux.

        .PARAMETER PassThru
            Returns each file that was copied.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.IO.FileInfo. With -PassThru, one object per copied file. Otherwise
            nothing.

        .EXAMPLE
            Deploy-LinuxConfiguration -WhatIf

            Lists the files that would be copied and where.

        .EXAMPLE
            Invoke-Sudo { Import-Module ./PSSecurity.psd1; Deploy-LinuxConfiguration -PassThru }

            Deploys every file as root and lists the files that were copied.

        .EXAMPLE
            Deploy-LinuxConfiguration -Name '99-pssecurity-hardening.conf', '99-pssecurity-core.conf'

            Deploys only the kernel parameters and the core dump policy, leaving the kernel
            module blacklist out.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([System.IO.FileInfo])]
        param(
            [Parameter(HelpMessage = 'Enter the file names to deploy. Wildcards are accepted.')]
            [ValidateNotNullOrEmpty()]
            [string[]]$Name = '*',

            [Parameter(HelpMessage = 'Return each file that was copied.')]
            [switch]$PassThru
        )

        $configRoot = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Config' -AdditionalChildPath 'Linux'
        $sysctlChanged = $false

        # 0644. Copy-Item keeps the source mode, and /mnt/c shows every Windows file as
        # 0777, which would leave world-writable files in /etc.
        $fileMode = [System.IO.UnixFileMode]'UserRead, UserWrite, GroupRead, OtherRead'

        foreach ($source in Get-ChildItem -LiteralPath $configRoot -File -Recurse -Include $Name) {
            $destination = '/' + [System.IO.Path]::GetRelativePath($configRoot, $source.FullName)

            $upToDate = $false
            if (Test-Path -LiteralPath $destination) {
                $sameContent = (Get-FileHash -LiteralPath $destination).Hash -eq (Get-FileHash -LiteralPath $source.FullName).Hash
                $upToDate = $sameContent -and (Get-Item -LiteralPath $destination).UnixFileMode -eq $fileMode
            }
            if ($upToDate) {
                Write-Verbose -Message "$destination is already up to date."
                continue
            }

            if ($PSCmdlet.ShouldProcess($destination, "Copy from $($source.FullName) with mode 0644")) {
                [void](New-Item -ItemType Directory -Path (Split-Path -Path $destination -Parent) -Force -ErrorAction Stop)
                Copy-Item -LiteralPath $source.FullName -Destination $destination -Force -ErrorAction Stop
                [System.IO.File]::SetUnixFileMode($destination, $fileMode)

                if ($destination -like '/etc/sysctl.d/*') {
                    $sysctlChanged = $true
                }
                if ($PassThru) {
                    Get-Item -LiteralPath $destination
                }
            }
        }

        if ($sysctlChanged) {
            $sysctlOutput = (sysctl --system 2>&1)
            if ($LASTEXITCODE -ne 0) {
                $failures = @($sysctlOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] })
                Write-Warning -Message "sysctl --system could not apply every key: $($failures -join '; ')"
            }
        }
    }
}
