 <h2 style="color: #DCA657;">New-LocalAdminUser</h2>

 Skipped off Windows. Local accounts and the Administrators group are Windows concepts.

```powershell
Describe 'New-LocalAdminUser' -Skip:(-not $IsWindows)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The function is exported, and is a function rather than an alias.
```powershell
It 'Is exported as a function'
```

 ---

 <h2 style="color: #DCA657;">New-LocalAdminUser elevated</h2>

 The account is removed from Administrators and deleted in `AfterAll`, each in
 its own `try` so a failure in the first does not skip the second.

```powershell
Describe 'New-LocalAdminUser elevated' -Skip:(-not $IsElevatedHost)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The account is created, reported, and is a real member of Administrators.
   The group membership is verified against Windows, not against the return value.
```powershell
It 'Creates the user and adds it to Administrators'
```

 ---

