#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Get-EnumeratedDirectory {
    <#
    .SYNOPSIS
        Lists the child directories of a filesystem path.

    .DESCRIPTION
        Returns immediate child directories by default. With -Recurse, a matching
        exclusion skips the entire subtree. The walk includes hidden directories,
        skips reparse points such as symbolic links, and skips unreadable contents.

    .PARAMETER LiteralPath
        Directory to enumerate. The path is used exactly as typed, including brackets.
        Defaults to the current location. Accepts directory paths from the pipeline.

    .PARAMETER Exclude
        Case-insensitive patterns matched against each directory name. Use * for
        any number of characters and ? for one character. Brackets are literal.

    .PARAMETER Recurse
        Searches all descendants of the starting directory.

    .INPUTS
        System.String. You can pipe directory paths to this function.

    .OUTPUTS
        System.Collections.Generic.List[System.IO.DirectoryInfo]. One list per
        input path. A directory with no matching children produces an empty list.

    .NOTES
        **Restart PowerShell after changing the embedded directory enumerator type.**
        The first enumeration in the new session compiles the updated definition.

    .EXAMPLE
        Get-EnumeratedDirectory

        Lists the immediate child directories of the current location.

    .EXAMPLE
        Get-EnumeratedDirectory -LiteralPath . -Recurse -Exclude '.git', 'bin*'

        Lists descendants and skips subtrees named .git or starting with bin.

    .EXAMPLE
        './Public', './Private' | Get-EnumeratedDirectory -Recurse

        Returns a separate list of descendants for each input path.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[System.IO.DirectoryInfo]])]
    param(
        [Parameter(ValueFromPipeline, HelpMessage = 'Enter a literal directory path. Accepts paths from the pipeline.')]
        [ValidateNotNullOrWhiteSpace()]
        [string]$LiteralPath = $PWD.Path,

        [Parameter(HelpMessage = 'Enter directory name patterns to skip, such as .git or bin*.')]
        [ValidateNotNull()]
        [string[]]$Exclude = @(),

        [Parameter(HelpMessage = 'Also enumerate descendant directories.')]
        [switch]$Recurse
    )
    begin {
        Add-TypeDirectoryEnumerator
        $enumerator = [PSSecurity.DirectoryEnumerator]::new($Recurse.IsPresent)
        $excludeSet = [System.Collections.Generic.HashSet[string]]::new(
            $Exclude,
            [System.StringComparer]::OrdinalIgnoreCase
        )
    }
    process {
        $directory = Get-Item -LiteralPath $LiteralPath -Force -ErrorAction Stop
        Write-Output -NoEnumerate -InputObject ($enumerator.EnumerateItem($directory, $excludeSet))
    }
}
