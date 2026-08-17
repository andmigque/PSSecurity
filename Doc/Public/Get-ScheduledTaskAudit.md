 <h2 style="color: #DCA657;">Get-ScheduledTaskAudit</h2>

```powershell
function Get-ScheduledTaskAudit
```
 Return one flat row per scheduled task.

 <b style="color: #D2A8FF;">Parameters</b>

 - `[string]`: __TaskPath__
     - *Task folder to enumerate. Defaults to every folder.*
 Warned, not thrown. Stopping here would deny a non-admin an audit that is
 still worth having, but silence would present two thirds of the machine as
 the whole of it.
 LastRunTime, LastTaskResult and NextRunTime live on a different cmdlet.
 Get-ScheduledTask alone never tells you whether a task actually ran.
 A principal is either a UserId or a GroupId, never both. Reading only
 UserId leaves every group principal blank, which is a third of the tasks
 on a stock Windows install. That failure is silent, unlike the COM action
 one above, which is why it is easy to miss.
 Most non-zero results are not failures. The 0x000413xx range is the
 scheduler's own informational set, and "the task has not yet run" alone
 accounts for the overwhelming majority of them. The HRESULT severity bit
 is what separates a real failure from a status report.

 <b style="color: #369FFF;">Returns</b>

 - `[PSCustomObject]`
     - `[string]`: __TaskName__ / __TaskPath__ / __State__ / __Author__
         - *Identity and current state.*
     - `[string]`: __RunAs__
         - *The principal, resolved from `UserId` or `GroupId`.*
     - `[string]`: __PrincipalKind__
         - *`User` or `Group`, naming which one produced `RunAs`.*
     - `[string]`: __LogonType__ / __RunLevel__
         - *How it logs on, and whether it runs at `Highest`.*
     - `[string]`: __ActionKind__
         - *`Exec`, `ComHandler`, or a comma joined mix.*
     - `[string]`: __Runs__
         - *Command line per exec action, or `COM:<ClassId>`.*
     - `[datetime]`: __LastRunTime__ / __NextRunTime__
         - *From `Get-ScheduledTaskInfo`, not from the task itself.*
     - `[int]`: __LastTaskResult__
         - *Raw result code.*
     - `[string]`: __LastResultHex__
         - *The same code as `0xXXXXXXXX`, which is the readable form.*
     - `[string]`: __LastResultKind__
         - *`Success`, `Informational`, or `Failure`, by HRESULT severity bit.*

 ---

