#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Search-PatternInFile {
    <#
    .SYNOPSIS
        Searches the files under a path for a regular expression.

    .DESCRIPTION
        Recurses the path, including hidden and system files, and searches each file
        with Select-String on multiple threads. Files are read as UTF-8 and every match
        on a line is returned. Files and directories that can't be read are skipped.

        When -Pattern is not given, searches for IPv4 addresses.

    .PARAMETER Path
        The file or directory to search. Wildcards are accepted. Defaults to the
        current location. Accepts paths from the pipeline.

    .PARAMETER Pattern
        The regular expression to search for. Defaults to a pattern that matches IPv4
        addresses.

    .PARAMETER ThrottleLimit
        The maximum number of files searched at once, from 1 through 255. Defaults to
        75% of the processors, rounded down, and at least 1.

    .INPUTS
        System.String. You can pipe paths to this function.

    .OUTPUTS
        System.Management.Automation.PSCustomObject. One object per file with at least
        one match, with the file path, the match count, and the line number, line, and
        matched values of each match.

    .EXAMPLE
        Search-PatternInFile -Path ./Doc/PwshBestPractice/PowershellExamples.md -Pattern 'Get-FileHash'

        Finds the Microsoft help examples that use Get-FileHash.

    .EXAMPLE
        Search-PatternInFile -Path ./Config

        Finds the IPv4 addresses in every file under ./Config.

    .EXAMPLE
        './Public', './Private' | Search-PatternInFile -Pattern 'using namespace' | Select-Object -ExpandProperty Path

        Lists the files in Public and Private that still have a using namespace line.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ValueFromPipeline,
            HelpMessage = 'Enter the file or directory to search. Wildcards are accepted. Accepts paths from the pipeline.')]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(HelpMessage = 'Enter the regular expression to search for.')]
        [ValidateNotNullOrEmpty()]
        [string]$Pattern,

        [Parameter(HelpMessage = 'Enter the maximum number of files searched at once (1-255).')]
        [ValidateRange(1, 255)]
        [int]$ThrottleLimit
    )
    begin {
        if (-not $PSBoundParameters.ContainsKey('ThrottleLimit')) {
            $ThrottleLimit = Get-DefaultThrottleLimit
        }

        if (-not $PSBoundParameters.ContainsKey('Pattern')) {
            $Pattern = '(?<![\d.])(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(?:\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}(?![\d.])'
        }
    }
    process {
        if (-not $PSBoundParameters.ContainsKey('Path')) {
            $Path = (Get-Location).Path
        }

        # Throws when nothing matches the path. A wildcard can resolve to several paths.
        $resolvedPath = (Resolve-Path -Path $Path -ErrorAction Stop).Path

        $searchParams = @{
            ThrottleLimit = $ThrottleLimit
            Parallel      = {
                $selectParams = @{
                    LiteralPath = $_.FullName
                    Pattern     = $using:Pattern
                    Encoding    = 'utf8'
                    AllMatches  = $true
                    ErrorAction = 'SilentlyContinue'
                }
                $matchInfo = @(Select-String @selectParams)
                if ($matchInfo.Count -gt 0) {
                    $values = @{ Name = 'Values'; Expression = { , @($_.Matches.Value) } }
                    [PSCustomObject]@{
                        Path       = $_.FullName
                        MatchCount = @($matchInfo.Matches).Count
                        Matches    = @($matchInfo | Select-Object -Property LineNumber, Line, $values)
                    }
                }
            }
        }
        Get-ChildItem -Path $resolvedPath -Recurse -File -Force -ErrorAction SilentlyContinue |
            ForEach-Object @searchParams
    }
}
