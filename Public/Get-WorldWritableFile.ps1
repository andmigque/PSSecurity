#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsLinux) {
    function Get-WorldWritableFile {
        <#
        .SYNOPSIS
            Finds world-writable files on Linux.

        .DESCRIPTION
            Walks each path and returns one report listing every file that any account can
            write. With -IncludeDirectories, the report also lists world-writable directories
            that lack the sticky bit. The walk stays on the filesystem of each root, skips
            symlinks, and uses no external tools. Directories that cannot be read land in
            Errors, so a partial scan reports itself. -Verbose writes the mode, owner, and
            group of each finding.

        .PARAMETER Path
            The root directories to scan.

        .PARAMETER IncludeDirectories
            Also checks directories and lists the world-writable ones without the sticky bit.

        .INPUTS
            None. This function does not accept pipeline input.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. One object with these properties:

            Path   [string[]] The roots that were scanned.
            Count  [int]      The number of entries checked: every file, plus every
                              directory under -IncludeDirectories.
            Found  [string[]] The world-writable entries.
            Errors [object[]] One Path and Message per directory that could not be read.

        .EXAMPLE
            Invoke-Sudo { Import-Module PSSecurity; Get-WorldWritableFile | ConvertTo-Json } | ConvertFrom-Json

            Scans the root filesystem as root. Invoke-Sudo returns text, so the report goes
            through JSON to come back as an object.

        .EXAMPLE
            (Invoke-Sudo { Import-Module PSSecurity;
            Get-WorldWritableFile -Path '/', '/home', '/var' -IncludeDirectories | ConvertTo-Json } | ConvertFrom-Json).Found

            Lists world-writable files and non-sticky world-writable directories on the root
            filesystem and the separate /home and /var partitions.

        .EXAMPLE
            Invoke-Sudo { Import-Module PSSecurity; Get-WorldWritableFile -Path /etc -Verbose }

            Prints the report and the mode, owner, and group of each finding as text.

        .NOTES
            Requires PowerShell 7.3 or later for the UnixStat property. Run as root: a
            non-root scan cannot read root-only directories, so they land in Errors.

            The walk does not descend into mount points listed in /proc/self/mounts, the
            same as find -xdev. Separate partitions such as /home or /var are scanned only
            when passed as roots. Pseudo filesystems such as /proc and tmpfs mounts such as
            /tmp are mount points, so the walk skips them. Bind mounts are skipped as well.

            Files include every non-directory entry, so a world-writable socket or FIFO is
            listed along with regular files.
        #>
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            [Parameter(HelpMessage = 'Enter the root directories to scan.')]
            [ValidateNotNullOrEmpty()]
            [string[]]$Path = '/',

            [Parameter(HelpMessage = 'Also list world-writable directories without the sticky bit.')]
            [switch]$IncludeDirectories
        )

        $otherWrite = [System.IO.UnixFileMode]::OtherWrite
        $stickyBit = [System.IO.UnixFileMode]::StickyBit

        $roots = [System.Collections.Generic.List[string]]::new()
        $found = [System.Collections.Generic.List[string]]::new()
        $errors = [System.Collections.Generic.List[object]]::new()
        $count = 0

        # Writes one verbose line per finding. Objects from .NET enumeration have no
        # UnixStat, so the finding is read again through Get-Item, which costs one call
        # per finding instead of one per entry. User and Group are empty when the ID has
        # no account, so the numeric ID stands in.
        $writeFinding = {
            param([System.IO.FileSystemInfo]$Entry)
            $item = Get-Item -LiteralPath $Entry.FullName -Force
            $owner = if ($item.User) { $item.User } else { $item.UnixStat.UserId }
            $group = if ($item.Group) { $item.Group } else { $item.UnixStat.GroupId }
            Write-Verbose -Message ('{0} {1}:{2} {3}' -f [Convert]::ToString([int]$Entry.UnixFileMode, 8), $owner, $group, $Entry.FullName)
        }

        # Every mount point on the host, read from the kernel's own mount table. A
        # directory in this set is the root of another filesystem, so the walk does not
        # descend into it, the same as find -xdev. The kernel writes space, tab, newline,
        # and backslash in mount paths as octal escapes, which are decoded here.
        # Checking the set costs nothing per directory; reading each directory's device
        # ID instead would take one Get-Item call per directory, about 15 times slower.
        # A bind mount is a mount point too, so the walk skips it even when it repeats
        # the root's filesystem.
        $mountPoints = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        foreach ($mountLine in Get-Content -LiteralPath '/proc/self/mounts' -ErrorAction Stop) {
            $mountPoint = ($mountLine -split ' ')[1]
            $mountPoint = $mountPoint.Replace('\040', ' ').Replace('\011', "`t").Replace('\012', "`n").Replace('\134', '\')
            [void]$mountPoints.Add($mountPoint)
        }

        foreach ($root in $Path) {
            $rootDirectory = Get-Item -LiteralPath $root -Force -ErrorAction Stop
            if (-not $rootDirectory.PSIsContainer) {
                throw "$root is not a directory."
            }

            $roots.Add($rootDirectory.FullName)

            # The root goes on the stack even when it is a mount point, so a separate
            # partition is scanned by passing it as a root.
            $directories = [System.Collections.Generic.Stack[System.IO.DirectoryInfo]]::new()
            $directories.Push([System.IO.DirectoryInfo]::new($rootDirectory.FullName))

            while ($directories.Count -gt 0) {
                $directory = $directories.Pop()

                # A world-writable directory with the sticky bit is the /tmp convention:
                # anyone can create files, and only the owner can delete or rename them.
                # Without the sticky bit, any account can delete or replace another
                # account's files.
                if ($IncludeDirectories) {
                    $count++
                    $directoryMode = $directory.UnixFileMode
                    if (($directoryMode -band $otherWrite) -and -not ($directoryMode -band $stickyBit)) {
                        $found.Add($directory.FullName)
                        & $writeFinding $directory
                    }
                }

                try {
                    foreach ($entry in $directory.EnumerateFileSystemInfos()) {
                        # A symlink's own mode is always 777 and says nothing about its
                        # target, and following it could leave the root's filesystem.
                        if ($entry.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                            continue
                        }

                        if ($entry -is [System.IO.DirectoryInfo]) {
                            if ($mountPoints.Contains($entry.FullName)) {
                                Write-Verbose -Message "Skipping other filesystem: $($entry.FullName)"
                            }
                            else {
                                $directories.Push($entry)
                            }

                            continue
                        }

                        # UnixFileMode comes from the metadata the enumeration already read,
                        # so checking a file costs no extra system call.
                        $count++
                        if ($entry.UnixFileMode -band $otherWrite) {
                            $found.Add($entry.FullName)
                            & $writeFinding $entry
                        }
                    }
                }
                catch {
                    # GetBaseException unwraps PowerShell's 'Exception calling ...' wrapper
                    # down to the .NET message, such as 'Access to the path ... is denied.'
                    $errors.Add([pscustomobject]@{ Path = $directory.FullName; Message = $_.Exception.GetBaseException().Message })
                }
            }
        }

        [pscustomobject]@{
            Path   = $roots.ToArray()
            Count  = $count
            Found  = $found.ToArray()
            Errors = $errors.ToArray()
        }
    }
}
