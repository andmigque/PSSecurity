 <h2 style="color: #DCA657;">Get-ScheduledTaskAudit</h2>

 Skipped off Windows. The task scheduler CIM classes do not exist there.

```powershell
Describe 'Get-ScheduledTaskAudit' -Skip:(-not $IsWindows)
```

 <b style="color: #D2A8FF;">Cases</b>

 - Regression: `$task.Actions.Execute` throws on COM handler actions, and the
   throw kills the whole record. Row parity with the raw enumeration is what
   catches tasks being dropped silently rather than erroring.
```powershell
It 'Returns one row per scheduled task, dropping none'
```
 - The documented field set is present on every row.
```powershell
It 'Projects the documented fields'
```
 - Regression: a principal is either a UserId or a GroupId. Reading only
   UserId left roughly a third of rows with no identity, and said nothing.
```powershell
It 'Never leaves RunAs blank'
```
 - And names which of the two produced it.
```powershell
It 'Reports PrincipalKind as User or Group'
```
 - Regression: COM handler tasks are the ones that used to disappear, so
   their presence is the positive proof the switch handles both classes.
```powershell
It 'Includes COM handler tasks alongside exec tasks'
```
 - A COM action records its class id rather than an empty command line.
```powershell
It 'Records a ClassId for COM handler actions'
```
 - Every result classifies, and the hex form is what makes a code readable.
```powershell
It 'Classifies every result and renders it as hex'
```
 - Regression: `LastTaskResult -ne 0` is mostly false positives. The
   scheduler's own informational range must not classify as failure.
```powershell
It 'Treats the 0x000413xx informational range as not a failure'
```
 - A failure is exactly a set HRESULT severity bit, nothing else.
```powershell
It 'Classifies a result as Failure only when the severity bit is set'
```

 ---

 <h2 style="color: #DCA657;">Get-ScheduledTaskAudit elevated</h2>

```powershell
Describe 'Get-ScheduledTaskAudit elevated' -Skip:(-not ($IsWindows -and $IsElevatedHost))
```

 <b style="color: #D2A8FF;">Cases</b>

 - An elevated session sees the whole machine, so it raises no warning.
```powershell
It 'Raises no elevation warning'
```
 - SYSTEM context tasks are the ones an unelevated session cannot see, and
   they are the bulk of what elevation buys.
```powershell
It 'Sees SYSTEM context tasks'
```

 ---

 <h2 style="color: #DCA657;">Get-ScheduledTaskAudit unelevated</h2>

```powershell
Describe 'Get-ScheduledTaskAudit unelevated' -Skip:(-not ($IsWindows -and -not $IsElevatedHost))
```

 <b style="color: #D2A8FF;">Cases</b>

 - The partial view must announce itself. Silence would present two thirds
   of the machine as the whole of it, weighted toward the privileged end.
```powershell
It 'Warns that enumeration is incomplete'
```
 - It still returns what it can see. A partial audit beats no audit.
```powershell
It 'Still returns the tasks it can see'
```

 ---

