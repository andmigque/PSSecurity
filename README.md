# PSSecurity

A cross-platform PowerShell module for auditing and hardening Windows and Linux.
PSSecurity uses only
PowerShell and .NET.

[![Open in vscode.dev](https://img.shields.io/badge/Open%20in-vscode.dev-blue)][1]

  [1]: https://vscode.dev/github/andmigque/PSSecurity

### Summary

- [PSSecurity](#pssecurity)
    - [Summary](#summary)
    - [Features of PSSecurity include](#features-of-pssecurity-include)
  - [Project objectives](#project-objectives)
  - [Getting the module](#getting-the-module)
  - [Getting started](#getting-started)
  - [Command reference](#command-reference)
    - [Audit](#audit)
    - [Harden](#harden)
    - [Accounts and system setup](#accounts-and-system-setup)
    - [Utilities](#utilities)
  - [Repository layout](#repository-layout)
    - [How private functions stay private](#how-private-functions-stay-private)
    - [Documentation](#documentation)
  - [Writing functions](#writing-functions)
    - [Finding files](#finding-files)
    - [Running work in parallel](#running-work-in-parallel)
    - [Requiring administrator rights](#requiring-administrator-rights)
    - [Handling CUI](#handling-cui)
  - [Known issues and planned changes](#known-issues-and-planned-changes)
  - [License](#license)

### Features of PSSecurity include

- [Audit][2] - Read ACLs, Authenticode signatures, scheduled tasks, UAC settings,
  and file hashes as PowerShell objects.
- [Harden][3] - Apply UAC policies, change ownership, encrypt with EFS, and remove
  unwanted AppX packages.
- [Parallel by default][4] - Recurse large file trees and run work on a fixed pool of
  thread jobs, sized to 75% of the processors.
- [Self-documenting][5] - Generate Markdown documentation from each function's
  comment-based help.

  [2]: #audit
  [3]: #harden
  [4]: #running-work-in-parallel
  [5]: #documentation

## Project objectives

1. **Minimal dependencies**
   - Uses built-in PowerShell and .NET instead of third-party modules.
2. **Cross-platform**
   - Supports Windows and Linux from one module.
   - Platform-specific functions check `$IsWindows` or `$IsLinux` before they are
     defined.
3. **Consistent, readable functions**
   - Every function follows the rules and file structure in [AGENTS.md][6].
   - Every function has full comment-based help, so its documentation can be
     generated.

  [6]: ./AGENTS.md

> Back to the [summary](#summary)

## Getting the module

PSSecurity is not published to the PowerShell Gallery. Clone it from GitHub.

Module | Description | Downloads / instructions
------ | ----------- | ------------------------
PSSecurity | Audit and harden Windows and Linux with PowerShell. | [source][7] / [instructions](#getting-started)

  [7]: https://github.com/andmigque/PSSecurity

> Back to the [summary](#summary)

## Getting started

Import the module, then install the PSSecurity profile:

```powershell
Import-Module ./PSSecurity.psd1
Deploy-PSProfile
```

[Deploy-PSProfile][8] copies [Config/PwshProfile.ps1][9], which works on both
Windows and Linux, to your `$PROFILE`.

  [8]: ./Public/Deploy-PSProfile.ps1
  [9]: ./Config/PwshProfile.ps1

> Back to the [summary](#summary)

## Command reference

The public commands, grouped by security domain. Commands marked *No help yet*
do not have comment-based help.

### Audit

Command | Description
------- | -----------
[Get-AclItem][10] | Gets ownership, access rules, and metadata for an item.
[Get-ApplicationSignatureAudit][11] | Audits Authenticode signatures of discoverable applications.
[Get-ScheduledTaskAudit][12] | Gets scheduled task configuration and last-run details.
[Get-UacConfiguration][13] | Gets UAC settings and their interpreted values.
[Measure-OwnerAnomaly][14] | Counts items whose owner differs from the expected identity.
[Write-DirectoryHash][15] | Hashes the files in a directory tree using the module's hash settings.
[Get-SshdConfiguration][52] | Gets the effective SSH daemon configuration as objects.
[Get-UnixFileMode][53] | Finds files or directories whose Unix mode has any of the given bits set, such as SUID or world-writable.

  [10]: ./Public/Get-AclItem.ps1
  [11]: ./Public/Get-ApplicationSignatureAudit.ps1
  [12]: ./Public/Get-ScheduledTaskAudit.ps1
  [13]: ./Public/Get-UacConfiguration.ps1
  [14]: ./Public/Measure-OwnerAnomaly.ps1
  [15]: ./Public/Write-DirectoryHash.ps1
  [52]: ./Public/Get-SshdConfiguration.ps1
  [53]: ./Public/Get-UnixFileMode.ps1

> Back to the [summary](#summary)

### Harden

Command | Description
------- | -----------
[Set-UacConsentOnly][16] | Sets the administrator UAC consent policy to value 5.
[Set-UacRequirePassword][17] | Sets the administrator UAC credential policy to value 1.
[Set-AclItemOwner][18] | Changes an item's owner and returns its updated ACL details.
[Protect-Item][19] | Encrypts an item using Windows EFS.
[Unprotect-Item][20] | Decrypts an item using Windows EFS.
[Remove-App][21] | Removes AppX packages identified by JSON input.
[Remove-ProvisionedApp][22] | Removes provisioned AppX packages from the online Windows image.
[Add-UnixFileMode][54] | Adds bits to the Unix mode of files or directories, such as the sticky bit.

  [16]: ./Public/Set-UacConsentOnly.ps1
  [17]: ./Public/Set-UacRequirePassword.ps1
  [18]: ./Public/Set-AclItemOwner.ps1
  [19]: ./Public/Protect-Item.ps1
  [20]: ./Public/Unprotect-Item.ps1
  [21]: ./Public/Remove-App.ps1
  [22]: ./Public/Remove-ProvisionedApp.ps1
  [54]: ./Public/Add-UnixFileMode.ps1

> Back to the [summary](#summary)

### Accounts and system setup

Command | Description
------- | -----------
[New-LocalAdminUser][23] | Creates a local user and adds it to Administrators.
[New-WindowsUserProfile][24] | Creates a local user and its Windows profile directory.
[New-SecurityCertificate][25] | Generates certificates with mkcert on Linux.
[Invoke-Sudo][26] | Runs a script block as root through sudo.
[Deploy-PSProfile][8] | Installs the PSSecurity pwsh profile for the current user and host.
[Import-Ubuntu][27] | Imports an Ubuntu archive as a WSL 2 distribution.
[Install-AzureDevOpsAgent][28] | Downloads and registers an Azure Pipelines Windows agent as a service.
[Install-DpkgPwsh][29] | Installs PowerShell 7.6.6 from the GitHub .deb package on Linux.
[Install-Sftp][30] | *No help yet.* Not implemented; the body is commented out.

  [23]: ./Public/New-LocalAdminUser.ps1
  [24]: ./Public/New-WindowsUserProfile.ps1
  [25]: ./Public/New-SecurityCertificate.ps1
  [26]: ./Public/Invoke-Sudo.ps1
  [27]: ./Public/Import-Ubuntu.ps1
  [28]: ./Public/Install-AzureDevOpsAgent.ps1
  [29]: ./Public/Install-DpkgPwsh.ps1
  [30]: ./Public/Install-Sftp.ps1

> Back to the [summary](#summary)

### Utilities

Command | Description
------- | -----------
[Compress-FileTree][31] | Compresses a directory tree into individual gzip files using thread jobs.
[Convert-CommentHelpToMarkdown][32] | Converts PowerShell comment-based help into Markdown documents.
[Join-MegaHash][33] | Joins the hashes of a directory tree into one file.
[Compare-MegaHash][51] | Compares a directory tree with the joined hash saved by Join-MegaHash.
[Search-PatternInFile][34] | Searches the files under a path for a regular expression.

  [31]: ./Public/Compress-FileTree.ps1
  [32]: ./Public/Convert-CommentHelpToMarkdown.ps1
  [33]: ./Public/Join-MegaHash.ps1
  [34]: ./Public/Search-PatternInFile.ps1
  [51]: ./Public/Compare-MegaHash.ps1

> Back to the [summary](#summary)

## Repository layout

Path | Contents
---- | --------
[PSSecurity.psd1][35] | Module manifest. Only the data PowerShell requires for a module.
[PSSecurity.psm1][36] | Module loader. Loads every `.ps1` file and exports only the public functions.
[Public/][37] | Exported functions, one per `.ps1` file.
[Private/][38] | Internal helper functions, one per `.ps1` file.
[Config/][39] | [Setting.psd1][40] holds the module's settings; [PwshProfile.ps1][9] is the profile installed by `Deploy-PSProfile`.
[Doc/][41] | `PwshBestPractices/` is hand edited. `Public/` and `Private/` are generated.
[Pipeline/][42] | Azure Pipelines definitions (`.yml`).
[Skill/][43] | Agent skills, such as [cui-llm-redact][44].
[AGENTS.md][6] | Coding rules, file structure, and exemplar functions for agents and contributors.

  [35]: ./PSSecurity.psd1
  [36]: ./PSSecurity.psm1
  [37]: ./Public/
  [38]: ./Private/
  [39]: ./Config/
  [40]: ./Config/Setting.psd1
  [41]: ./Doc/
  [42]: ./Pipeline/
  [43]: ./Skill/
  [44]: ./Skill/cui-llm-redact/SKILL.md

> Back to the [summary](#summary)

### How private functions stay private

[PSSecurity.psm1][36] loads `Private/` first, records the contents of the
`Function:` drive, then loads `Public/`. Only the functions that appear after that
snapshot are exported, so everything in `Private/` stays internal to the module.

> Back to the [summary](#summary)

### Documentation

Everything under [Doc/][41] is generated from comment-based help by
[Convert-CommentHelpToMarkdown][32]. Update the help inside a function, then
regenerate:

```powershell
Convert-CommentHelpToMarkdown -Path ./Private -OutPath ./Doc/Private
```

> Back to the [summary](#summary)

## Writing functions

Follow the rules and file structure in [AGENTS.md][6], and use its exemplar
functions as models.

### Finding files

Pick a recursive file search based on the size of the tree:

- [Get-FileSingleThreaded][45] - For small trees. It has no startup cost.
- [Get-FileMultiThreaded][46] - For large trees. It recurses into each subdirectory
  in parallel, at the cost of starting thread jobs.

  [45]: ./Private/Get-FileSingleThreaded.ps1
  [46]: ./Private/Get-FileMultiThreaded.ps1

> Back to the [summary](#summary)

### Running work in parallel

[Invoke-ParallelJob][47] runs a script block on a fixed pool of thread jobs. The
default pool size, from [Get-DefaultThrottleLimit][48], is 75% of the processors.

For long-running work with interactive, multi-threaded progress, see
[Compress-FileTree][31].

  [47]: ./Private/Invoke-ParallelJob.ps1
  [48]: ./Private/Get-DefaultThrottleLimit.ps1

> Back to the [summary](#summary)

### Requiring administrator rights

Use [Test-Administrator][49] to check for an elevated session, or
[Assert-Administrator][50] to stop when the session is not elevated.

  [49]: ./Private/Test-Administrator.ps1
  [50]: ./Private/Assert-Administrator.ps1

> Back to the [summary](#summary)

### Handling CUI

The [cui-llm-redact][44] skill explains how to redact and generalize Controlled
Unclassified Information (CUI) so that it is no longer CUI and can be used in
prompts to a public LLM.

> Back to the [summary](#summary)

## Known issues and planned changes

- **Some Linux audit and hardening functions are disabled.** The files for
  `Get-SudoersAudit`, `Set-CoreDumpPolicy`, `Set-CronPermission`,
  `Set-HomeDirectoryPermission`, `Set-LinuxFilePermission`, `Set-LoginDefPolicy`,
  `Set-ModprobeBlacklist`, and `Set-SysctlHardening` are commented out until they
  are rewritten. Their configuration moves to files in [Config/][39], copied into
  place by Deploy functions.
- **Configuration is hard to read.** [Config/Setting.psd1][40] holds every
  setting, with a lot of Linux-specific detail. It needs a better strategy for
  settings and configuration files.
- **Settings reach functions through hidden module variables.**
  [PSSecurity.psm1][36] copies settings into about 20 `$script:` variables, such
  as `$script:HashIndexInclude`, which functions like [Write-DirectoryHash][15]
  read without declaring them. The plan is to store only the path to the settings
  file as a `$script:` variable, and have each function read the settings it
  needs from that file.
- **`Public/` is flat.** Group functions into subfolders by security domain, such
  as `Audit` and `Harden`. The loader in [PSSecurity.psm1][36] only reads `.ps1`
  files directly inside `Public/` and `Private/`, so it needs to search
  subfolders first.
- **There are several disparate recursive file implementations.** All implementations should be refactored to use one of the private `Get-File*Threaded` functions.
- **Do Not write linux config files from a powershell function.** Put the config in `./Config`, and copy it into place.

> Back to the [summary](#summary)

## License

This project is [licensed under the MIT License](./LICENSE).
