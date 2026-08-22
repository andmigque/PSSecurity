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

#### <h2 style="color: #DCA657;">Get-ApplicationSignatureAudit</h2>
####
#### Skipped off Windows. Authenticode is a Windows signing scheme.
####
Describe 'Get-ApplicationSignatureAudit' -Skip:(-not $IsWindows) {
    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The function is exported, and is a function rather than an alias.
    It 'Is exported as a function' {
        $cmd = Get-Command -Module PSSecurity -Name 'Get-ApplicationSignatureAudit' -ErrorAction SilentlyContinue
        $cmd | Should -Not -BeNullOrEmpty
        $cmd.CommandType | Should -Be 'Function'
    }

    #### - The parallel throttle is reachable by the caller.
    It 'Exposes a ThrottleLimit parameter' {
        (Get-Command Get-ApplicationSignatureAudit).Parameters.ContainsKey('ThrottleLimit') | Should -BeTrue
    }
}
####
#### ---
####
