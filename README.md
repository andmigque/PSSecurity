# PSSecurity

A cross-platform PowerShell security module for auditing and hardening Windows and Linux.

## Compliance

Keep
dependencies to a minimum, ideally none: use built-in PowerShell and .NET rather
than third-party modules.

## Getting started

Import the module, then install the PSSecurity profile:

```powershell
Import-Module ./PSSecurity.psd1
Deploy-PwshProfile
```

[Deploy-PwshProfile](./Public/Deploy-PsProfile.ps1) copies
[Config/PwshProfile.ps1](./Config/PwshProfile.ps1), which works on both Windows
and Linux, to your `$PROFILE`.

## Repository layout

| Path | Contents |
|---|---|
| [PSSecurity.psd1](./PSSecurity.psd1) | Module manifest. Only the data PowerShell requires for a module. |
| [PSSecurity.psm1](./PSSecurity.psm1) | Module loader. Loads every `.ps1` file and exports only the public functions. |
| [Public/](./Public/) | Exported functions, one per `.ps1` file. |
| [Private/](./Private/) | Internal helper functions, one per `.ps1` file. |
| [Config/](./Config/) | [Setting.psd1](./Config/Setting.psd1) holds the module's settings; [PwshProfile.ps1](./Config/PwshProfile.ps1) is the profile installed by `Deploy-PwshProfile`. |
| [Doc/](./Doc/) | Generated documentation. Do not edit by hand. |
| [Pipeline/](./Pipeline/) | Azure Pipelines definitions (`.yml`). |
| [Skill/](./Skill/) | Agent skills, such as [cui-llm-redact](./Skill/cui-llm-redact/SKILL.md). |
| [AGENTS.md](./AGENTS.md) | Coding rules, file structure, and exemplar functions for agents and contributors. |

### How private functions stay private

[PSSecurity.psm1](./PSSecurity.psm1) loads `Private/` first, records the contents
of the `Function:` drive, then loads `Public/`. Only the functions that appear
after that snapshot are exported, so everything in `Private/` stays internal to
the module.

### Documentation

Everything under [Doc/](./Doc/) is generated from comment-based help by
[Convert-CommentHelpToMarkdown](./Public/Convert-CommentHelpToMarkdown.ps1).
Update the help inside a function, then regenerate. For example:

```powershell
Convert-CommentHelpToMarkdown -Path ./Private -OutPath ./Doc/Private
```

## Writing functions

Follow the rules and file structure in [AGENTS.md](./AGENTS.md), and use its
exemplar functions as models.

### Finding files

Pick a recurser based on the size of the tree:

- [Get-FileSingleThreaded](./Private/Get-FileSingleThreaded.ps1) for small trees.
  It has no startup cost.
- [Get-FileMultiThreaded](./Private/Get-FileMultiThreaded.ps1) for large trees.
  It walks each subdirectory in parallel, at the cost of starting thread jobs.

### Running work in parallel

[Invoke-ParallelJob](./Private/Invoke-ParallelJob.ps1) runs a script block on a
fixed pool of thread jobs. The default pool size, from
[Get-DefaultThrottleLimit](./Private/Get-DefaultThrottleLimit.ps1), is 75% of the
processors.

For long-running work with interactive, multi-threaded progress, see
[Compress-FileTree](./Public/Compress-FileTree.ps1).

### Requiring administrator rights

Use [Test-Administrator](./Private/Test-Administrator.ps1) to check for an
elevated session, or [Assert-Administrator](./Private/Assert-Administrator.ps1) to
stop when the session is not elevated.

### Handling CUI

The [cui-llm-redact](./Skill/cui-llm-redact/SKILL.md) skill explains how to redact
and generalize Controlled Unclassified Information (CUI) so that it is no longer
CUI and can be used in prompts to a public LLM.

## Known issues and planned changes

- **Configuration is hard to read.** [Config/Setting.psd1](./Config/Setting.psd1)
  holds every setting, with a lot of Linux-specific detail. It needs a better
  strategy for settings and configuration files.
- **Settings reach functions through hidden module variables.**
  [PSSecurity.psm1](./PSSecurity.psm1) copies settings into about 20 `$script:`
  variables, such as `$script:HashIndexInclude`, which functions like
  [Write-DirectoryHash](./Public/Write-DirectoryHash.ps1) read without declaring
  them. The plan is to store only the path to the settings file as a `$script:`
  variable, and have each function read the settings it needs from that file.
- **`Public/` is flat.** Group functions into subfolders by security domain, such
  as `Audit` and `Harden`.
