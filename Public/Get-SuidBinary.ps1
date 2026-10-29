#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsLinux) {
    function Get-SuidBinary {
        <#
        .SYNOPSIS
            Finds SUID and SGID files on Linux.

        .DESCRIPTION
            Runs find with -xdev under each path and returns one object per regular file
            whose SUID or SGID bit is set. find uses only POSIX predicates plus -print0, so
            GNU findutils and BusyBox both work. Owner, group, and mode come from
            PowerShell's own stat data, with no other external tool. Records are
            NUL-delimited, so any filename parses intact. If find exits nonzero, its stderr
            is written as an error after the results, so a partial scan reports itself.

        .PARAMETER Path
            The root directories to scan.

        .INPUTS
            None. This function does not accept pipeline input.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. Owner, Group, Mode, and Path for each file.

        .EXAMPLE
            Get-SuidBinary -Path /usr

            Lists SUID and SGID files under /usr.

        .EXAMPLE
            Get-SuidBinary -Path '/', '/home', '/var'

            Scans the root filesystem and the separate /home and /var partitions.

        .EXAMPLE
            Invoke-Sudo { Import-Module PSSecurity; Get-SuidBinary | ConvertTo-Json } | ConvertFrom-Json

            Runs the scan as root and rehydrates the results as objects.

        .NOTES
            Requires PowerShell 7.3 or later for the UnixStat property.

            -xdev keeps find on the filesystem of each root. Separate partitions such as
            /home or /var are scanned only when passed as roots.

            An owner or group with no account name reports its numeric ID. A filename that
            is not valid UTF-8 decodes with U+FFFD replacement characters, so PowerShell
            cannot reopen it: the finding is still reported with that path and empty Owner,
            Group, and Mode, plus a warning.
        #>
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            [Parameter(HelpMessage = 'Enter the root directories to scan.')]
            [ValidateNotNullOrEmpty()]
            [string[]]$Path = '/'
        )

        # Resolve every root to an absolute path that starts with '/'. find reads any
        # argument that starts with '-' as an expression, so a root like '-delete' would
        # become an action running as root.
        $roots = @(foreach ($root in $Path) { (Resolve-Path -LiteralPath $root -ErrorAction Stop).ProviderPath })

        # -perm -4000 matches the SUID bit and -perm -2000 the SGID bit. The POSIX
        # '-perm -mode' form is used instead of GNU's '-perm /6000' so BusyBox find works.
        # -type f skips symlinks, whose mode says nothing about the target.
        # -print0 ends each path with NUL. Filenames can contain newlines but never NUL,
        # so a binary named with a newline cannot split a record or hide from the parse.
        $arguments = $roots + @('-xdev', '-type', 'f', '(', '-perm', '-4000', '-o', '-perm', '-2000', ')', '-print0')

        # Start find through Process instead of calling it as a native command. PowerShell
        # splits native output on newlines, which would undo the NUL delimiter. ArgumentList
        # passes each argument to find unchanged, with no shell quoting.
        $startInfo = [System.Diagnostics.ProcessStartInfo]::new('find')
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        foreach ($argument in $arguments) {
            $startInfo.ArgumentList.Add($argument)
        }

        $process = [System.Diagnostics.Process]::Start($startInfo)
        try {
            # Read stderr asynchronously while stdout is read. Reading both pipes one after
            # the other deadlocks once find fills the stderr buffer, such as a non-root scan
            # that hits thousands of permission denials.
            $stderrTask = $process.StandardError.ReadToEndAsync()
            $stdout = $process.StandardOutput.ReadToEnd()
            $process.WaitForExit()

            foreach ($foundPath in $stdout.Split([char]0, [System.StringSplitOptions]::RemoveEmptyEntries)) {
                $finding = [pscustomobject]@{ Owner = $null; Group = $null; Mode = $null; Path = $foundPath }

                # UnixStat is PowerShell's own lstat data, so owner and mode need no stat
                # binary. User and Group are empty when the ID has no account, which is
                # itself worth review, so the numeric ID is reported instead.
                $item = Get-Item -LiteralPath $foundPath -Force -ErrorAction SilentlyContinue
                if ($item) {
                    $finding.Owner = if ($item.User) { $item.User } else { [string]$item.UnixStat.UserId }
                    $finding.Group = if ($item.Group) { $item.Group } else { [string]$item.UnixStat.GroupId }

                    # 4095 is octal 7777: the permission bits plus SUID, SGID, and sticky,
                    # without the file type bits.
                    $finding.Mode = [Convert]::ToString($item.UnixStat.Mode -band 4095, 8)
                }
                else {
                    Write-Warning -Message "Could not read the owner and mode of $foundPath."
                }

                $finding
            }

            # A nonzero exit means find could not read part of the tree, so the results
            # above are a partial scan. The error comes after the results: callers using
            # -ErrorAction Stop fail hard, and other callers keep the data and see why it
            # is incomplete.
            if ($process.ExitCode -ne 0) {
                Write-Error -Message "find exited with code $($process.ExitCode); the scan is incomplete.`n$($stderrTask.Result)"
            }
        }
        finally {
            $process.Dispose()
        }
    }
}
