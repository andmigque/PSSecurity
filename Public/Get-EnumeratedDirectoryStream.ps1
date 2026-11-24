#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Get-EnumeratedDirectoryStream {
    <#
    .SYNOPSIS
        Streams classified child directory entries from a filesystem path.

    .DESCRIPTION
        Emits each child directory entry as it is discovered. Each result has an
        Item property containing the DirectoryInfo and an ItemType property
        identifying it as Directory, SymbolicLink, Junction, or OtherReparsePoint.

        The starting path must be an ordinary directory. The walk includes hidden
        directory entries and skips unreadable contents. With -Recurse, it descends
        only into ordinary directories. A matching exclusion skips the entry and
        its subtree.

    .PARAMETER LiteralPath
        Directory to enumerate. The path is used exactly as typed, including brackets.
        Defaults to the current location. Accepts directory paths from the pipeline.

    .PARAMETER Exclude
        Case-insensitive patterns matched against each directory name. Use * for
        any number of characters and ? for one character. Brackets are literal.

    .PARAMETER Recurse
        Searches all descendants reachable through ordinary directories.

    .INPUTS
        System.String. You can pipe directory paths to this function.

    .OUTPUTS
        PSSecurity.DirectoryEnumerator+DirectoryItem. One object per matching
        directory entry.

    .EXAMPLE
        Get-EnumeratedDirectoryStream -LiteralPath . -Recurse |
            Select-Object -First 10

        Returns the first ten directory entries and stops the walk.
    #>
    [CmdletBinding()]
    [OutputType('PSSecurity.DirectoryEnumerator+DirectoryItem')]
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

        $getLinkType = [System.Func[System.IO.DirectoryInfo, string]] {
            param([System.IO.DirectoryInfo] $item)
            $item.LinkType
        }
    }
    process {
        $directory = Get-Item -LiteralPath $LiteralPath -Force -ErrorAction Stop
        $entries = $enumerator.StreamDirectoryItems(
            $directory, $excludeSet, $getLinkType
        )
        foreach ($entry in $entries) {
            $entry
        }
    }
}
