 <h2 style="color: #DCA657;">Get-AclItem</h2>

 The fixture builds three files that each broke this function at some point:
 an ordinary file, a name containing wildcard characters, and a hidden item.

```powershell
Describe 'Get-AclItem' -Skip:(-not $IsWindows)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The function is exported, and is a function rather than an alias.
```powershell
It 'Is exported as a function'
```
 - A file returns every documented field.
```powershell
It 'Returns the documented field set for a file'
```
 - A directory returns the same field set. One shape for both types is the
   whole point, and this is the case that catches a FileInfo-only property.
```powershell
It 'Returns the same field set for a directory'
```
 - `ItemType` distinguishes the two without the caller testing types.
```powershell
It 'Reports ItemType as the underlying type name'
```
 - Each nested access entry carries its documented fields.
```powershell
It 'Projects each ACE with the documented fields'
```
 - A missing path throws the function's own message, not a provider error.
```powershell
It 'Throws a named error when the path does not exist'
```
 - Regression: `-Path` treats `b[1].txt` as a character class. A pattern
   matching two files returns two items and silently corrupts the result.
```powershell
It 'Treats wildcard characters in the path literally'
```
 - Binding from the pipeline resolves to the same absolute path.
```powershell
It 'Accepts the path from the pipeline'
```
 - Regression: hidden items are the ones an ownership audit most wants.
```powershell
It 'Reads a hidden item'
```

 ---

