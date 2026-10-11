if ($IsLinux) {
    Set-StrictMode -Version Latest
    function Set-HomeDirectoryPermission {
        <#
    .SYNOPSIS
        Restricts permissions on user home directories and the root account home.

    .DESCRIPTION
        Applies the requested octal mode to every immediate subdirectory of /home (default 750)
        and to /root (default 700). Only the top-level directory mode changes; files inside each
        home keep their current modes, so per-user settings such as .ssh stay untouched. Ownership
        is never modified. Directories already at the target mode are reported as compliant and
        skipped without invoking chmod. Symlinks are skipped so a mode change cannot escape the
        home root through a link. When the session is not root, chmod runs through sudo.

    .PARAMETER Mode
        Octal mode for /home subdirectories, such as 750 or 0750.

    .PARAMETER RootMode
        Octal mode for /root. The default is 700.

    .PARAMETER HomePath
        Parent directory of user home directories. The default is /home.

    .PARAMETER Exclude
        Home directory names to skip. Wildcards are allowed, for example shared*.

    .EXAMPLE
        Set-HomeDirectoryPermission -WhatIf

        Previews the mode change for every /home subdirectory and /root without applying it.

    .EXAMPLE
        Set-HomeDirectoryPermission -Mode 750 -Exclude @('shared*')

        Applies 750 to every /home subdirectory except those matching shared*, and 700 to /root.
        Returns a before and after report for each directory.

    .NOTES
        Runs on Linux only; in WSL, run it inside the target distribution. A non-root session
        needs sudo rights for directories outside the caller's ownership.
    #>
        [CmdletBinding(SupportsShouldProcess)]
        param (
            [Parameter(HelpMessage = 'Enter the octal mode for /home subdirectories, such as 750.')]
            [ValidatePattern('^[0-7]{3,4}$', ErrorMessage = 'Mode must be an octal value such as 750 or 0750.')]
            [string]$Mode = '750',

            [Parameter(HelpMessage = 'Enter the octal mode for /root, such as 700.')]
            [ValidatePattern('^[0-7]{3,4}$', ErrorMessage = 'RootMode must be an octal value such as 700 or 0700.')]
            [string]$RootMode = '700',

            [Parameter(HelpMessage = 'Enter the parent directory of user home directories.')]
            [ValidateNotNullOrEmpty()]
            [string]$HomePath = '/home',

            [Parameter(HelpMessage = 'Enter home directory names to skip. Wildcards are allowed.')]
            [string[]]$Exclude
        )

        $targetHomeMode = $Mode
        $targetRootMode = $RootMode

        if ($targetHomeMode.Length -eq 4 -and $targetHomeMode.StartsWith('0')) {
            $targetHomeMode = $targetHomeMode.Substring(1)
        }

        if ($targetRootMode.Length -eq 4 -and $targetRootMode.StartsWith('0')) {
            $targetRootMode = $targetRootMode.Substring(1)
        }

        $sessionIsRoot = (& id -u) -eq 0

        $targets = [System.Collections.Generic.List[PSCustomObject]]::new()

        if (Test-Path -LiteralPath $HomePath -PathType Container) {
            $homeDirectories = Get-ChildItem -LiteralPath $HomePath -Directory | Where-Object -FilterScript { $null -eq $_.LinkType }

            if (-not $homeDirectories) {
                Write-Verbose -Message "No home directories found under $HomePath."
            }

            foreach ($homeDirectory in $homeDirectories) {
                $isExcluded = $false

                foreach ($pattern in $Exclude) {
                    if ($homeDirectory.Name -like $pattern) {
                        $isExcluded = $true
                        break
                    }
                }

                if ($isExcluded) {
                    Write-Verbose -Message "Skipping excluded home directory: $($homeDirectory.FullName)"
                }
                else {
                    $homeTarget = [PSCustomObject]@{
                        Path = $homeDirectory.FullName
                        Mode = $targetHomeMode
                    }

                    $targets.Add($homeTarget)
                }
            }
        }
        else {
            Write-Warning -Message "Home path not found: $HomePath"
        }

        if (Test-Path -LiteralPath '/root' -PathType Container) {
            $rootTarget = [PSCustomObject]@{
                Path = '/root'
                Mode = $targetRootMode
            }

            $targets.Add($rootTarget)
        }
        else {
            Write-Warning -Message 'Root home not found: /root'
        }

        foreach ($target in $targets) {
            $beforeMode = & stat -c '%a' -- $target.Path

            if ($LASTEXITCODE -ne 0) {
                Write-Error -Message "Could not read the current mode of $($target.Path)."
                continue
            }

            if ($beforeMode -eq $target.Mode) {
                [PSCustomObject]@{
                    Path   = $target.Path
                    Before = $beforeMode
                    After  = $beforeMode
                    Status = 'Compliant'
                }
                continue
            }

            if (-not $PSCmdlet.ShouldProcess($target.Path, "Set mode to $($target.Mode)")) {
                [PSCustomObject]@{
                    Path   = $target.Path
                    Before = $beforeMode
                    After  = $target.Mode
                    Status = 'Preview'
                }
                continue
            }

            if ($sessionIsRoot) {
                & chmod $target.Mode -- $target.Path
            }
            else {
                & sudo chmod $target.Mode -- $target.Path
            }

            if ($LASTEXITCODE -ne 0) {
                Write-Error -Message "chmod failed on $($target.Path)."

                [PSCustomObject]@{
                    Path   = $target.Path
                    Before = $beforeMode
                    After  = $beforeMode
                    Status = 'Failed'
                }
                continue
            }

            $afterMode = & stat -c '%a' -- $target.Path
            $status = if ($afterMode -eq $target.Mode) { 'Hardened' } else { 'Failed' }

            [PSCustomObject]@{
                Path   = $target.Path
                Before = $beforeMode
                After  = $afterMode
                Status = $status
            }
        }
    }
}