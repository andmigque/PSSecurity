#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsLinux) {
    function Get-UnixFileMode {
        <#
        .SYNOPSIS
            Finds files or directories whose Unix mode has any of the given bits set.

        .DESCRIPTION
            Recurses the path and returns every file, or every directory with -ItemType
            Directory, whose UnixFileMode includes at least one bit of -Mode. Use it to
            find SUID and SGID binaries, world-writable files, and world-writable
            directories.

            Directories whose name is in -Exclude are skipped entirely. The defaults skip
            the proc, sys, dev, and run pseudo filesystems, and mnt, where WSL mounts the
            Windows drives with every file world-writable. Directories that cannot be read
            are skipped, so run as root for a complete scan. Symbolic links are not
            followed. The path itself is not checked, only the items below it.

            Returns the raw .NET objects, which list as a flat table of names. Select
            FullName and UnixFileMode to see the path and mode. Linux only.

        .PARAMETER Path
            The directories to search. Wildcards are accepted. Accepts paths from the
            pipeline.

        .PARAMETER Mode
            The mode bits to look for, such as SetUser, SetGroup, or OtherWrite. An item
            matches when any of the bits is set.

        .PARAMETER ItemType
            File returns files, Directory returns directories. Defaults to File.

        .PARAMETER Exclude
            Directory names to skip, matched against the name only, not the path.
            Defaults to proc, sys, dev, run, and mnt.

        .PARAMETER ThrottleLimit
            The number of subdirectories recursed at once, from 1 through 255. Defaults
            to 1, one thread. Higher values are faster on large or slow trees, slower on
            small ones.

        .INPUTS
            System.String. You can pipe directory paths to this function.

        .OUTPUTS
            System.IO.FileInfo, or System.IO.DirectoryInfo with -ItemType Directory. One
            object for each matching item.

        .EXAMPLE
            Get-UnixFileMode -Path / -Mode SetUser, SetGroup | Select-Object FullName, UnixFileMode

            Lists the SUID and SGID files on the system.

        .EXAMPLE
            Get-UnixFileMode -Path / -Mode OtherWrite -ThrottleLimit 8

            Lists the world-writable files on the system, recursing eight subdirectories
            at a time.

        .EXAMPLE
            Get-UnixFileMode -Path /home, /var -Mode OtherWrite -ItemType Directory | Select-Object FullName, UnixFileMode

            Lists the world-writable directories under /home and /var.

        .EXAMPLE
            Get-UnixFileMode -Path / -Mode OtherWrite -ItemType Directory | Add-UnixFileMode -Mode StickyBit

            Adds the sticky bit to every world-writable directory that lacks it (CIS
            1.1.21).
        #>
        [CmdletBinding()]
        [OutputType([System.IO.FileInfo], [System.IO.DirectoryInfo])]
        param(
            [Parameter(Mandatory, ValueFromPipeline,
                HelpMessage = 'Enter the directories to search. Wildcards are accepted. Accepts paths from the pipeline.')]
            [ValidateNotNullOrEmpty()]
            [string[]]$Path,

            [Parameter(Mandatory, HelpMessage = 'Enter the mode bits to look for, such as SetUser, SetGroup, or OtherWrite.')]
            [System.IO.UnixFileMode]$Mode,

            [Parameter(HelpMessage = 'Enter File to return files or Directory to return directories.')]
            [ValidateSet('File', 'Directory')]
            [string]$ItemType = 'File',

            [Parameter(HelpMessage = 'Enter the directory names to skip.')]
            [string[]]$Exclude = @('proc', 'sys', 'dev', 'run', 'mnt'),

            [Parameter(HelpMessage = 'Enter the number of subdirectories to recurse at once (1-255).')]
            [ValidateRange(1, 255)]
            [int]$ThrottleLimit = 1
        )
        process {
            $treeParams = @{
                Path          = $Path
                File          = $ItemType -eq 'File'
                Exclude       = $Exclude
                ThrottleLimit = $ThrottleLimit
            }
            Get-Tree @treeParams | Where-Object { ($_.UnixFileMode -band $Mode) -ne 0 }
        }
    }
}
