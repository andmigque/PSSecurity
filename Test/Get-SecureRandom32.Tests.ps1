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

#### <h2 style="color: #DCA657;">Get-SecureRandom32</h2>
####
Describe 'Get-SecureRandom32' {
    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The default length is 32, which the name promises.
    It 'Returns 32 characters by default' {
        (Get-SecureRandom32).Length | Should -Be 32
    }

    #### - An explicit length is honored at both ends of the useful range.
    It 'Honors -Length' {
        (Get-SecureRandom32 -Length 16).Length | Should -Be 16
        (Get-SecureRandom32 -Length 64).Length | Should -Be 64
    }

    #### - Output stays inside the declared alphabet, so it is safe to paste anywhere.
    It 'Returns alphanumeric characters only' {
        Get-SecureRandom32 | Should -Match '^[A-Za-z0-9]+$'
    }

    #### - Two calls differ. A generator that repeats is the failure worth catching.
    It 'Returns different values across calls' {
        (Get-SecureRandom32) | Should -Not -Be (Get-SecureRandom32)
    }

    #### - The 1 to 512 range is enforced by the parameter, not by the body.
    It 'Rejects a length outside 1..512' {
        { Get-SecureRandom32 -Length 0 } | Should -Throw
        { Get-SecureRandom32 -Length 513 } | Should -Throw
    }
}
####
#### ---
####
