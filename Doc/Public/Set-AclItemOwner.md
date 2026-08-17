 <h2 style="color: #DCA657;">Set-AclItemOwner</h2>

```powershell
function Set-AclItemOwner
```
 Change the owner of one item and return it as read back from disk.

 Requires Administrator. Supports `-WhatIf`.

 <b style="color: #D2A8FF;">Parameters</b>

 - `[PSCustomObject]`: __AclItem__
     - *An object from `Get-AclItem`. Accepts pipeline input.*
 - `[string]`: __Identity__
     - *New owner as `DOMAIN\User`. Defaults to the current user.*

 <b style="color: #C22514;">Throws</b>

 - When the session is not elevated.
 - When `AclItem` did not come from `Get-AclItem`.

 <b style="color: #369FFF;">Returns</b>

 - `[PSCustomObject]`
     - *A fresh `Get-AclItem` read, so the owner reflects disk and not intent.*
     - *Nothing under `-WhatIf`.*

 ---

