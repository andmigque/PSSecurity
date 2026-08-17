 <h2 style="color: #DCA657;">Unprotect-EncryptedFile</h2>

```powershell
function Unprotect-EncryptedFile
```
 Decrypt a file produced by `Protect-FileWithEncryption`.

 <b style="color: #D2A8FF;">Parameters</b>

 - `[string]`: __EncryptedFilePath__
     - *Path to the `.enc` file.*
 - `[securestring]`: __FilePassword__
     - *The passphrase used during encryption.*
 - `[string]`: __OutputFilePath__
     - *Destination for the decrypted output.*

 <b style="color: #C22514;">Throws</b>

 - When `EncryptedFilePath` does not resolve.
 - When the passphrase is wrong, which surfaces as a padding failure.
 Salt and IV come off the front of the file in the order they were written.
 Copied in 4 KB chunks, so file size never drives memory use.

 <b style="color: #369FFF;">Returns</b>

 - `[PSCustomObject]`
     - `[string]`: __Status__
         - *`Success`. Any failure throws instead.*
     - `[string]`: __EncryptedFile__
         - *Resolved path of the input.*
     - `[string]`: __DecryptedFile__
         - *Path of the decrypted output.*
     - `[int]`: __EncryptedFileSizeKB__
         - *Size of the input in KB.*
     - `[int]`: __DecryptedFileSizeKB__
         - *Size of the output in KB.*
     - `[string]`: __Salt__
         - *Base64 salt read from the header.*
     - `[string]`: __IV__
         - *Base64 initialization vector read from the header.*

 ---

