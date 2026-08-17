 <h2 style="color: #DCA657;">Measure-OwnerAnomaly</h2>

```powershell
function Measure-OwnerAnomaly
```
 Summarize a pipeline of `Get-AclItem` objects by owner.

 An item owned by anyone other than `Identity` is an anomaly.
 Scope belongs to the caller, so point the pipeline at what you want measured.

 <b style="color: #D2A8FF;">Parameters</b>

 - `[PSCustomObject]`: __AclItem__
     - *An object from `Get-AclItem`. Accepts pipeline input.*
 - `[string]`: __Identity__
     - *Expected owner as `DOMAIN\User`. Defaults to the current user.*
     - *Compared without regard to case.*

 <b style="color: #369FFF;">Returns</b>

 - `[PSCustomObject]`
     - *One summary for the whole pipeline, emitted once.*
     - `[int]`: __AclItemCount__
         - *Items that came down the pipeline.*
     - `[int]`: __AnomalyCount__
         - *Items owned by someone other than `Identity`.*
     - `[PSCustomObject[]]`: __AclItems__
         - *Every input, in pipeline order.*
     - `[PSCustomObject[]]`: __Anomalies__
         - *The offending items. Group by `Owner` to see who holds them.*

 ---

