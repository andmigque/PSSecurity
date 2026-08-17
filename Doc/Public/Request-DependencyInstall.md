 <h2 style="color: #DCA657;">Request-DependencyInstall</h2>

```powershell
function Request-DependencyInstall
```
 Asks the user once whether to install the absent requirements in a set,
 then installs the ones they accept for the current user.

 Returns without asking when nothing is absent. Needs an interactive host,
 because the question goes through `$Host.UI.PromptForChoice`.

 ```powershell
 Request-DependencyInstall -Label 'runtime' -Dependency $script:PSSecurityRuntimeModules
 ```

 <b style="color: #D2A8FF;">Parameters</b>

 - `[string]`: __Label__
     - *Names the set in the prompt title, such as `runtime` or `build time`.*
 - `[array]`: __Dependency__
     - *Requirements to check, each with `ModuleName` and `ModuleVersion`.*
 Wrapped in @() because PowerShell unrolls a collection on output. An empty
 result would arrive as $null, and reading .Count on it throws under strict mode.
 Guideline SD04: talk to the user through the host interface, never the
 System.Console API.

 <b style="color: #369FFF;">Returns</b>

 - *Nothing. `Install-Module` writes its own progress.*

 ---

