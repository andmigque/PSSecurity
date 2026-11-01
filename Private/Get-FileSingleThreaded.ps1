#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Get-FileSingleThreaded {
    <#
    .SYNOPSIS
        Returns the files in a directory that match a name pattern, on one thread.

    .DESCRIPTION
        The single-threaded recursive search behind Get-FileMultiThreaded. Lists the
        files in -Directory and, with -Recurse, every directory below it, using .NET
        enumeration and a stack instead of Get-ChildItem or recursive function calls.

        Directories whose name is in -Exclude are skipped entirely, so their contents
        are never read. Directories that cannot be read are skipped instead of stopping
        the recursion. Symbolic links and junctions are not followed. Hidden and system
        items are included. Name matching is case insensitive on every platform.

        This function runs inside Invoke-ParallelJob workers, so it must not call
        other functions from this module.

    .PARAMETER Directory
        The directory to list. Accepts directories from the pipeline.

    .PARAMETER Include
        File name patterns to return, such as *.ps1. A file is returned when its name
        matches any pattern.

    .PARAMETER Exclude
        Directory names to skip, such as .git or node_modules. Matched against the
        directory name only, not its path.

    .PARAMETER Recurse
        Also lists every directory below -Directory. Without it, only the files
        directly in -Directory are returned.

    .INPUTS
        System.IO.DirectoryInfo. You can pipe directories to this function.

    .OUTPUTS
        System.IO.FileInfo. One object for each matching file.

    .EXAMPLE
        Get-FileSingleThreaded -Directory $HOME/Develop -Include '*.ps1' -Exclude '.git' -Recurse

        Returns every PowerShell script under ~/Develop, skipping .git directories.

    .EXAMPLE
        Get-FileSingleThreaded -Directory /etc -Include '*.conf' -Exclude @()

        Returns the .conf files directly in /etc, without reading subdirectories.
    #>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(Mandatory, ValueFromPipeline,
            HelpMessage = 'Enter the directory to list. Accepts directories from the pipeline.')]
        [System.IO.DirectoryInfo]$Directory,

        [Parameter(Mandatory, HelpMessage = 'Enter the file name patterns to return, such as *.ps1.')]
        [string[]]$Include,

        [Parameter(Mandatory, HelpMessage = 'Enter the directory names to skip, such as .git.')]
        [AllowEmptyCollection()]
        [string[]]$Exclude,

        [Parameter(HelpMessage = 'Also list every directory below the directory.')]
        [switch]$Recurse
    )
    begin {
        # Setting AttributesToSkip replaces the default of Hidden and System, so only
        # links are skipped. IgnoreInaccessible skips unreadable directories.
        $enumerationOptions = [System.IO.EnumerationOptions]@{
            IgnoreInaccessible    = $true
            RecurseSubdirectories = $false
            AttributesToSkip      = [System.IO.FileAttributes]::ReparsePoint
        }
        $pending = [System.Collections.Generic.Stack[System.IO.DirectoryInfo]]::new()
    }
    process {
        $pending.Push($Directory)

        while ($pending.Count -gt 0) {
            $current = $pending.Pop()

            if ($Recurse) {
                foreach ($subDirectory in $current.EnumerateDirectories('*', $enumerationOptions)) {
                    if ($subDirectory.Name -notin $Exclude) {
                        $pending.Push($subDirectory)
                    }
                }
            }

            foreach ($file in $current.EnumerateFiles('*', $enumerationOptions)) {
                foreach ($pattern in $Include) {
                    if ($file.Name -like $pattern) {
                        $file
                        break
                    }
                }
            }
        }
    }
}
