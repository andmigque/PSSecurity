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
    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module PSSecurity -Force -ErrorAction SilentlyContinue
}

#### <h2 style="color: #DCA657;">Set-UacConsentOnly</h2>
####
#### Skipped off Windows. The registry keys do not exist there.
####
Describe 'Set-UacConsentOnly' -Skip:(-not $IsWindows) {
    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The function is exported, and is a function rather than an alias.
    It 'Is exported as a function' {
        $cmd = Get-Command -Module PSSecurity -Name 'Set-UacConsentOnly' -ErrorAction SilentlyContinue
        $cmd | Should -Not -BeNullOrEmpty
        $cmd.CommandType | Should -Be 'Function'
    }
}
####
#### ---
####

#### <h2 style="color: #DCA657;">Set-UacConsentOnly elevated</h2>
####
Describe 'Set-UacConsentOnly elevated' -Skip:(-not $IsElevatedHost) {
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
    #### - The inverse setter returns the machine to the Windows default.
    It 'Sets ConsentPromptBehaviorAdmin to 5' {
        (Set-UacConsentOnly).After | Should -Be 5
    }
}
####
#### ---
####
