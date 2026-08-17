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

#### <h2 style="color: #DCA657;">Unprotect-EncryptedFile</h2>
####
Describe 'Unprotect-EncryptedFile' {
    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - Plaintext survives a full encrypt then decrypt cycle byte for byte,
    ####   including the embedded newline.
    It 'Round-trips plaintext through AES-256' {
        $plain = "The quick brown fox jumps over the lazy dog.`nLine two ends here."
        $key = Get-RandomSecureString
        $tempIn = New-TemporaryFile
        $tempOut = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString() + '.out')
        $encPath = $null
        try {
            Set-Content -LiteralPath $tempIn -Value $plain -NoNewline -Encoding utf8NoBOM
            $encPath = [string](Protect-FileWithEncryption -Path $tempIn -SecureKey $key)['Path']
            (Test-Path -LiteralPath $encPath) | Should -BeTrue
            ([System.IO.FileInfo]::new($encPath).Length) | Should -BeGreaterThan 0

            Unprotect-EncryptedFile -EncryptedFilePath $encPath -FilePassword $key -OutputFilePath $tempOut | Out-Null
            (Get-Content -LiteralPath $tempOut -Raw -Encoding utf8NoBOM) | Should -Be $plain
        }
        finally {
            Remove-Item -LiteralPath $tempIn -Force -ErrorAction SilentlyContinue
            if ($encPath -and (Test-Path -LiteralPath $encPath)) { Remove-Item -LiteralPath $encPath -Force -ErrorAction SilentlyContinue }
            Remove-Item -LiteralPath $tempOut -Force -ErrorAction SilentlyContinue
        }
    }
}
####
#### ---
####
