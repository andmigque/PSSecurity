```powershell
function Get-RandomSecureString
```
 <h2 style="color: #DCA657;">Protect-FileWithEncryption</h2>

```powershell
Describe 'Protect-FileWithEncryption'
```

 <b style="color: #D2A8FF;">Cases</b>

 - The same plaintext under two different keys produces different files.
   Note this cannot isolate the key on its own, since the salt and IV are
   also fresh per call and would change the bytes regardless.
```powershell
It 'Produces different ciphertext for different keys'
```

 ---

