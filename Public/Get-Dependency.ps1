using namespace System

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Get-Dependency</h2>
####
function Get-Dependency {
    #### Returns the requirements from a set that are not installed.
    ####
    #### ```powershell
    #### Get-Dependency -Dependency $script:PSSecurityRuntimeModules
    #### ```
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    param(
        #### - `[array]`: __Dependency__
        ####     - *Requirements to check, each with `ModuleName` and `ModuleVersion`.*
        [array]$Dependency
    )

    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - `[List[hashtable]]`
    ####     - *The requirements that are absent. Empty when every one is satisfied.*
    $absent = [Collections.Generic.List[hashtable]]::new()
    foreach ($item in $Dependency) {
        if (-not (Test-DependencySatisfied -Dependency $item)) {
            $absent.Add($item)
        }
    }
    return $absent
}
####
#### ---
####
