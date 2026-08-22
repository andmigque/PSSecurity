Set-StrictMode -Version Latest

BeforeAll {
    $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.psd1') -Force
}

AfterAll {
    Remove-Module PSSecurity -Force -ErrorAction SilentlyContinue
}

#### <h2 style="color: #DCA657;">Protect-Item</h2>
####
Describe 'Protect-Item' {
    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - Resolves the supplied path and calls `Encrypt()` on the resulting item.
    It 'Encrypts the item returned by Get-Item' {
        $fakeItem = [pscustomobject]@{ EncryptCallCount = 0 }
        $fakeItem | Add-Member -MemberType ScriptMethod -Name Encrypt -Value {
            $this.EncryptCallCount++
        }
        Mock -CommandName Get-Item -ModuleName PSSecurity -MockWith { $fakeItem }

        Protect-Item -Path 'input.txt'

        $fakeItem.EncryptCallCount | Should -Be 1
        Should -Invoke -CommandName Get-Item -ModuleName PSSecurity -Times 1 -Exactly -ParameterFilter {
            $Path -eq 'input.txt'
        }
    }
}
####
#### ---
####
