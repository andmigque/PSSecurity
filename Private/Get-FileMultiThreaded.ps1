#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Get-FileMultiThreaded {
    <#
    .SYNOPSIS
        Recursively returns the files under a directory that match a name pattern,
        walking its subdirectories in parallel.

    .DESCRIPTION
        Lists the files directly in -Directory, then walks each of its subdirectories
        recursively with Get-FileSingleThreaded, -ThrottleLimit subdirectories at a
        time, using Invoke-ParallelJob.

        Directories whose name is in -Exclude are skipped entirely, so their contents
        are never read. Directories that cannot be read are skipped instead of stopping
        the walk. Symbolic links and junctions are not followed. Hidden and system
        items are included. Name matching is case insensitive on every platform.

        Files are returned as workers find them, not in directory order.

    .PARAMETER Directory
        The directory to walk. Accepts directories from the pipeline.

    .PARAMETER Include
        File name patterns to return, such as *.ps1. A file is returned when its name
        matches any pattern.

    .PARAMETER Exclude
        Directory names to skip, such as .git or node_modules. Matched against the
        directory name only, not its path.

    .PARAMETER ThrottleLimit
        The number of subdirectories walked at once, from 1 through 255. Defaults to
        75% of the processors, rounded down, and at least 1.

    .INPUTS
        System.IO.DirectoryInfo. You can pipe directories to this function.

    .OUTPUTS
        System.IO.FileInfo. One object for each matching file.

    .EXAMPLE
        Get-FileMultiThreaded -Directory $HOME/Develop -Include '*.ps1', '*.psm1' -Exclude '.git', 'node_modules'

        Returns every PowerShell script under ~/Develop, skipping .git and node_modules.

    .EXAMPLE
        Get-Item -LiteralPath /etc | Get-FileMultiThreaded -Include '*.conf' -Exclude 'ssl' -ThrottleLimit 2

        Returns the .conf files under /etc, two subdirectories at a time, skipping any
        directory named ssl and any directory the current user cannot read.
    #>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(Mandatory, ValueFromPipeline,
            HelpMessage = 'Enter the directory to walk. Accepts directories from the pipeline.')]
        [System.IO.DirectoryInfo]$Directory,

        [Parameter(Mandatory, HelpMessage = 'Enter the file name patterns to return, such as *.ps1.')]
        [string[]]$Include,

        [Parameter(Mandatory, HelpMessage = 'Enter the directory names to skip, such as .git.')]
        [AllowEmptyCollection()]
        [string[]]$Exclude,

        [Parameter(HelpMessage = 'Enter the maximum number of workers (1-255).')]
        [ValidateRange(1, 255)]
        [int]$ThrottleLimit
    )
    begin {
        if (-not $PSBoundParameters.ContainsKey('ThrottleLimit')) {
            $ThrottleLimit = Get-DefaultThrottleLimit
        }

        $enumerationOptions = [System.IO.EnumerationOptions]@{
            IgnoreInaccessible = $true
            AttributesToSkip   = [System.IO.FileAttributes]::ReparsePoint
        }

        # Workers cannot call this module's functions, so each one builds
        # Get-FileSingleThreaded from its text once, in begin.
        $parallelParams = @{
            ThrottleLimit = $ThrottleLimit
            ArgumentList  = (Get-Command -Name Get-FileSingleThreaded).ScriptBlock.ToString(), $Include, $Exclude
            ScriptBlock   = {
                param($WalkerText, $Include, $Exclude)
                begin { $walk = [scriptblock]::Create($WalkerText) }
                process { & $walk -Directory $_ -Include $Include -Exclude $Exclude -Recurse }
            }
        }
    }
    process {
        Get-FileSingleThreaded -Directory $Directory -Include $Include -Exclude $Exclude

        $Directory.EnumerateDirectories('*', $enumerationOptions) |
            Where-Object -Property Name -NotIn $Exclude |
            Invoke-ParallelJob @parallelParams
    }
}
