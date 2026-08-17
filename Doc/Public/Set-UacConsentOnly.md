 <h2 style="color: #DCA657;">Set-UacConsentOnly</h2>

```powershell
function Set-UacConsentOnly
```
 Set UAC back to consent only elevation.

 Sets `ConsentPromptBehaviorAdmin` to 5, the Windows default.
 This is the inverse of `Set-UacRequirePassword` and is not the hardened setting.
 Requires Administrator. Supports `-WhatIf`.


 <b style="color: #C22514;">Throws</b>

 - When the session is not elevated.

 <b style="color: #369FFF;">Returns</b>

 - `[PSCustomObject]`
     - *Same shape as `Set-UacRequirePassword`, with `After` set to 5.*

 ---

