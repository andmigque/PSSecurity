using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h1 style="color: #DCA657;">🎆 PSSecurity</h1>
####
#### > Loads the security toolkit into a PowerShell session.
####
#### The loader runs once each time the module is imported. It performs five phases in order:
####
#### 1. Read `PSSecuritySettings.json` from the module directory.
#### 2. Create the module-scoped settings used by the imported functions.
#### 3. Detect whether the host can safely ask interactive questions.
#### 4. Load private helpers, load public commands, and export only the public commands.
#### 5. Offer dependency installation to a person, or report missing dependencies to an agent or build.
####
#### ---
####
#### <h2 style="color: #DCA657;">1. Read the module settings</h2>
####
#### Every path starts from the loader's own directory. The caller's current directory does
#### not affect the import.
####
#### The settings file is read once as a hashtable. This preserves each dependency entry as
#### a hashtable, which is the shape expected by the dependency commands.
####

$env:POWERSHELL_TELEMETRY_OPTOUT = 'true'
$root = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

$script:SettingsPath = Join-Path -Path $root -ChildPath 'PSSecuritySettings.json'
$psSecuritySettings = Get-Content -LiteralPath $script:SettingsPath -Raw | ConvertFrom-Json -AsHashtable

$script:HashIndexAlgorithm = $psSecuritySettings.HashIndexAlgorithm
$script:HashIndexInclude = $psSecuritySettings.HashIndexInclude
$script:HashIndexExclude = $psSecuritySettings.HashIndexExclude
$script:PSSecurityRuntimeModules = $psSecuritySettings.PSSecurityRuntimeModules
$script:PSSecurityBuildtimeModules = $psSecuritySettings.PSSecurityBuildtimeModules

#### <h2 style="color: #DCA657;">2. Create shared module state</h2>
####
#### Values copied into `$script:` scope are available to every file loaded into the module.
####
#### | State | Purpose |
#### | --- | --- |
#### | `SettingsPath` | Locates the settings file that was read during import. |
#### | `HashIndexAlgorithm` | Selects the algorithm used to hash repository files. |
#### | `HashIndexInclude` | Lists the file patterns included in a hash index. |
#### | `HashIndexExclude` | Lists the directories excluded from a hash index. |
#### | `PSSecurityRuntimeModules` | Defines modules needed while using PSSecurity. |
#### | `PSSecurityBuildtimeModules` | Defines modules needed to build and test PSSecurity. |
#### | `OutputEncoding` | Sets console input and output to UTF-8. |
####
$script:OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

#### <h2 style="color: #DCA657;">3. Detect the host</h2>
####
#### Dependency questions are allowed only when PowerShell is running interactively with an
#### attached console. Agents, pipelines, redirected shells, and build runners take the
#### non-interactive path and are never asked to answer a prompt.
####
#### | Check | True when |
#### | --- | --- |
#### | `IsInteractive` | The host is `ConsoleHost`, exposes its UI, and belongs to an interactive user. |
#### | `HasConsole` | Standard input and standard output are both attached to the console. |
####
$script:IsInteractive = $Host.Name -eq 'ConsoleHost' -and $Host.UI -and $Host.UI.RawUI -and [Environment]::UserInteractive

$script:HasConsole = -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected

####
#### <h2 style="color: #DCA657;">4. Load and export the commands</h2>
####
#### The loader dot-sources every `.ps1` file directly inside `Private`, then records the
#### current function table. It next dot-sources every `.ps1` file directly inside `Public`.
#### The functions added by the second pass are the public commands exported by the module.
####
#### This order lets public commands call private helpers without exposing those helpers to
#### the caller. Adding a function file to `Public` is enough to export it; the loader does
#### not maintain a separate function-name list.
####
Get-ChildItem -Path "$(Join-Path -Path $root -ChildPath 'Private')" -Filter '*.ps1' | Resolve-Path | ForEach-Object { . $_ }
$sysFuncs = Get-ChildItem Function:
Get-ChildItem -Path "$(Join-Path -Path $root -ChildPath 'Public')" -Filter '*.ps1' | Resolve-Path | ForEach-Object { . $_ }
$funcs = Get-ChildItem Function: | Where-Object { $sysFuncs -notcontains $_ }

####
#### <b style="color: #C22514;">Throws</b>
####
#### - When loading `Public` adds no functions.
####
if ($funcs) {
    Export-ModuleMember -Function $funcs.Name
}
else {
    throw 'PSSecurity function load failed. Check module .psm1'
}
####
#### ---
####
#### <h2 style="color: #DCA657;">5. Handle module dependencies</h2>
####
#### Dependency handling happens after the commands are loaded because it uses the public
#### dependency commands from the previous phase.
####
#### | Host | Loader behavior |
#### | --- | --- |
#### | Interactive console | Ask whether to install missing runtime and build-time modules for the current user. |
#### | Agent, build, or redirected shell | Skip every prompt and write one warning that names the missing modules. |
####
#### `DependencyPromptAnswered` persists the interactive answer in
#### `PSSecuritySettings.json`, so importing again does not repeat the questions. Set it to
#### `false` to ask again. The flag is written only after both prompts finish. If the module
#### directory is read-only, the loader warns that it could not save the answer and continues.
####
#### Missing dependencies do not stop the module from loading. The loader installs a missing
#### module only when an interactive user accepts the prompt; otherwise it reports what is
#### absent and leaves installation to the caller.
####
if ($script:IsInteractive -and $script:HasConsole) {
    if (-not $psSecuritySettings.DependencyPromptAnswered) {
        Request-DependencyInstall -Label 'runtime' -Dependency $script:PSSecurityRuntimeModules
        Request-DependencyInstall -Label 'build time' -Dependency $script:PSSecurityBuildtimeModules

        try {
            $psSecuritySettings.DependencyPromptAnswered = $true
            $psSecuritySettings |
                ConvertTo-Json -Depth 5 |
                Set-Content -LiteralPath $script:SettingsPath -Encoding utf8
        }
        catch {
            Write-Warning "Could not record the dependency prompt answer: $($_.Exception.Message)"
        }
    }
}
else {
    $absentRuntime = @(Get-Dependency -Dependency $script:PSSecurityRuntimeModules)
    $absentBuild = @(Get-Dependency -Dependency $script:PSSecurityBuildtimeModules)

    if (($absentRuntime.Count + $absentBuild.Count) -gt 0) {
        $missing = @($absentRuntime + $absentBuild | ForEach-Object { "$($_.ModuleName) $($_.ModuleVersion)" }) -join ', '
        Write-Warning "PSSecurity: these dependencies may not be installed: $missing"
    }
}
####
#### ---
####
#### <h2 style="color: #DCA657;">Import result</h2>
####
#### After a successful import:
####
#### - Functions loaded from `Public` are available to the caller.
#### - Functions loaded from `Private` remain available only inside the module.
#### - Hash-index settings and dependency definitions are shared in module scope.
#### - Non-interactive hosts complete without a prompt, even when dependencies are missing.
####
