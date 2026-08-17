 <h2 style="color: #DCA657;">Protect-FileWithEncryption</h2>

```powershell
function Protect-FileWithEncryption
```
 Encrypt a file with AES-256-CBC.

 Output is the source path with `.enc` appended. The source is left in place.

 <b style="color: #D2A8FF;">Parameters</b>

 - `[string]`: __Path__
     - *File to encrypt. Accepts pipeline input.*
 - `[securestring]`: __SecureKey__
     - *Encryption passphrase.*

 <b style="color: #C22514;">Throws</b>

 - When `Path` does not resolve.
 A fresh salt and IV per file. Two encryptions of the same bytes with the
 same passphrase produce different ciphertext, which is the point.
 Header first, then ciphertext. The reader depends on this order.
 The crypto stream closes first. Closing it flushes the final padded
 block into the file stream underneath it.

 <b style="color: #369FFF;">Returns</b>

 - `[ImmutableDictionary[string, object]]`
     - `[string]`: __Path__
         - *Path of the encrypted file.*
     - `[long]`: __SizeBytes__
         - *Size of the encrypted file, header included.*
 Each Add returns a new dictionary rather than mutating the old one, so
 the second call is what produces the value this function emits.

 ---

