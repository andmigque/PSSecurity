# PSSecurity

A cross-platform PowerShell module for auditing and hardening Windows and Linux.

[![Open in vscode.dev](https://img.shields.io/badge/Open%20in-vscode.dev-blue)][1]

  [1]: https://vscode.dev/github/andmigque/PSSecurity

### 🧭 Summary

- [PSSecurity](#pssecurity)
    - [🧭 Summary](#-summary)
    - [✨ Features of PSSecurity include](#-features-of-pssecurity-include)
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
    - [⚡ Running work in parallel](#-running-work-in-parallel)
    - [🔑 Requiring administrator rights](#-requiring-administrator-rights)
  - [🔭 Roadmap](#-roadmap)
  - [🚧 Known issues and planned changes](#-known-issues-and-planned-changes)
  - [🚨 Vulnerabilities](#-vulnerabilities)
  - [📄 License](#-license)

### ✨ Features of PSSecurity 

PSSecurity helps you run multithreaded auditing and hardening workflows. The module is conceptually organized into four domains:

- [Audit][2] - Read ACLs, Authenticode signatures, scheduled tasks, UAC settings,
  and file hashes as PowerShell objects.
- [Harden][3] - Apply UAC policies, change ownership, encrypt with EFS, and remove unwanted AppX packages.
- [MultiThreaded][4] - Recurse large file trees and run work on a fixed pool of
  thread jobs, sized to 75% of the processors.
- [Doucmentation][5] - Generate Markdown documentation from each function's
  comment-based help.

  [2]: #-audit
  [3]: #-harden
  [4]: #-running-work-in-parallel
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

  [8]: ./Public/Deploy-PSProfile.ps1
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
[Install-Sftp][30] | Installs the Windows OpenSSH server as a chrooted SFTP drop point, with a firewall rule limited to given addresses.

  [23]: ./Public/New-LocalAdminUser.ps1
  [24]: ./Public/New-WindowsUserProfile.ps1
  [25]: ./Public/New-SecurityCertificate.ps1
  [26]: ./Public/Invoke-Sudo.ps1
  [27]: ./Public/Import-Ubuntu.ps1
  [28]: ./Public/Install-AzureDevOpsAgent.ps1
  [29]: ./Public/Install-DpkgPwsh.ps1
  [30]: ./Public/Install-Sftp.ps1

> Back to the [summary](#-summary)

### 🧰 Utilities

Command | Description
------- | -----------
[Compress-FileTree][31] | Recursively mirrors and compresses directory trees as gzip files using thread jobs.
[Convert-CommentHelpToMarkdown][32] | Converts PowerShell comment-based help into Markdown documents.
[Search-PatternInFile][34] | Searches the files under a path for a regular expression.

  [31]: ./Public/Compress-FileTree.ps1
  [32]: ./Public/Convert-CommentHelpToMarkdown.ps1
  [34]: ./Public/Search-PatternInFile.ps1

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
[Pipeline/][42] | Azure Pipelines definitions (`.yml`).
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
Convert-CommentHelpToMarkdown -Path ./Private -OutPath ./Doc/Private
```

> Back to the [summary](#-summary)

## 🔧 Writing Functions

Follow the rules and file structure in [AGENTS.md][6], and use its exemplar
functions as models.

### 📂 Finding Files
Pick a private recursive file implementation to use in your public function.  
Choose based on the size of the tree:

- [Get-FileSingleThreaded][45] - For small trees. It has no startup cost.
- [Get-FileMultiThreaded][46] - For large trees. It recurses into each subdirectory
  in parallel, at the cost of starting thread jobs.

  [45]: ./Private/Get-FileSingleThreaded.ps1
  [46]: ./Private/Get-FileMultiThreaded.ps1

> Back to the [summary](#-summary)

### ⚡ Running Multi Threaded Work

For long-running work with interactive, multi-threaded progress, see
[Compress-FileTree][31].

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

## 🔭 Roadmap

[Doc/Roadmap.md][59] plans new functions and states their requirements as
MUST, SHOULD, MAY, and MUST NOT rules. The first planned function is `Get-Log`,
which reads Windows Event Logs and the Linux journal through one set of
parameters and one output shape.

  [59]: ./Doc/Roadmap.md

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

## 🚨 Vulnerabilities

Known security issues in this repository that are not yet fixed.

- **The WSL pipelines expose the admin password on a command line.**
  [build-ubuntu-wsl-tar.yml][60] and [harden-ubuntu-wsl-tar.yml][61] set the
  password with `bash -c "echo 'admin:$($env:WSL_SUDOER)' | chpasswd"`. The
  password becomes part of the `wsl.exe` and `bash` arguments, so any process
  that can list command lines can read it, and command-line auditing and EDR
  logs record it. Fix: send it on standard input instead, with
  `"admin:$env:WSL_SUDOER" | wsl.exe -d $distro -u root -- chpasswd`.

  [60]: ./Pipeline/build-ubuntu-wsl-tar.yml#L50
  [61]: ./Pipeline/harden-ubuntu-wsl-tar.yml#L55

> Back to the [summary](#-summary)

## 📄 License

This project is [licensed under the MIT License](./LICENSE).
