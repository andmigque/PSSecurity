using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Unprotect-EncryptedFile</h2>
####
function Unprotect-EncryptedFile {
    #### Decrypt a file produced by `Protect-FileWithEncryption`.
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding()]
    param (
        #### - `[string]`: __EncryptedFilePath__
        ####     - *Path to the `.enc` file.*
        [Parameter(Mandatory = $true)]
        [string]$EncryptedFilePath,

        #### - `[securestring]`: __FilePassword__
        ####     - *The passphrase used during encryption.*
        [Parameter(Mandatory = $true)]
        [securestring]$FilePassword,

        #### - `[string]`: __OutputFilePath__
        ####     - *Destination for the decrypted output.*
        [Parameter(Mandatory = $true)]
        [string]$OutputFilePath
    )

    ####
    #### <b style="color: #C22514;">Throws</b>
    ####
    #### - When `EncryptedFilePath` does not resolve.
    #### - When the passphrase is wrong, which surfaces as a padding failure.
    $EncryptedFilePath = Resolve-Path -Path $EncryptedFilePath -ErrorAction Stop

    try {
        $encryptedStream = [File]::Open($EncryptedFilePath, 'Open', 'Read')

        try {
            #### Salt and IV come off the front of the file in the order they were written.
            $salt = [byte[]]::new(16)
            $encryptedStream.Read($salt, 0, $salt.Length) | Out-Null

            $iv = [byte[]]::new(16)
            $encryptedStream.Read($iv, 0, $iv.Length) | Out-Null

            $pbkdf2 = [Rfc2898DeriveBytes]::new($FilePassword, $salt, 100000)
            $key = $pbkdf2.GetBytes(32)

            $aes = [Aes]::Create()
            $aes.Key = $key
            $aes.IV = $iv

            $decryptor = $aes.CreateDecryptor()
            $cryptoStream = [CryptoStream]::new($encryptedStream, $decryptor, [CryptoStreamMode]::Read)
            $outputStream = [File]::Open($OutputFilePath, 'Create', 'Write')

            try {
                #### Copied in 4 KB chunks, so file size never drives memory use.
                $buffer = [byte[]]::new(4096)
                while (($bytesRead = $cryptoStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    $outputStream.Write($buffer, 0, $bytesRead)
                }

                ####
                #### <b style="color: #369FFF;">Returns</b>
                ####
                #### - `[PSCustomObject]`
                ####     - `[string]`: __Status__
                ####         - *`Success`. Any failure throws instead.*
                ####     - `[string]`: __EncryptedFile__
                ####         - *Resolved path of the input.*
                ####     - `[string]`: __DecryptedFile__
                ####         - *Path of the decrypted output.*
                ####     - `[int]`: __EncryptedFileSizeKB__
                ####         - *Size of the input in KB.*
                ####     - `[int]`: __DecryptedFileSizeKB__
                ####         - *Size of the output in KB.*
                ####     - `[string]`: __Salt__
                ####         - *Base64 salt read from the header.*
                ####     - `[string]`: __IV__
                ####         - *Base64 initialization vector read from the header.*
                $dataObject = [PSCustomObject]@{
                    Status              = 'Success'
                    EncryptedFile       = $EncryptedFilePath
                    DecryptedFile       = $OutputFilePath
                    EncryptedFileSizeKB = (([FileInfo]::new($EncryptedFilePath).Length / 1KB) -as [int])
                    DecryptedFileSizeKB = (([FileInfo]::new($OutputFilePath).Length / 1KB) -as [int])
                    Salt                = ([Convert]::ToBase64String($salt))
                    IV                  = ([Convert]::ToBase64String($iv))
                }

                $dataObject
            }
            finally {
                $outputStream.Close()
                $cryptoStream.Close()
            }
        }
        finally {
            $encryptedStream.Close()
        }
    }
    catch {
        throw
    }
}
####
#### ---
####

