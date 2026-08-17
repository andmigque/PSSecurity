 <h2 style="color: #DCA657;">Get-ApplicationSignatureAudit</h2>

 Skipped off Windows. Authenticode is a Windows signing scheme.

```powershell
Describe 'Get-ApplicationSignatureAudit' -Skip:(-not $IsWindows)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The function is exported, and is a function rather than an alias.
```powershell
It 'Is exported as a function'
```
 - The parallel throttle is reachable by the caller.
```powershell
It 'Exposes a ThrottleLimit parameter'
```

 ---

