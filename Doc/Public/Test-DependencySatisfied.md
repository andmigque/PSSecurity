 <h2 style="color: #DCA657;">Test-DependencySatisfied</h2>

```powershell
function Test-DependencySatisfied
```
 Reports whether one module dependency is already installed.

 ```powershell
 Test-DependencySatisfied -Dependency @{ ModuleName = 'BurntToast'; ModuleVersion = '1.1.0' }
 ```

 <b style="color: #D2A8FF;">Parameters</b>

 - `[hashtable]`: __Dependency__
     - *One requirement, with `ModuleName` and `ModuleVersion` keys.*
     - *Shaped like an entry in `Setting.psd1`.*
 Any installed version at or above the floor satisfies it. `ModuleVersion`
 is a minimum, matching how the manifest keyword of the same name behaves.

 <b style="color: #369FFF;">Returns</b>

 - `[bool]`
     - *True when an installed version is at or above `ModuleVersion`.*

 ---

