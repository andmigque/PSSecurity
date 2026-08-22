using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h1 style="color: #DCA657;">🎆 Assert-Administrator.Tests</h1>
####
#### > Unit tests for the private `Assert-Administrator` helper.
####
#### ---
####
#### This helper is deliberately not exported, so the only thing a test can assert
#### about it from outside the module is that it stayed private. The loader exports
#### the delta between the `Private` and `Public` passes, and this is what proves
#### that still holds after the one function per file split.
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

#### <h2 style="color: #DCA657;">Assert-Administrator</h2>
####
Describe 'Assert-Administrator' {
    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The elevation gate stays private. Exporting it would put a guard clause
    ####   on the public surface where a caller could mistake it for a check they own.
    It 'Is not exported from the module' {
        Get-Command -Module PSSecurity -Name 'Assert-Administrator' -ErrorAction SilentlyContinue |
            Should -BeNullOrEmpty
    }
}
####
#### ---
####
