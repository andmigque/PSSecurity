using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

BeforeAll {
    $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.psm1') -Force

    # Defined inside BeforeAll, not at file scope. A top level function exists only
    # during Pester discovery and is invisible to the It blocks at run time.
    function Get-RandomSecureString {
        param([int]$Length = 24)

        # Appended one character at a time so the passphrase never exists as a
        # plaintext string. That is the whole objection behind
        # PSAvoidUsingConvertToSecureStringWithPlainText, and a test does not need
        # to know its own throwaway key.
        $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
        $secure = [System.Security.SecureString]::new()
        foreach ($position in 1..$Length) {
            $secure.AppendChar($alphabet[[RandomNumberGenerator]::GetInt32(0, $alphabet.Length)])
        }
        $secure.MakeReadOnly()
        return $secure
    }
}
AfterAll {
    Remove-Module PSSecurity -Force -ErrorAction SilentlyContinue
}

#### <h2 style="color: #DCA657;">Protect-FileWithEncryption</h2>
####
Describe 'Protect-FileWithEncryption' {
    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The same plaintext under two different keys produces different files.
    ####   Note this cannot isolate the key on its own, since the salt and IV are
    ####   also fresh per call and would change the bytes regardless.
    It 'Produces different ciphertext for different keys' {
        $plain = 'same plaintext'
        $keyA = Get-RandomSecureString
        $keyB = Get-RandomSecureString
        $sourceA = New-TemporaryFile
        $sourceB = New-TemporaryFile
        $encA = $null
        $encB = $null
        try {
            Set-Content -LiteralPath $sourceA -Value $plain -NoNewline
            Set-Content -LiteralPath $sourceB -Value $plain -NoNewline
            $encA = [string](Protect-FileWithEncryption -Path $sourceA -SecureKey $keyA)['Path']
            $encB = [string](Protect-FileWithEncryption -Path $sourceB -SecureKey $keyB)['Path']
            $bytesA = [Convert]::ToBase64String([IO.File]::ReadAllBytes($encA))
            $bytesB = [Convert]::ToBase64String([IO.File]::ReadAllBytes($encB))
            $bytesA | Should -Not -Be $bytesB
        }
        finally {
            Remove-Item -LiteralPath $sourceA -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $sourceB -Force -ErrorAction SilentlyContinue
            if ($encA) { Remove-Item -LiteralPath $encA -Force -ErrorAction SilentlyContinue }
            if ($encB) { Remove-Item -LiteralPath $encB -Force -ErrorAction SilentlyContinue }
        }
    }
}
####
#### ---
####
