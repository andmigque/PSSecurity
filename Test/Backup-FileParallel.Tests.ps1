using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h1 style="color: #DCA657;">🎆 Backup-FileParallel.Tests</h1>
####
#### > Unit tests for `Backup-FileParallel`.
####
#### ---
####
#### Each case builds a throwaway source tree under the temp directory and removes
#### both trees afterward, so a failed run leaves nothing behind.
####
#### ---
####
BeforeAll {
    $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module PSSecurity -Force -ErrorAction SilentlyContinue
}

#### <h2 style="color: #DCA657;">Backup-FileParallel</h2>
####
Describe 'Backup-FileParallel' {
    # Five files are enough to exercise the parallel block without making the
    # suite wait on real compression work.
    BeforeEach {
        $script:src = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        $script:dst = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:src | Out-Null
        0..4 | ForEach-Object {
            Set-Content -LiteralPath (Join-Path $script:src "TestFile$($_).txt") -Value "content $_"
        }
    }
    AfterEach {
        Remove-Item -LiteralPath $script:src -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $script:dst -Recurse -Force -ErrorAction SilentlyContinue
    }

    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - A missing source throws before any destination directory is created.
    It 'Throws when Path does not exist' {
        $missing = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        { Backup-FileParallel -Path $missing -OutPath $script:dst } | Should -Throw
    }
}
####
#### ---
####
