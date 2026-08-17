 <h2 style="color: #DCA657;">Set-AclItemOwner</h2>

```powershell
Describe 'Set-AclItemOwner' -Skip:(-not $IsWindows)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The function is exported, and is a function rather than an alias.
```powershell
It 'Is exported as a function'
```
 - The composition `Get-AclItem | Set-AclItemOwner` is reachable, and the
   mutator declares ShouldProcess so `-WhatIf` is available.
```powershell
It 'Takes an AclItem from the pipeline and supports ShouldProcess'
```

 ---

 <h2 style="color: #DCA657;">Set-AclItemOwner elevated</h2>

 The Administrators account name is resolved from its well known SID rather than
 hardcoded, so these cases pass on a non English Windows install.

```powershell
Describe 'Set-AclItemOwner elevated' -Skip:(-not $IsElevatedHost)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The returned item carries the new owner, and identifies the file it changed.
```powershell
It 'Returns the re-read item with the new owner'
```
 - The change survives a fresh read, so the return value reflects disk and
   not just what the function intended to do.
```powershell
It 'Persists the change to disk'
```
 - Omitting `-Identity` falls back to the current user.
```powershell
It 'Defaults the identity to the current user'
```
 - `-WhatIf` reaches the ShouldProcess branch and writes nothing.
```powershell
It 'Leaves the owner alone under WhatIf'
```
 - A foreign object fails rather than silently mutating something.
```powershell
It 'Rejects an object that did not come from Get-AclItem'
```

 ---

