Set-StrictMode -Version Latest

function Search-PatternInFile {
    <#
    .SYNOPSIS
        Searches files recursively and writes matching lines to JSON.

    .PARAMETER Directory
        Existing root directory to search recursively, including hidden files.

    .PARAMETER Pattern
        Regular expression passed to Select-String.

    .PARAMETER OutPath
        Destination directory for SearchPatternInFile.json. Created when missing; the report is overwritten.

    .PARAMETER Throttle
        Maximum parallel search workers. Defaults to 4.

    .EXAMPLE
        Search-PatternInFile -Directory C:\Data -Pattern 'error' -OutPath C:\Reports

        Writes matching file paths, lines, and values to JSON and returns a summary string. Requires PowerShell 7.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Existing root directory to search recursively, including hidden files.')]
        [ValidateNotNullOrEmpty()]
        [string]$Directory,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Regular expression passed to Select-String.')]
        [ValidateNotNullOrEmpty()]
        [string]$Pattern,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Destination directory for SearchPatternInFile.json. Created when missing; the report is overwritten.')]
        [ValidateNotNullOrEmpty()]
        [string]$OutPath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Maximum parallel search workers. Defaults to 4.')]
        [int]$Throttle = 4
    )

    # Resolve the search root before starting parallel workers.
    $resolvedDirectory = Resolve-Path -Path $Directory

    # Return one record per matching file from each worker. Files with no match
    # emit nothing, so the results are already the matched set.
    $results = @(
        Get-ChildItem -Path $resolvedDirectory -Recurse -File -ErrorAction SilentlyContinue -Force |
            ForEach-Object -Parallel {
                $pattern = $using:Pattern
                $matchInfo = @(Select-String -Path $_.FullName -Pattern $pattern -Encoding utf8 -AllMatches -ErrorAction SilentlyContinue)
                if ($matchInfo.Count -gt 0) {
                    # Select-String already emits one object per matching line, so keep
                    # that shape and project it. Member enumeration on .Matches pulls the
                    # matched text without walking it. A full MatchInfo does not belong on
                    # the wire out of the worker or in the JSON.
                    # The leading comma keeps a single match an array, so Values is
                    # never a bare string in the JSON.
                    $values = @{ Name = 'Values'; Expression = { , @($_.Matches.Value) } }
                    [PSCustomObject]@{
                        Path       = $_.FullName
                        MatchCount = @($matchInfo.Matches).Count
                        Matches    = @($matchInfo | Select-Object -Property LineNumber, Line, $values)
                    }
                }
            } -ThrottleLimit $Throttle
    )

    # Workers finish out of order, so sort by path to keep the file diffable.
    $matchedFiles = @($results | Sort-Object -Property Path)
    # Measure-Object emits nothing for an empty set, and strict mode rejects the
    # property read on the resulting null.
    $matchCount = 0
    if ($matchedFiles.Count -gt 0) {
        $matchCount = [int]($matchedFiles | Measure-Object -Property MatchCount -Sum).Sum
    }

    # Persist matches so large result sets do not depend on terminal output.
    if (-not (Test-Path -Path $OutPath)) {
        [void](New-Item -Path $OutPath -ItemType Directory -Force)
    }
    $jsonPath = Join-Path $OutPath 'SearchPatternInFile.json'
    $jsonOut = ConvertTo-Json -InputObject $matchedFiles -Depth 10
    $jsonOut | Out-File -FilePath $jsonPath -Encoding utf8

    # Use the same summary for pipeline output and the optional notification.
    $summary = "$($matchedFiles.Count) files, $matchCount matches written to $jsonPath"

    Write-Output $summary
}

