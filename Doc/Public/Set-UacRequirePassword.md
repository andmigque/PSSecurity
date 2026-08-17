 <h2 style="color: #DCA657;">Set-UacRequirePassword</h2>

```powershell
function Set-UacRequirePassword
```
 Set UAC to prompt for credentials on the secure desktop.

 Sets `ConsentPromptBehaviorAdmin` to 1, so elevation requires credentials.
 Requires Administrator. Supports `-WhatIf`.


 <b style="color: #C22514;">Throws</b>

 - When the session is not elevated.
 The value is read before and after the write, so the caller sees the
 transition rather than the intent.

 <b style="color: #369FFF;">Returns</b>

 - `[PSCustomObject]`
     - `[string]`: __Setting__
         - *`ConsentPromptBehaviorAdmin`.*
     - `[int]`: __Before__
         - *Registry value before the write.*
     - `[int]`: __After__
         - *Registry value after the write, read back from the registry.*
     - `[string]`: __Status__
         - *What the new value means.*

 ---

