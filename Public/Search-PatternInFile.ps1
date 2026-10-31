Set-StrictMode -Version Latest

function Search-PatternInFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$Pattern,

        [Parameter(Mandatory = $false)]
        [ValidateRange(2, 256)]
        [int]$ThrottleLimit = [Math]::Round(([int][Environment]::GetEnvironmentVariable('NUMBER_OF_PROCESSORS') * 0.75), [MidpointRounding]::AwayFromZero)
    )

    if ([string]::IsNullOrEmpty($Path)) {
        $Path = (Get-Location).Path
    }

    $Path = (Resolve-Path -Path $Path).Path

    if ([string]::IsNullOrEmpty($Pattern)) {
        $Pattern = '(?<![\d.])(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(?:\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}(?![\d.])'
    }

    $results = @(
        Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue -Force |
            ForEach-Object -Parallel {
                $pattern = $using:Pattern
                $matchInfo = @(Select-String -Path $_.FullName -Pattern $pattern -Encoding utf8 -AllMatches -ErrorAction SilentlyContinue)
                if ($matchInfo.Count -gt 0) {
                    $values = @{ Name = 'Values'; Expression = { , @($_.Matches.Value) } }
                    [PSCustomObject]@{
                        Path       = $_.FullName
                        MatchCount = @($matchInfo.Matches).Count
                        Matches    = @($matchInfo | Select-Object -Property LineNumber, Line, $values)
                    }
                }
            } -ThrottleLimit $ThrottleLimit
    )

    $matchedFiles = @($results | Sort-Object -Property Path)
    $matchCount = 0
    if ($matchedFiles.Count -gt 0) {
        $matchCount = [int]($matchedFiles | Measure-Object -Property MatchCount -Sum).Sum
    }

    if (-not (Test-Path -Path $OutPath)) {
        [void](New-Item -Path $OutPath -ItemType Directory -Force)
    }
    $jsonPath = Join-Path $OutPath 'SearchPatternInFile.json'
    $jsonOut = ConvertTo-Json -InputObject $matchedFiles -Depth 10
    $jsonOut | Out-File -FilePath $jsonPath -Encoding utf8

    $summary = "$($matchedFiles.Count) files, $matchCount matches written to $jsonPath"

    Write-Output $summary
}
