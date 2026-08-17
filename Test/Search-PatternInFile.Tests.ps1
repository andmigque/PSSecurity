using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

BeforeAll {
    $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.psm1') -Force
}
AfterAll {
    Remove-Module PSSecurity -Force -ErrorAction SilentlyContinue
}

#### <h2 style="color: #DCA657;">Search-PatternInFile</h2>
####
Describe 'Search-PatternInFile' {
    # One file holds the needle and one does not, so a match and a non-match are
    # both present in every run.
    BeforeEach {
        $script:dir = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        $script:out = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:dir | Out-Null
        New-Item -ItemType Directory -Path $script:out | Out-Null
        Set-Content -LiteralPath (Join-Path $script:dir 'hit.txt') -Value 'the NEEDLE is here'
        Set-Content -LiteralPath (Join-Path $script:dir 'miss.txt') -Value 'nothing to see'
        # Two occurrences on one line and one on another, so a per-file count and a
        # per-line count cannot be mistaken for each other.
        Set-Content -LiteralPath (Join-Path $script:dir 'many.txt') -Value @(
            'NEEDLE and NEEDLE again'
            'nothing here'
            'one more NEEDLE'
        )
    }
    # Search-PatternInFile raises a real desktop toast when BurntToast is present.
    # Unmocked, a suite run fires one notification per case at whoever is sitting
    # at the machine. The mock is scoped to the module because the call happens
    # inside Search-PatternInFile, not at the test's own scope.
    BeforeAll {
        Mock -ModuleName PSSecurity Show-DesktopNotification { }
    }

    AfterEach {
        Remove-Item -LiteralPath $script:dir -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $script:out -Recurse -Force -ErrorAction SilentlyContinue
    }

    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The file holds exactly the matching paths. The matches live on disk, so
    ####   this reads the file rather than the return value.
    It 'Records the matching files and excludes non-matching files' {
        Search-PatternInFile -Directory $script:dir -Pattern 'NEEDLE' -OutPath $script:out | Out-Null
        $entries = @(Get-Content -LiteralPath (Join-Path $script:out 'SearchPatternInFile.json') -Raw | ConvertFrom-Json)
        $entries.Count | Should -Be 2
        @($entries.Path) | Should -Not -Contain (Join-Path $script:dir 'miss.txt')
    }

    #### - Repeats on one line are counted, not collapsed. `many.txt` holds two on
    ####   the first line and one on the third, so a line count and an occurrence
    ####   count cannot be mistaken for each other.
    It 'Counts every occurrence and records one entry per matching line' {
        Search-PatternInFile -Directory $script:dir -Pattern 'NEEDLE' -OutPath $script:out | Out-Null
        $entries = @(Get-Content -LiteralPath (Join-Path $script:out 'SearchPatternInFile.json') -Raw | ConvertFrom-Json)
        $many = $entries | Where-Object { $_.Path -match 'many\.txt$' }
        $many.MatchCount | Should -Be 3
        @($many.Matches).Count | Should -Be 2
        @($many.Matches | Where-Object LineNumber -EQ 1).Values.Count | Should -Be 2
    }

    #### - Each entry carries what `Select-String` reports: the line it sits on, the
    ####   whole line, and the values matched on it.
    It 'Carries the line number, the line, and the matched values' {
        Search-PatternInFile -Directory $script:dir -Pattern 'NEEDLE' -OutPath $script:out | Out-Null
        $entries = @(Get-Content -LiteralPath (Join-Path $script:out 'SearchPatternInFile.json') -Raw | ConvertFrom-Json)
        $hit = $entries | Where-Object { $_.Path -match 'hit\.txt$' }
        $match = @($hit.Matches)[0]
        $match.LineNumber | Should -Be 1
        $match.Line | Should -Be 'the NEEDLE is here'
        @($match.Values) | Should -Be @('NEEDLE')
    }

    #### - The result survives the session as a file under `OutPath`.
    It 'Writes SearchPatternInFile.json under OutPath' {
        Search-PatternInFile -Directory $script:dir -Pattern 'NEEDLE' -OutPath $script:out | Out-Null
        Test-Path -Path (Join-Path $script:out 'SearchPatternInFile.json') -PathType Leaf | Should -BeTrue
    }

    #### - The return value is a summary naming both counts and the file, not the
    ####   matches. A long run can produce more matches than a terminal will hold.
    It 'Returns a summary naming both counts and the output file' {
        $summary = Search-PatternInFile -Directory $script:dir -Pattern 'NEEDLE' -OutPath $script:out
        $summary | Should -BeOfType [string]
        $summary | Should -Match '^2 files, 4 matches written to '
        $summary | Should -Match 'SearchPatternInFile\.json$'
    }

    #### - Emits exactly one object. Anything extra on the success stream would be
    ####   the caller's problem to filter.
    It 'Emits a single summary line' {
        @(Search-PatternInFile -Directory $script:dir -Pattern 'NEEDLE' -OutPath $script:out).Count | Should -Be 1
    }

    #### - The notification is raised, carrying the same summary the caller receives.
    ####   Asserting the mock ran is also what proves the real toast did not.
    It 'Raises a desktop notification carrying the summary' {
        $summary = Search-PatternInFile -Directory $script:dir -Pattern 'NEEDLE' -OutPath $script:out
        Should -Invoke -ModuleName PSSecurity Show-DesktopNotification -Times 1 -Exactly -ParameterFilter {
            $Message -eq $summary
        }
    }

    #### - Regression: without a launch path the toast activates the app it is
    ####   registered under, which is PowerShell, so clicking the result opened a
    ####   console instead of the findings.
    It 'Points the notification at the output file' {
        Search-PatternInFile -Directory $script:dir -Pattern 'NEEDLE' -OutPath $script:out | Out-Null
        $expected = Join-Path $script:out 'SearchPatternInFile.json'
        Should -Invoke -ModuleName PSSecurity Show-DesktopNotification -Times 1 -Exactly -ParameterFilter {
            $LaunchPath -eq $expected
        }
    }

    #### - No match still writes an empty JSON array and reports zero.
    It 'Reports zero and writes an empty array when nothing matches' {
        $summary = Search-PatternInFile -Directory $script:dir -Pattern 'NOTPRESENTANYWHERE' -OutPath $script:out
        $summary | Should -Match '^0 files, 0 matches written to '
        @(Get-Content -LiteralPath (Join-Path $script:out 'SearchPatternInFile.json') -Raw | ConvertFrom-Json).Count | Should -Be 0
    }
}
####
#### ---
####
