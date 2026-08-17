 <h2 style="color: #DCA657;">New-SecurityCertificate</h2>

```powershell
function New-SecurityCertificate
```
 Generate locally trusted TLS certificates for a hostname and optional subdomains.

 Supports `-WhatIf`.

 <b style="color: #D2A8FF;">Parameters</b>

 - `[string]`: __Hostname__
     - *Primary hostname. Defaults to the system hostname.*
 - `[string[]]`: __Subdomains__
     - *Optional subdomain prefixes. Each becomes `<subdomain>.<Hostname>`.*

 <b style="color: #C22514;">Throws</b>

 - When `mkcert` is not on PATH.

 <b style="color: #369FFF;">Returns</b>

 - `[PSCustomObject[]]`
     - `[string]`: __Domain__
         - *Fully qualified domain the certificate covers.*
     - `[string]`: __Status__
         - *`Generated`.*

 ---

