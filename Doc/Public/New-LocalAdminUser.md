 <h2 style="color: #DCA657;">New-LocalAdminUser</h2>

```powershell
function New-LocalAdminUser
```
 Create a local user account and add it to the Administrators group.

 Requires Administrator. Supports `-WhatIf`.

 <b style="color: #D2A8FF;">Parameters</b>

 - `[PSCredential]`: __Credential__
     - *Username and password for the new account.*
     - *Windows caps a local account name at 20 characters.*
 - `[string]`: __FullName__
     - *Display name. Optional.*
 - `[string]`: __Description__
     - *Account description. Optional.*
 - `[switch]`: __PasswordNeverExpires__
     - *Sets the account password to never expire.*

 <b style="color: #C22514;">Throws</b>

 - When the session is not elevated.
 - When the account name is longer than 20 characters.
 - When the account already exists.
 Optional values are added only when supplied, so the splat never carries
 an empty string into a field that would then be set to blank.
 One gate covers both calls. An account created but never added to
 Administrators is a worse outcome than no account at all.

 <b style="color: #369FFF;">Returns</b>

 - `[PSCustomObject]`
     - `[string]`: __Username__
         - *Account name from `Credential.UserName`.*
     - `[string]`: __FullName__
         - *Display name, or empty when not supplied.*
     - `[bool]`: __Created__
         - *True. The function throws rather than reporting failure here.*
     - `[bool]`: __IsAdministrator__
         - *True. The account is added to Administrators before this returns.*
     - `[bool]`: __PasswordNeverExpires__
         - *Reflects the switch.*

 ---

