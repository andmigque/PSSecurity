Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Request-DependencyInstall</h2>
####
function Request-DependencyInstall {
    #### Asks the user once whether to install the absent requirements in a set,
    #### then installs the ones they accept for the current user.
    ####
    #### Returns without asking when nothing is absent. Needs an interactive host,
    #### because the question goes through `$Host.UI.PromptForChoice`.
    ####
    #### ```powershell
    #### Request-DependencyInstall -Label 'runtime' -Dependency $script:PSSecurityRuntimeModules
    #### ```
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    param(
        #### - `[string]`: __Label__
        ####     - *Names the set in the prompt title, such as `runtime` or `build time`.*
        [string]$Label,

        #### - `[array]`: __Dependency__
        ####     - *Requirements to check, each with `ModuleName` and `ModuleVersion`.*
        [array]$Dependency
    )

    #### Wrapped in @() because PowerShell unrolls a collection on output. An empty
    #### result would arrive as $null, and reading .Count on it throws under strict mode.
    $absent = @(Get-Dependency -Dependency $Dependency)
    if ($absent.Count -eq 0) {
        return
    }

    $names = ($absent | ForEach-Object { "$($_.ModuleName) $($_.ModuleVersion)" }) -join ', '

    #### Guideline SD04: talk to the user through the host interface, never the
    #### System.Console API.
    $yes = [System.Management.Automation.Host.ChoiceDescription]::new('&Yes', "Install $names for the current user.")
    $no = [System.Management.Automation.Host.ChoiceDescription]::new('&No', 'Continue without installing.')

    $choice = $Host.UI.PromptForChoice(
        "PSSecurity $Label dependencies",
        "Install? $names",
        @($yes, $no),
        0)

    if ($choice -ne 0) {
        return
    }

    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - *Nothing. `Install-Module` writes its own progress.*
    foreach ($item in $absent) {
        Install-Module -Name $item.ModuleName -MinimumVersion $item.ModuleVersion -Scope CurrentUser -Force
    }
}
####
#### ---
####
