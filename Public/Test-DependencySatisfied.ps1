Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Test-DependencySatisfied</h2>
####
function Test-DependencySatisfied {
    #### Reports whether one module dependency is already installed.
    ####
    #### ```powershell
    #### Test-DependencySatisfied -Dependency @{ ModuleName = 'BurntToast'; ModuleVersion = '1.1.0' }
    #### ```
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    param(
        #### - `[hashtable]`: __Dependency__
        ####     - *One requirement, with `ModuleName` and `ModuleVersion` keys.*
        ####     - *Shaped like an entry in `PSSecuritySettings.json`.*
        [hashtable]$Dependency
    )

    #### Any installed version at or above the floor satisfies it. `ModuleVersion`
    #### is a minimum, matching how the manifest keyword of the same name behaves.
    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - `[bool]`
    ####     - *True when an installed version is at or above `ModuleVersion`.*
    foreach ($candidate in Get-Module -ListAvailable -Name $Dependency.ModuleName) {
        if ($candidate.Version -ge [version]$Dependency.ModuleVersion) {
            return $true
        }
    }
    return $false
}
####
#### ---
####
