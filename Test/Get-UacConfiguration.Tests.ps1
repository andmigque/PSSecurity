using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

# Evaluated at discovery time so -Skip resolves while Pester builds the tree.
$IsElevatedHost = $false
if ($IsWindows) {
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $IsElevatedHost = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

BeforeAll {
    $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.psm1') -Force
}
AfterAll {
    Remove-Module PSSecurity -Force -ErrorAction SilentlyContinue
}

#### <h2 style="color: #DCA657;">Get-UacConfiguration</h2>
####
#### Skipped off Windows. The registry keys do not exist there.
####
Describe 'Get-UacConfiguration' -Skip:(-not $IsWindows) {
    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The function is exported, and is a function rather than an alias.
    It 'Is exported as a function' {
        $cmd = Get-Command -Module PSSecurity -Name 'Get-UacConfiguration' -ErrorAction SilentlyContinue
        $cmd | Should -Not -BeNullOrEmpty
        $cmd.CommandType | Should -Be 'Function'
    }
}
####
#### ---
####

#### <h2 style="color: #DCA657;">Get-UacConfiguration elevated</h2>
####
Describe 'Get-UacConfiguration elevated' -Skip:(-not $IsElevatedHost) {
    BeforeAll {
        $script:uacRegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
        $script:uacOriginal = (Get-ItemProperty -Path $script:uacRegPath -Name ConsentPromptBehaviorAdmin).ConsentPromptBehaviorAdmin
    }
    AfterAll {
        Set-ItemProperty -Path $script:uacRegPath -Name ConsentPromptBehaviorAdmin -Value $script:uacOriginal
    }

    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The reader agrees with the setter, and evaluates the machine as hardened.
    It 'Reports hardened after require-password' {
        # The setter establishes the policy this case reads back. Both come from the
        # same imported module, so the dependency is explicit rather than an ordering
        # assumption about some other test having run first.
        Set-UacRequirePassword | Out-Null

        $cfg = Get-UacConfiguration
        $cfg.ConsentPromptBehaviorAdmin | Should -Be 1
        $cfg.Hardened | Should -BeTrue
    }
}
####
#### ---
####
