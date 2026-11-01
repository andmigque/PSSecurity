#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Get-Tree {
    <#
    .SYNOPSIS
        Returns the directories, or with -File the files, below a path.

    .DESCRIPTION
        Recurses each path with .NET enumeration and a stack, without Get-ChildItem or
        recursive function calls. Returns every directory below the path, or every file
        with -File. The path itself is not returned.

        Directories whose name is in -Exclude are skipped entirely: they are not
        returned and their contents are never read. Directories that cannot be read
        are skipped instead of stopping the recursion. Symbolic links and junctions are
        not followed. Hidden and system items are included. Name matching is case
        insensitive on every platform.

        Runs on one thread by default. With -ThrottleLimit above 1, the items directly
        in the path are returned first, then each subdirectory is recursed by
        Enter-ThreadQueue, -ThrottleLimit subdirectories at a time. Starting workers
        costs time, so raise -ThrottleLimit for large trees, such as /, and leave it at
        1 for small ones. With more than one worker, items are returned as workers find
        them, not in tree order.

    .PARAMETER Path
        The directories to recurse. Wildcards are accepted. Accepts paths and
        directory objects from the pipeline. A path that resolves to a file throws.

    .PARAMETER File
        Returns files instead of directories.

    .PARAMETER Include
        Name patterns to return, such as *.ps1. An item is returned when its name
        matches any pattern. Defaults to every name.

    .PARAMETER Exclude
        Directory names to skip, such as .git or proc. Matched against the directory
        name only, not its path. Defaults to none.

    .PARAMETER ThrottleLimit
        The number of subdirectories recursed at once, from 1 through 255. Defaults to
        1, one thread.

    .INPUTS
        System.String. You can pipe paths, or directory objects by their FullName, to
        this function.

    .OUTPUTS
        System.IO.DirectoryInfo, or System.IO.FileInfo with -File. One object for each
        item.

    .EXAMPLE
        Get-Tree -Path . -Exclude '.git'

        Returns the directories below the current directory, skipping .git.

    .EXAMPLE
        Get-Tree -Path $HOME/Develop -File -Include '*.ps1', '*.psm1' -Exclude '.git', 'node_modules'

        Returns every PowerShell script under ~/Develop.

    .EXAMPLE
        Get-Tree -Path / -File -Exclude 'proc', 'sys', 'dev' -ThrottleLimit 8

        Returns every file on the system, recursing eight subdirectories at a time.

    .EXAMPLE
        Get-Tree -Path . -File -ThrottleLimit 4 |
            Enter-ThreadQueue -ThrottleLimit 4 { process { Get-AclItem -LiteralPath $_.FullName } } |
            Measure-OwnerAnomaly -Identity 'BUILTIN\Administrators'

        Reads the owner of every file below the current directory on four threads, then
        counts the files that Administrators does not own.
    #>
    [CmdletBinding()]
    [OutputType([System.IO.DirectoryInfo], [System.IO.FileInfo])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName,
            HelpMessage = 'Enter the directories to recurse. Wildcards are accepted.')]
        [Alias('PSPath', 'FullName')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        [Parameter(HelpMessage = 'Return files instead of directories.')]
        [switch]$File,

        [Parameter(HelpMessage = 'Enter the name patterns to return, such as *.ps1.')]
        [string[]]$Include = @('*'),

        [Parameter(HelpMessage = 'Enter the directory names to skip, such as .git.')]
        [string[]]$Exclude = @(),

        [Parameter(HelpMessage = 'Enter the number of subdirectories to recurse at once (1-255).')]
        [ValidateRange(1, 255)]
        [int]$ThrottleLimit = 1
    )
    begin {
        # Setting AttributesToSkip replaces the default of Hidden and System, so only
        # links are skipped. IgnoreInaccessible skips unreadable directories.
        $enumerationOptions = [System.IO.EnumerationOptions]@{
            IgnoreInaccessible = $true
            AttributesToSkip   = [System.IO.FileAttributes]::ReparsePoint
        }

        # Returns what is below each piped directory, not the directory itself. Runs
        # here on one thread and inside Enter-ThreadQueue workers, so it must not call
        # this module's functions.
        $walkTree = {
            param($File, $Include, $Exclude, $EnumerationOptions)
            begin {
                $pending = [System.Collections.Generic.Stack[System.IO.DirectoryInfo]]::new()
            }
            process {
                $pending.Push($_)
                while ($pending.Count -gt 0) {
                    $current = $pending.Pop()

                    foreach ($subDirectory in $current.EnumerateDirectories('*', $EnumerationOptions)) {
                        if ($subDirectory.Name -in $Exclude) {
                            continue
                        }
                        $pending.Push($subDirectory)
                        if (-not $File) {
                            foreach ($pattern in $Include) {
                                if ($subDirectory.Name -like $pattern) {
                                    $subDirectory
                                    break
                                }
                            }
                        }
                    }

                    if ($File) {
                        foreach ($fileInfo in $current.EnumerateFiles('*', $EnumerationOptions)) {
                            foreach ($pattern in $Include) {
                                if ($fileInfo.Name -like $pattern) {
                                    $fileInfo
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        $walkArguments = [bool]$File, $Include, $Exclude, $enumerationOptions
    }
    process {
        # -Path can name several directories, and each wildcard can match several.
        foreach ($resolvedPath in (Resolve-Path -Path $Path -ErrorAction Stop).ProviderPath) {
            if (-not [System.IO.Directory]::Exists($resolvedPath)) {
                throw "Get-Tree: '$resolvedPath' is not a directory."
            }
            $root = [System.IO.DirectoryInfo]::new($resolvedPath)

            if ($ThrottleLimit -eq 1) {
                $root | & $walkTree @walkArguments
                continue
            }

            # The top level is listed here; each subdirectory below it gets a worker.
            $topDirectories = @(
                $root.EnumerateDirectories('*', $enumerationOptions) |
                    Where-Object -Property Name -NotIn $Exclude
            )
            if ($File) {
                foreach ($fileInfo in $root.EnumerateFiles('*', $enumerationOptions)) {
                    if ($Include.Where({ $fileInfo.Name -like $_ }, 'First')) {
                        $fileInfo
                    }
                }
            }
            else {
                $topDirectories.Where({ $directory = $_; $Include.Where({ $directory.Name -like $_ }, 'First') })
            }

            $queueParams = @{
                ThrottleLimit = $ThrottleLimit
                ArgumentList  = $walkArguments
                ScriptBlock   = $walkTree
            }
            $topDirectories | Enter-ThreadQueue @queueParams
        }
    }
}
