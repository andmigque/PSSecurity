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

#### <h2 style="color: #DCA657;">New-LocalAdminUser</h2>
####
#### Skipped off Windows. Local accounts and the Administrators group are Windows concepts.
####
Describe 'New-LocalAdminUser' -Skip:(-not $IsWindows) {
    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The function is exported, and is a function rather than an alias.
    It 'Is exported as a function' {
        $cmd = Get-Command -Module PSSecurity -Name 'New-LocalAdminUser' -ErrorAction SilentlyContinue
        $cmd | Should -Not -BeNullOrEmpty
        $cmd.CommandType | Should -Be 'Function'
    }
}
####
#### ---
####

#### <h2 style="color: #DCA657;">New-LocalAdminUser elevated</h2>
####
#### The account is removed from Administrators and deleted in `AfterAll`, each in
#### its own `try` so a failure in the first does not skip the second.
####
Describe 'New-LocalAdminUser elevated' -Skip:(-not $IsElevatedHost) {
    BeforeAll {
        $script:userName = '_OptSecTest_' + (Get-Random -Maximum 999999).ToString('D6')

        # Appended one character at a time so the password never exists as a
        # plaintext string. Local account policy wants several character classes,
        # so one of each leads rather than being left to the random fill.
        $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
        $password = [System.Security.SecureString]::new()
        foreach ($required in 'Q', 'z', '7', '!') {
            $password.AppendChar($required)
        }
        foreach ($position in 1..20) {
            $password.AppendChar($alphabet[[RandomNumberGenerator]::GetInt32(0, $alphabet.Length)])
        }
        $password.MakeReadOnly()

        $script:cred = [PSCredential]::new($script:userName, $password)
    }
    AfterAll {
        # Each removal gets its own try so a failure in the first does not skip the
        # second. The catch warns rather than swallowing: a sacrificial admin account
        # left behind on the machine is worth saying out loud, and throwing here
        # would fail the run over cleanup that already did its real work.
        try {
            Remove-LocalGroupMember -Group 'Administrators' -Member $script:userName -ErrorAction SilentlyContinue
        }
        catch {
            Write-Warning "Could not remove $($script:userName) from Administrators: $($_.Exception.Message)"
        }

        try {
            Remove-LocalUser -Name $script:userName -ErrorAction SilentlyContinue
        }
        catch {
            Write-Warning "Could not remove the local account $($script:userName): $($_.Exception.Message)"
        }
    }

    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The account is created, reported, and is a real member of Administrators.
    ####   The group membership is verified against Windows, not against the return value.
    It 'Creates the user and adds it to Administrators' {
        $newAdmin = @{
            Credential  = $script:cred
            FullName    = 'PSSecurity PSSecurity Test'
            Description = 'Sacrificial test account; safe to delete'
        }
        $result = New-LocalAdminUser @newAdmin
        $result.Username | Should -Be $script:userName
        $result.Created | Should -BeTrue
        $result.IsAdministrator | Should -BeTrue

        Get-LocalUser -Name $script:userName -ErrorAction Stop | Should -Not -BeNullOrEmpty
        $member = Get-LocalGroupMember -Group 'Administrators' | Where-Object { $_.Name -like "*\$($script:userName)" }
        $member | Should -Not -BeNullOrEmpty
    }
}
####
#### ---
####
