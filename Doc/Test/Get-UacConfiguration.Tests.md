 <h2 style="color: #DCA657;">Get-UacConfiguration</h2>

 Skipped off Windows. The registry keys do not exist there.

```powershell
Describe 'Get-UacConfiguration' -Skip:(-not $IsWindows)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The function is exported, and is a function rather than an alias.
```powershell
It 'Is exported as a function'
```

 ---

 <h2 style="color: #DCA657;">Get-UacConfiguration elevated</h2>

```powershell
Describe 'Get-UacConfiguration elevated' -Skip:(-not $IsElevatedHost)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The reader agrees with the setter, and evaluates the machine as hardened.
```powershell
It 'Reports hardened after require-password'
```

 ---

