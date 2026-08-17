using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

$env:POWERSHELL_TELEMETRY_OPTOUT = 'true'
$root = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
#### Resolved against the module root, not the caller's location. A relative path here
#### makes the import work only when the shell happens to be sitting in the repo.
####
#### `-AsHashtable` is what keeps the shape the rest of the file already expects. Without
#### it every entry arrives as a `PSCustomObject`, which will not bind to a `[hashtable]`
#### parameter. On PowerShell 7.3 and later it returns an ordered hashtable, so a rewrite
#### preserves key order rather than scrambling the file.
$script:SettingsPath = Join-Path -Path $root -ChildPath 'PSSecuritySettings.json'
$psSecuritySettings = Get-Content -LiteralPath $script:SettingsPath -Raw | ConvertFrom-Json -AsHashtable

$script:HashIndexAlgorithm = $psSecuritySettings.HashIndexAlgorithm
$script:HashIndexInclude = $psSecuritySettings.HashIndexInclude
$script:HashIndexExclude = $psSecuritySettings.HashIndexExclude
$script:PSSecurityRuntimeModules = $psSecuritySettings.PSSecurityRuntimeModules
$script:PSSecurityBuildtimeModules = $psSecuritySettings.PSSecurityBuildtimeModules

#### <h1 style="color: #DCA657;">🎆 PSSecurity</h1>
####
#### > Module loader for the security toolkit.
####
#### ---
####
#### Sets strict mode, opts out of telemetry, and fixes the hash index policy at module scope.
#### Dot-sources `Private` then `Public`, then exports every function the load added.
####
#### ---
####
#### <h2 style="color: #DCA657;">Module Scope State Variables</h2>
####
#### | Variable | Purpose |
#### | --- | --- |
#### | `OutputEncoding` | UTF-8 in and out, so terminal characters parse accurately. |
#### | `IsInteractive` | False for an agent or a build, so interactive-only paths stay off. |
#### | `HasConsole` | False when either stream is redirected. |
#### | `HashIndexAlgorithm` | Hash algorithm for the directory index. |
#### | `HashIndexInclude` | File patterns the index covers. |
#### | `HashIndexExclude` | Directory names the walk refuses to descend into. |
#### | `SettingsPath` | `PSSecuritySettings.json`, read at load and rewritten when the dependency prompt is answered. |
####

#### Output encoding ensures accurate terminal character parsing.
$script:OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

#### IsInteractive keeps the shell from executing interactive-only functions,
#### so an AI agent can execute the script normally.
$script:IsInteractive = $Host.Name -eq 'ConsoleHost' -and $Host.UI -and $Host.UI.RawUI -and [Environment]::UserInteractive

#### HasConsole confirms a console is actually attached.
$script:HasConsole = -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected

####
#### <h2 style="color: #DCA657;">Load order</h2>
####
#### Private loads first so Public can call the helpers.
#### The function table is captured between the two passes, so only what Public
#### added gets exported and the private helpers stay private.
####
Get-ChildItem -Path "$(Join-Path -Path $root -ChildPath 'Private')" -Filter '*.ps1' | Resolve-Path | ForEach-Object { . $_ }
$sysFuncs = Get-ChildItem Function:
Get-ChildItem -Path "$(Join-Path -Path $root -ChildPath 'Public')" -Filter '*.ps1' | Resolve-Path | ForEach-Object { . $_ }
$funcs = Get-ChildItem Function: | Where-Object { $sysFuncs -notcontains $_ }

####
#### <b style="color: #C22514;">Throws</b>
####
#### - When the Public pass added no functions, which means the load failed.
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
#### <h2 style="color: #DCA657;">Dependencies</h2>

#### Prompt once, tracked by `DependencyPromptAnswered` in the settings file. A module
#### scope variable cannot carry this. `Import-Module -Force` re-runs the file in a fresh
#### module scope, and every new shell starts empty, so the question would come back
#### forever. Settings on disk survive both. Set the flag back to false to be asked again.
if ($script:IsInteractive -and $script:HasConsole) {
    if (-not $psSecuritySettings.DependencyPromptAnswered) {
        Request-DependencyInstall -Label 'runtime' -Dependency $script:PSSecurityRuntimeModules
        Request-DependencyInstall -Label 'build time' -Dependency $script:PSSecurityBuildtimeModules

        #### Written after the prompts, not before. If a prompt fails the question is
        #### asked again next load, which is the better failure. Writing first would
        #### silently retire the prompt on an install that never happened.
        ####
        #### The write itself is guarded: a module installed to a read only location
        #### must still load. Losing the flag only costs a repeated question.
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
    #### Non interactive hosts get told, not asked. An agent or a build cannot
    #### answer a prompt, and blocking on one would hang the session.
    ####
    #### The notice goes to the warning stream. `Import-Module` discards whatever a module
    #### writes to the success stream while it loads, so `Write-Output` here reached nobody.
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
