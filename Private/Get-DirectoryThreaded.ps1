#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Get-DirectoryThreaded {
    <#
    .SYNOPSIS
        Recursively returns the directories under a directory, on one thread or in
        parallel.

    .DESCRIPTION
        Recurses -Directory with .NET enumeration and a stack, and returns every
        directory below it. -Directory itself is not returned.

        With -Parallel, returns each directory directly in -Directory, then recurses
        into each of them on its own worker, -ThrottleLimit directories at a time,
        using Invoke-ParallelJob. Starting workers costs time, so use -Parallel for
        large trees, such as /, and leave it off for small ones.

        Directories whose name is in -Exclude are skipped entirely: they are not
        returned and their contents are never read. Directories that cannot be read
        are skipped instead of stopping the recursion. Symbolic links and junctions are
        not followed. Hidden and system directories are included.

        With -Parallel, directories are returned as workers find them, not in tree
        order.

    .PARAMETER Directory
        The directory to recurse. Accepts directories from the pipeline.

    .PARAMETER Exclude
        Directory names to skip, such as proc or .git. Matched against the directory
        name only, not its path. Defaults to none.

    .PARAMETER Parallel
        Recurses the subdirectories of -Directory in parallel thread jobs.

    .PARAMETER ThrottleLimit
        With -Parallel, the number of subdirectories recursed at once, from 1 through
        255. Defaults to 75% of the processors, rounded down, and at least 1.

    .INPUTS
        System.IO.DirectoryInfo. You can pipe directories to this function.

    .OUTPUTS
        System.IO.DirectoryInfo. One object for each directory.

    .EXAMPLE
        Get-DirectoryThreaded -Directory $HOME/Develop/PSSecurity -Exclude '.git'

        Returns the directories in the repository on one thread, skipping .git.

    .EXAMPLE
        Get-DirectoryThreaded -Directory / -Exclude 'proc', 'sys', 'dev' -Parallel

        Returns every directory on the system in parallel, skipping the proc, sys, and
        dev pseudo filesystems.

    .EXAMPLE
        Get-Item -LiteralPath $HOME/Develop | Get-DirectoryThreaded -Exclude 'node_modules' -Parallel -ThrottleLimit 2

        Returns the directories under ~/Develop, two subdirectories at a time.
    #>
    [CmdletBinding()]
    [OutputType([System.IO.DirectoryInfo])]
    param(
        [Parameter(Mandatory, ValueFromPipeline,
            HelpMessage = 'Enter the directory to recurse. Accepts directories from the pipeline.')]
        [System.IO.DirectoryInfo]$Directory,

        [Parameter(HelpMessage = 'Enter the directory names to skip, such as proc.')]
        [string[]]$Exclude = @(),

        [Parameter(HelpMessage = 'Recurse the subdirectories in parallel thread jobs.')]
        [switch]$Parallel,

        [Parameter(HelpMessage = 'Enter the maximum number of workers (1-255).')]
        [ValidateRange(1, 255)]
        [int]$ThrottleLimit
    )
    begin {
        if (-not $PSBoundParameters.ContainsKey('ThrottleLimit')) {
            $ThrottleLimit = Get-DefaultThrottleLimit
        }

        # Setting AttributesToSkip replaces the default of Hidden and System, so only
        # links are skipped. IgnoreInaccessible skips unreadable directories.
        $enumerationOptions = [System.IO.EnumerationOptions]@{
            IgnoreInaccessible = $true
            AttributesToSkip   = [System.IO.FileAttributes]::ReparsePoint
        }

        # Runs here on one thread, and inside workers with -Parallel, so it must not
        # call this module's functions.
        $recurseDirectory = {
            param($Exclude, $EnumerationOptions)
            begin {
                $pending = [System.Collections.Generic.Stack[System.IO.DirectoryInfo]]::new()
            }
            process {
                $pending.Push($_)
                while ($pending.Count -gt 0) {
                    foreach ($subDirectory in $pending.Pop().EnumerateDirectories('*', $EnumerationOptions)) {
                        if ($subDirectory.Name -notin $Exclude) {
                            $subDirectory
                            $pending.Push($subDirectory)
                        }
                    }
                }
            }
        }
    }
    process {
        if ($Parallel) {
            $topDirectories = @(
                $Directory.EnumerateDirectories('*', $enumerationOptions) |
                    Where-Object -Property Name -NotIn $Exclude
            )
            foreach ($topDirectory in $topDirectories) {
                $topDirectory
            }

            $parallelParams = @{
                ThrottleLimit = $ThrottleLimit
                ArgumentList  = $Exclude, $enumerationOptions
                ScriptBlock   = $recurseDirectory
            }
            $topDirectories | Invoke-ParallelJob @parallelParams
        }
        else {
            $Directory | & $recurseDirectory $Exclude $enumerationOptions
        }
    }
}
