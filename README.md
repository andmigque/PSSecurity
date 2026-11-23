# PSSecurity

A cross-platform PowerShell module for auditing and hardening Windows and Linux.

[![Open in vscode.dev](https://img.shields.io/badge/Open%20in-vscode.dev-blue)][1]

  [1]: https://vscode.dev/github/andmigque/PSSecurity

## 🔭 Roadmap

See the [Roadmap][59] for the upcoming FedRAMP feature.
The most up-to-date FedRAMP rules and marketplace listings, accessible directly in your terminal.

- [1.3 FedRAMP Rules](./Doc/Roadmap.md#-13-fedramp-rules)
- [1.4 FedRAMP Marketplace](./Doc/Roadmap.md#-14-fedramp-marketplace)
- [2.3 FedRAMP Requirements](./Doc/Roadmap.md#-23-fedramp-requirements)
  - [2.3.6 FedRAMP rules example](./Doc/Roadmap.md#-236-fedramp-rules-example)
- [2.4 FedRAMP Marketplace Requirements](./Doc/Roadmap.md#-24-fedramp-marketplace-requirements)
  - [2.4.6 Marketplace category example](./Doc/Roadmap.md#-246-marketplace-category-example)

  [59]: ./Doc/Roadmap.md

### 🧭 Summary

- [PSSecurity](#pssecurity)
  - [🔭 Roadmap](#-roadmap)
    - [🧭 Summary](#-summary)
    - [✨ Features of PSSecurity](#-features-of-pssecurity-include)
  - [🎯 Project objectives](#-project-objectives)
  - [📦 Getting the module](#-getting-the-module)
  - [🚀 Getting started](#-getting-started)
  - [📖 Command reference](#-command-reference)
    - [🔍 Audit](#-audit)
    - [🔒 Harden](#-harden)
    - [👤 Accounts and system setup](#-accounts-and-system-setup)
    - [🧰 Utilities](#-utilities)
  - [📁 Repository layout](#-repository-layout)
    - [🙈 How private functions stay private](#-how-private-functions-stay-private)
    - [📝 Documentation](#-documentation)
  - [🔧 Writing functions](#-writing-functions)
    - [📂 Finding files](#-finding-files)
    - [⚡ Running multithreaded work](#-running-multithreaded-work)
    - [🔑 Requiring administrator rights](#-requiring-administrator-rights)
  - [🚧 Known issues and planned changes](#-known-issues-and-planned-changes)
  - [📄 License](#-license)

### ✨ Features of PSSecurity 

PSSecurity helps you run multithreaded auditing and hardening workflows. The module is conceptually organized into four domains:

- [Audit][2] - Read ACLs, Authenticode signatures, scheduled tasks, UAC settings,
  and file hashes as PowerShell objects.
- [Harden][3] - Apply UAC policies, change ownership, encrypt with EFS, and remove unwanted AppX packages.
- [Multithreading][4] - Schedule caller-created thread jobs and inspect the
  running, completed, failed, and stopped jobs.
- [Doucmentation][5] - Generate Markdown documentation from each function's
  comment-based help.

  [2]: #-audit
  [3]: #-harden
  [4]: #-running-multithreaded-work
  [5]: #-documentation

## 🎯 PSSecurity Objectives

1. **Minimal Dependencies**
   - Uses built-in PowerShell and .NET. No external module dependencies. 
2. **Cross Platform**
   - Supports Windows and Linux.
3. **LLM Friendly**
   - Comprehensive Markdown function documentation.

  [6]: ./AGENTS.md

> Back to the [summary](#-summary)

## 📦 Clone the Module

Enter your source code directory, then:

```powershell
git clone https://github.com/andmigque/PSSecurity.git
```

  [7]: https://github.com/andmigque/PSSecurity

> Back to the [summary](#-summary)

## 🚀 Import the Module

Import the module, then deploy the PSSecurity profile:

```powershell
Import-Module PSSecurity
Deploy-PSProfile
```

[Deploy-PSProfile][8] copies [Config/PwshProfile.ps1][9] to your `$PROFILE` on Win and Lin.

All future commands will be written to the root of your user directory into the pshistory.log file.

Restart your session to begin using your upgraded PowerShell.

  [8]: ./Public/Deploy-PsProfile.ps1
  [9]: ./Config/PwshProfile.ps1

> Back to the [summary](#-summary)

## 📖 Command Reference

The public commands, grouped by security domain. Commands marked *No help yet*
do not have comment-based help.

### 🔍 Audit

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
[Get-SudoersAudit][57] | Audits sudo rules for passwordless, all-command, and wildcard grants.

  [10]: ./Public/Get-AclItem.ps1
  [11]: ./Public/Get-ApplicationSignatureAudit.ps1
  [12]: ./Public/Get-ScheduledTaskAudit.ps1
  [13]: ./Public/Get-UacConfiguration.ps1
  [14]: ./Public/Measure-OwnerAnomaly.ps1
  [15]: ./Public/Write-DirectoryHash.ps1
  [52]: ./Public/Get-SshdConfiguration.ps1
  [53]: ./Public/Get-UnixFileMode.ps1
  [57]: ./Public/Get-SudoersAudit.ps1

> Back to the [summary](#-summary)

### 🔒 Harden

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
[Deploy-LinuxConfiguration][55] | Copies the Linux hardening files in Config/Linux into place: kernel parameters, module blacklist, and core dump policy.
[Set-LinuxFilePermission][56] | Tightens the owner and mode of system files, cron directories, and home directories to a rule table.

  [16]: ./Public/Set-UacConsentOnly.ps1
  [17]: ./Public/Set-UacRequirePassword.ps1
  [18]: ./Public/Set-AclItemOwner.ps1
  [19]: ./Public/Protect-Item.ps1
  [20]: ./Public/Unprotect-Item.ps1
  [21]: ./Public/Remove-App.ps1
  [22]: ./Public/Remove-ProvisionedApp.ps1
  [54]: ./Public/Add-UnixFileMode.ps1
  [55]: ./Public/Deploy-LinuxConfiguration.ps1
  [56]: ./Public/Set-LinuxFilePermission.ps1

> Back to the [summary](#-summary)

### 👤 Accounts and Setup

Command | Description
------- | -----------
[New-LocalAdminUser][23] | Creates a local user and adds it to Administrators.
[New-WindowsUserProfile][24] | Creates a local user and its Windows profile directory.
[New-SecurityCertificate][25] | Generates certificates with mkcert on Linux.
[Invoke-Sudo][26] | Runs a script block as root through sudo.
[Deploy-PSProfile][8] | Installs the PSSecurity pwsh profile for the current user and host.
[Import-Ubuntu][27] | Imports an Ubuntu archive as a WSL 2 distribution.
[Install-AzureDevOpsAgent][28] | Downloads and registers an Azure Pipelines Windows agent as a service.
[Install-DpkgPwsh][29] | Installs PowerShell 7.6.6 from the GitHub .deb package on Linux

  [23]: ./Public/New-LocalAdminUser.ps1
  [24]: ./Public/New-WindowsUserProfile.ps1
  [25]: ./Public/New-SecurityCertificate.ps1
  [26]: ./Public/Invoke-Sudo.ps1
  [27]: ./Public/Import-Ubuntu.ps1
  [28]: ./Public/Install-AzureDevOpsAgent.ps1
  [29]: ./Public/Install-DpkgPwsh.ps1

> Back to the [summary](#-summary)

### 🧰 Utilities

Command | Description
------- | -----------
[Compress-FileTree][31] | Recursively mirrors and compresses directory trees as gzip files using thread jobs.
[Convert-CommentHelpToMarkdown][32] | Converts PowerShell comment-based help into Markdown documents.
[Get-EnumeratedDirectory][60] | Lists child directories and optionally recurses, skipping excluded subtrees.
[Initialize-ThreadJobBag][61] | Places an array of thread jobs in a bounded bag.
[Initialize-Pool][62] | Opens a scheduler runspace and attaches it to the supplied bag object.
[Start-ThreadJobPool][63] | Starts the scheduler and returns the pool with live job counts and job objects.
[Search-PatternInFile][34] | Searches the files under a path for a regular expression.

  [31]: ./Public/Compress-FileTree.ps1
  [32]: ./Public/Convert-CommentHelpToMarkdown.ps1
  [34]: ./Public/Search-PatternInFile.ps1
  [60]: ./Doc/Public/Get-EnumeratedDirectory.md
  [61]: ./Doc/Public/Initialize-ThreadJobBag.md
  [62]: ./Doc/Public/Initialize-Pool.md
  [63]: ./Doc/Public/Start-ThreadJobPool.md
  [64]: ./Doc/Private/Get-DefaultThreadCount.md

> Back to the [summary](#-summary)

## 📁 Repository Layout

Path | Contents
---- | --------
[PSSecurity.psd1][35] | Module manifest. Only the data PowerShell requires for a module.
[PSSecurity.psm1][36] | Module loader. Loads every `.ps1` file and exports only the public functions.
[Public/][37] | Exported functions, one per `.ps1` file.
[Private/][38] | Internal helper functions, one per `.ps1` file.
[Config/][39] | [Setting.psd1][40] holds the module's settings; [PwshProfile.ps1][9] is the profile installed by `Deploy-PSProfile`; `Linux/` mirrors `/` and holds the hardening files installed by `Deploy-LinuxConfiguration`; `LinuxFilePermission.psd1` holds the rules applied by `Set-LinuxFilePermission`.
[Doc/][41] | [Roadmap.md][59] and `PwshBestPractice/` are hand edited. `Public/` and `Private/` are generated.
[AGENTS.md][6] | Coding rules, file structure, and exemplar functions for agents and contributors.

  [35]: ./PSSecurity.psd1
  [36]: ./PSSecurity.psm1
  [37]: ./Public/
  [38]: ./Private/
  [39]: ./Config/
  [40]: ./Config/Setting.psd1
  [41]: ./Doc/
  [43]: ./Skill/
  
> Back to the [summary](#-summary)

### 🙈 How Private Functions Stay Private

[PSSecurity.psm1][36] loads `Private/` first, records the contents of the
`Function:` drive, then loads `Public/`. Only the functions that appear after that
snapshot are exported, so everything in `Private/` stays internal to the module.

> Back to the [summary](#-summary)

### 📝 Documentation

`Doc/Public/` and `Doc/Private/` are generated from comment-based help by
[Convert-CommentHelpToMarkdown][32]. Update the help inside a function, then
regenerate:

```powershell
Convert-CommentHelpToMarkdown -Path ./Public -OutPath ./Doc/Public
Convert-CommentHelpToMarkdown -Path ./Private -OutPath ./Doc/Private
```

> Back to the [summary](#-summary)

## 🔧 Writing Functions

Follow the rules and file structure in [AGENTS.md][6], and use its exemplar
functions as models.

### 📂 Finding Files

Use [Get-EnumeratedDirectory][60] to list immediate child directories, or pass
`-Recurse` to walk descendants. Exclusions match directory names and skip the
entire matching subtree. Each input path produces one list of directories.

```powershell
$directories = Get-EnumeratedDirectory -LiteralPath . -Recurse -Exclude '.git', 'bin*'
$directories | Select-Object -ExpandProperty FullName
```

### ⚡ Running Multithreaded Work

Pass your array of unstarted, unscheduled thread jobs to
[Initialize-ThreadJobBag][61]. The bag holds the entire batch.
[Initialize-Pool][62] opens the scheduler runspace, and [Start-ThreadJobPool][63]
starts dispatching jobs and returns the pool immediately. Jobs created with
`Start-ThreadJob` already have a scheduler.

```powershell
$pool = Initialize-ThreadJobBag -ThreadJob $threadJobs |
    Initialize-Pool |
    Start-ThreadJobPool -ThreadCount 8

$pool.Summary               # Counts for Active, Completed, Failed, and Stopped
$pool.Status.Active         # The job objects currently running
$pool.Status.Failed         # The job objects that failed
```

Omitting `-ThreadCount` or passing `0` selects the [default thread count][64].
The default and the initial number of jobs both cap concurrency. For example,
requesting 8 with 3 jobs and a default of 6 gives the scheduler 3 slots.

Read `Summary` or `Status` again to refresh it. To wait for the jobs and collect
their output, use the original job objects retained on the pool.

```powershell
$pool.ThreadJob | Wait-Job | Receive-Job
```

For file compression with interactive progress, see [Compress-FileTree][31].

  [47]: ./Private/Invoke-ParallelJob.ps1
  [48]: ./Private/Get-DefaultThrottleLimit.ps1

> Back to the [summary](#-summary)

### 🔑 Requiring administrator rights

Use [Test-Administrator][49] to check for an elevated session, or
[Assert-Administrator][50] to stop when the session is not elevated.

  [49]: ./Private/Test-Administrator.ps1
  [50]: ./Private/Assert-Administrator.ps1

> Back to the [summary](#-summary)

> Back to the [summary](#-summary)

## 🚧 Known issues and planned changes

- **The hash settings reach functions through hidden module variables.**
  [PSSecurity.psm1][36] copies the three HashIndex settings in
  [Config/Setting.psd1][40] into `$script:` variables, which
  [Write-DirectoryHash][15] reads without declaring them. The Linux functions
  already read their own files in [Config/][39] instead.
- **`Public/` is flat.** Group functions into subfolders by security domain, such
  as `Audit` and `Harden`. The loader in [PSSecurity.psm1][36] only reads `.ps1`
  files directly inside `Public/` and `Private/`, so it needs to search
  subfolders first.
- **There are several disparate recursive file implementations.** All implementations should be refactored to use one of the private `Get-File*Threaded` functions.
- **Do Not write linux config files from a powershell function.** Put the config in `./Config`, and copy it into place.

> Back to the [summary](#-summary)

## 📄 License

This project is [licensed under the MIT License](./LICENSE).
