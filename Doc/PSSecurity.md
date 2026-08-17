 <h1 style="color: #DCA657;">🎆 PSSecurity</h1>

 > Module loader for the security toolkit.

 ---

 Sets strict mode, opts out of telemetry, and fixes the hash index policy at module scope.
 Dot-sources `Private` then `Public`, then exports every function the load added.

 ---

 <h2 style="color: #DCA657;">Module Scope State Variables</h2>

 | Variable | Purpose |
 | --- | --- |
 | `OutputEncoding` | UTF-8 in and out, so terminal characters parse accurately. |
 | `IsInteractive` | False for an agent or a build, so interactive-only paths stay off. |
 | `HasConsole` | False when either stream is redirected. |
 | `HashIndexAlgorithm` | Hash algorithm for the directory index. |
 | `HashIndexInclude` | File patterns the index covers. |
 | `HashIndexExclude` | Directory names the walk refuses to descend into. |

 Output encoding ensures accurate terminal character parsing.
 IsInteractive keeps the shell from executing interactive-only functions,
 so an AI agent can execute the script normally.
 HasConsole confirms a console is actually attached.

 <h2 style="color: #DCA657;">Load order</h2>

 Private loads first so Public can call the helpers.
 The function table is captured between the two passes, so only what Public
 added gets exported and the private helpers stay private.


 <b style="color: #C22514;">Throws</b>

 - When the Public pass added no functions, which means the load failed.


 ---

 <h2 style="color: #DCA657;">Dependencies</h2>

 | Set | Needed for |
 | --- | --- |
 | Runtime | `Show-DesktopNotification`. The module loads and every other function works without it. |
 | Build time | `Invoke-Build` tasks: the suite, the analyzer, the doc build. |

 These are deliberately not in the manifest. A `RequiredModules` entry makes the
 whole module unloadable when a dependency is absent or a pinned version does not
 match, which would take the encryption and hashing surface down over a toast.

 Defined after `Export-ModuleMember`, so the two helpers below stay module private
 without needing to be excluded from the export set.

```powershell
function Test-DependencySatisfied
```
 Any installed version at or above the floor satisfies it. `ModuleVersion`
 is a minimum, matching how the manifest keyword of the same name behaves.
```powershell
function Get-AbsentDependency
```
```powershell
function Request-DependencyInstall
```
 Wrapped in @() because PowerShell unrolls a collection on output. An empty
 result would arrive as $null, and reading .Count on it throws under strict mode.
 Guideline SD04: talk to the user through the host interface, never the
 System.Console API.
 Prompt once, tracked by a marker file under `Generated`, which is gitignored.
 A variable cannot carry this. `Import-Module -Force` re-runs the file in a fresh
 module scope, and every new shell starts empty, so the question would come back
 forever. The marker survives both.
 Written after the prompts, not before. If a prompt fails the question is
 asked again next load, which is the better failure. Writing first would
 silently retire the prompt on an install that never happened.

 The write itself is guarded: a module installed to a read only location
 must still load. Losing the marker only costs a repeated question.
 Non interactive hosts get told, not asked. An agent or a build cannot
 answer a prompt, and blocking on one would hang the session.

 ---

