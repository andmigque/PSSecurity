 <h2 style="color: #DCA657;">Set-UacConsentOnly</h2>

 Skipped off Windows. The registry keys do not exist there.

```powershell
Describe 'Set-UacConsentOnly' -Skip:(-not $IsWindows)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The function is exported, and is a function rather than an alias.
```powershell
It 'Is exported as a function'
```

 ---

 <h2 style="color: #DCA657;">Set-UacConsentOnly elevated</h2>

```powershell
Describe 'Set-UacConsentOnly elevated' -Skip:(-not $IsElevatedHost)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The inverse setter returns the machine to the Windows default.
```powershell
It 'Sets ConsentPromptBehaviorAdmin to 5'
```

 ---

