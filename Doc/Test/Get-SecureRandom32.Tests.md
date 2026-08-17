 <h2 style="color: #DCA657;">Get-SecureRandom32</h2>

```powershell
Describe 'Get-SecureRandom32'
```

 <b style="color: #D2A8FF;">Cases</b>

 - The default length is 32, which the name promises.
```powershell
It 'Returns 32 characters by default'
```
 - An explicit length is honored at both ends of the useful range.
```powershell
It 'Honors -Length'
```
 - Output stays inside the declared alphabet, so it is safe to paste anywhere.
```powershell
It 'Returns alphanumeric characters only'
```
 - Two calls differ. A generator that repeats is the failure worth catching.
```powershell
It 'Returns different values across calls'
```
 - The 1 to 512 range is enforced by the parameter, not by the body.
```powershell
It 'Rejects a length outside 1..512'
```

 ---

