```powershell
function Get-RandomSecureString
```
 <h2 style="color: #DCA657;">Unprotect-EncryptedFile</h2>

```powershell
Describe 'Unprotect-EncryptedFile'
```

 <b style="color: #D2A8FF;">Cases</b>

 - Plaintext survives a full encrypt then decrypt cycle byte for byte,
   including the embedded newline.
```powershell
It 'Round-trips plaintext through AES-256'
```

 ---

