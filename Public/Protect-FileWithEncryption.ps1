using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Protect-FileWithEncryption</h2>
####
function Protect-FileWithEncryption {
    #### Encrypt a file with AES-256-CBC.
    ####
    #### Output is the source path with `.enc` appended. The source is left in place.
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding()]
    param(
        #### - `[string]`: __Path__
        ####     - *File to encrypt. Accepts pipeline input.*
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('FilePath')]
        [string]$Path,

        #### - `[securestring]`: __SecureKey__
        ####     - *Encryption passphrase.*
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [securestring]$SecureKey
    )

    process {
        ####
        #### <b style="color: #C22514;">Throws</b>
        ####
        #### - When `Path` does not resolve.
        $FilePath = Resolve-Path -Path $Path -ErrorAction Stop

        #### A fresh salt and IV per file. Two encryptions of the same bytes with the
        #### same passphrase produce different ciphertext, which is the point.
        $salt = [byte[]]::new(16)
        [RandomNumberGenerator]::Fill($salt)

        $aes = [Aes]::Create()
        $aes.Key = ([Rfc2898DeriveBytes]::new($SecureKey, $salt, 100000)).GetBytes(32)
        $aes.GenerateIV()

        $encryptedFilePath = [string]$FilePath + '.enc'
        $fileStream = [File]::Open($FilePath, 'Open', 'Read')
        $encryptedStream = [File]::Open($encryptedFilePath, 'Create', 'Write')
        $cryptoStream = $null

        try {
            #### Header first, then ciphertext. The reader depends on this order.
            $encryptedStream.Write($salt, 0, $salt.Length)
            $encryptedStream.Write($aes.IV, 0, $aes.IV.Length)
            $cryptoStream = [CryptoStream]::new($encryptedStream, $aes.CreateEncryptor(), [CryptoStreamMode]::Write)

            $buffer = [byte[]]::new(4096)
            while (($bytesRead = $fileStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $cryptoStream.Write($buffer, 0, $bytesRead)
            }
        }
        finally {
            #### The crypto stream closes first. Closing it flushes the final padded
            #### block into the file stream underneath it.
            if ($cryptoStream) { $cryptoStream.Close() }
            $fileStream.Close()
            $encryptedStream.Close()
        }

        ####
        #### <b style="color: #369FFF;">Returns</b>
        ####
        #### - `[ImmutableDictionary[string, object]]`
        ####     - `[string]`: __Path__
        ####         - *Path of the encrypted file.*
        ####     - `[long]`: __SizeBytes__
        ####         - *Size of the encrypted file, header included.*
        #### Each Add returns a new dictionary rather than mutating the old one, so
        #### the second call is what produces the value this function emits.
        $encryptedSize = [FileInfo]::new($encryptedFilePath).Length
        $manifest = [ImmutableDictionary[string, object]]::Empty.Add('Path', $encryptedFilePath)
        $manifest.Add('SizeBytes', $encryptedSize)
    }
}
####
#### ---
####

