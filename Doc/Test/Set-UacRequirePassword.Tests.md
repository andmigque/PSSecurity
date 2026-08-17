 <h2 style="color: #DCA657;">Set-UacRequirePassword</h2>

 Skipped off Windows. The registry keys do not exist there.

```powershell
Describe 'Set-UacRequirePassword' -Skip:(-not $IsWindows)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The function is exported, and is a function rather than an alias.
```powershell
It 'Is exported as a function'
```

 ---

 <h2 style="color: #DCA657;">Set-UacRequirePassword elevated</h2>

```powershell
Describe 'Set-UacRequirePassword elevated' -Skip:(-not $IsElevatedHost)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The setter reports the value it wrote, read back from the registry.
```powershell
It 'Sets ConsentPromptBehaviorAdmin to 1'
```

 ---

