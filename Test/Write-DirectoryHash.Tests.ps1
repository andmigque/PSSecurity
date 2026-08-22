using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

BeforeAll {
    $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.psd1') -Force
}

AfterAll {
    Remove-Module PSSecurity -Force -ErrorAction SilentlyContinue
}

#### <h2 style="color: #DCA657;">Write-DirectoryHash</h2>
####
Describe 'Write-DirectoryHash' {
    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - Both index files are written, the JSON holds one record per included file,
    ####   and the Markdown carries the header block naming the algorithm.
    It 'Writes HashIndex.md and HashIndex.json with one record per included file' {
        $dir = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $dir | Out-Null
        try {
            1..3 | ForEach-Object { Set-Content -LiteralPath (Join-Path $dir "f$_.ps1") -Value "$_" }
            Write-DirectoryHash -Path $dir *> $null

            (Test-Path (Join-Path $dir 'HashIndex.json')) | Should -BeTrue
            (Test-Path (Join-Path $dir 'HashIndex.md')) | Should -BeTrue

            # Three files in, three records out. The two index files exclude
            # themselves, or the count would drift on every run.
            $records = @(Get-Content (Join-Path $dir 'HashIndex.json') -Raw | ConvertFrom-Json)
            $records.Count | Should -Be 3
            $records[0].Hash | Should -Not -BeNullOrEmpty

            $markdown = Get-Content (Join-Path $dir 'HashIndex.md') -Raw
            $markdown | Should -Match '^# Hash Index'
            $markdown | Should -Match '\*\*Algorithm\*\* : SHA256'
        }
        finally { Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue }
    }
}
####
#### ---
####
