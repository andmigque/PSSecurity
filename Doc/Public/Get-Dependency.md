 <h2 style="color: #DCA657;">Get-Dependency</h2>

```powershell
function Get-Dependency
```
 Returns the requirements from a set that are not installed.

 ```powershell
 Get-Dependency -Dependency $script:PSSecurityRuntimeModules
 ```

 <b style="color: #D2A8FF;">Parameters</b>

 - `[array]`: __Dependency__
     - *Requirements to check, each with `ModuleName` and `ModuleVersion`.*

 <b style="color: #369FFF;">Returns</b>

 - `[List[hashtable]]`
     - *The requirements that are absent. Empty when every one is satisfied.*

 ---

