Set-StrictMode -Version Latest

BeforeAll {
    $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.psd1') -Force
}

AfterAll {
    Remove-Module PSSecurity -Force -ErrorAction SilentlyContinue
}

#### <h2 style="color: #DCA657;">Unprotect-Item</h2>
####
Describe 'Unprotect-Item' {
    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - Resolves the supplied path and calls `Decrypt()` on the resulting item.
    It 'Decrypts the item returned by Get-Item' {
        $fakeItem = [pscustomobject]@{ DecryptCallCount = 0 }
        $fakeItem | Add-Member -MemberType ScriptMethod -Name Decrypt -Value {
            $this.DecryptCallCount++
        }
        Mock -CommandName Get-Item -ModuleName PSSecurity -MockWith { $fakeItem }

        Unprotect-Item -Path 'input.txt'

        $fakeItem.DecryptCallCount | Should -Be 1
        Should -Invoke -CommandName Get-Item -ModuleName PSSecurity -Times 1 -Exactly -ParameterFilter {
            $Path -eq 'input.txt'
        }
    }
}
####
#### ---
####
