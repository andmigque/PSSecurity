 <h2 style="color: #DCA657;">Measure-OwnerAnomaly</h2>

```powershell
Describe 'Measure-OwnerAnomaly' -Skip:(-not $IsWindows)
```

 <b style="color: #D2A8FF;">Cases</b>

 - The function is exported, and is a function rather than an alias.
```powershell
It 'Is exported as a function'
```
 - One object for the whole pipeline. This is the accumulator contract.
```powershell
It 'Emits exactly one summary object for the whole pipeline'
```
 - Every input is counted, whether or not it was an anomaly.
```powershell
It 'Counts every item that came down the pipeline'
```
 - A matching identity produces no anomalies at all.
```powershell
It 'Reports no anomaly when the owner matches the identity'
```
 - An identity that owns nothing makes every item an anomaly.
```powershell
It 'Reports every item when the identity does not match the owner'
```
 - `-ne` on strings is case insensitive in PowerShell, so a shouted identity
   still matches. Anything that lowercases one side only would pass this too.
```powershell
It 'Compares the owner without regard to case'
```
 - `Anomalies` holds the offending items themselves, so the summary is
   actionable rather than just a count.
```powershell
It 'Carries the offending AclItem objects in Anomalies'
```
 - `AclItems` retains the full input alongside the filtered set.
```powershell
It 'Retains every input in AclItems alongside the anomalies'
```

 ---

 <h2 style="color: #DCA657;">Measure-OwnerAnomaly elevated</h2>

 Changing an owner needs elevation, so the one case that starts by doing that
 is gated. The Administrators account name is resolved from its well known SID
 rather than hardcoded, so it passes on a non English Windows install.

```powershell
Describe 'Measure-OwnerAnomaly elevated' -Skip:(-not $IsElevatedHost)
```

 <b style="color: #D2A8FF;">Cases</b>

 - An item whose owner was changed out from under the current user is
   reported as an anomaly, and the offending owner is named.
```powershell
It 'Flags an item owned by another principal'
```

 ---

