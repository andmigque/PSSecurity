# PSSecurity

A cross-platform PowerShell module for auditing and hardening Windows and Linux.

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PSSecurity)][58]
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/PSSecurity)][58]
[![PowerShell Gallery Platform](https://img.shields.io/powershellgallery/p/PSSecurity)][58]
[![Open in vscode.dev](https://img.shields.io/badge/Open%20in-vscode.dev-blue)][1]

  [1]: https://vscode.dev/github/andmigque/PSSecurity

### 🧭 Summary

- [PSSecurity](#pssecurity)
    - [🧭 Summary](#-summary)
    - [✨ PSSecurity Domains](#-pssecurity-domains)
  - [🎯 Goals](#-goals)
  - [🔭 Roadmap](#-roadmap)
  - [📦 Installation](#-installation)
  - [🚀 Getting started](#-getting-started)
  - [📖 Functionality by Domain](#-functionality-by-domain)
    - [🎲 Risk Management](#-risk-management)
    - [💎 Asset Security](#-asset-security)
    - [📐 Secure Design](#-secure-design)
    - [🌐 Network Security](#-network-security)
    - [🔐 Access Control](#-access-control)
    - [🧪 Security Testing](#-security-testing)
    - [📡 Security Operations](#-security-operations)
    - [💻 Secure Coding](#-secure-coding)
  - [📁 Repository layout](#-repository-layout)
    - [📝 Documentation](#-documentation)
  - [🚧 Known issues and planned changes](#-known-issues-and-planned-changes)
  - [🚨 Vulnerabilities](#-vulnerabilities)
  - [📄 License](#-license)

### ✨ PSSecurity Domains

1. [Risk Management][2]
2. [Asset Security][3]
3. [Secure Design][4]
4. [Network Security][5]
5. [Access Control][62]
6. [Security Testing][63]
7. [Security Operations][64]
8. [Secure Coding][65]

  [2]: #-risk-management
  [3]: #-asset-security
  [4]: #-secure-design
  [5]: #-network-security
  [62]: #-access-control
  [63]: #-security-testing
  [64]: #-security-operations
  [65]: #-secure-coding

## 🎯 Goals

1. **Minimal Dependencies**
   - Uses built-in PowerShell and .NET. No external module dependencies. 
2. **Cross-platform**
   - Supports Windows and Linux.
3. **LLM Friendly**
   - Comprehensive generated Markdown function documentation
   - `SKILL.md` with both Human and Agent utility
4. **Multi Threaded**
   - Lightweight thread job pools with .NET enumeration in lieu of Get-ChildItem
5. **Consistent Style**
   - House style function template available in Doc 

> Back to the [summary](#-summary)

## 🔭 Roadmap

[Doc/Roadmap.md][59] is a running list of advanced public functions and their associated requirements.

  [59]: ./Doc/Roadmap.md

> Back to the [summary](#-summary)

## 📦 Installation

Install PSSecurity from the PowerShell Gallery.

```powershell
Install-PSResource -Name PSSecurity -Repository PSGallery -Scope CurrentUser
```

  [7]: https://github.com/andmigque/PSSecurity
  [58]: https://www.powershellgallery.com/packages/PSSecurity

> Back to the [summary](#-summary)

## 🚀 Getting started

Import the module, then install the PSSecurity profile:

```powershell
Import-Module PSSecurity
Deploy-PSProfile
```

From a clone, import the manifest by path instead: `Import-Module ./PSSecurity.psd1`.

[Deploy-PSProfile][8] copies [Config/PwshProfile.ps1][9], which works on both
Windows and Linux, to your `$PROFILE`.

  [8]: ./Doc/Public/Deploy-PSProfile.md
  [9]: ./Config/PwshProfile.ps1

> Back to the [summary](#-summary)

## 📖 Functionality by Domain

PSSecurity functionality, grouped by domain.

### 🎲 Risk Management

- [cui-llm-redact][44]

> Back to the [summary](#-summary)

### 💎 Asset Security

- [Protect-Item][19]
- [Unprotect-Item][20]
- [Write-DirectoryHash][15]
- [Join-MegaHash][33]
- [Compare-MegaHash][51]
- [Compress-FileTree][31]

  [15]: ./Doc/Public/Write-DirectoryHash.md
  [19]: ./Doc/Public/Protect-Item.md
  [20]: ./Doc/Public/Unprotect-Item.md
  [31]: ./Doc/Public/Compress-FileTree.md
  [33]: ./Doc/Public/Join-MegaHash.md
  [51]: ./Doc/Public/Compare-MegaHash.md

> Back to the [summary](#-summary)

### 📐 Secure Design

- [Deploy-LinuxConfiguration][55]
- [Remove-App][21]
- [Remove-ProvisionedApp][22]
- [New-SecurityCertificate][25]

  [21]: ./Doc/Public/Remove-App.md
  [22]: ./Doc/Public/Remove-ProvisionedApp.md
  [25]: ./Doc/Public/New-SecurityCertificate.md
  [55]: ./Doc/Public/Deploy-LinuxConfiguration.md

> Back to the [summary](#-summary)

### 🌐 Network Security

- [Get-SshdConfiguration][52]
- [Install-Sftp][30]

  [30]: ./Doc/Public/Install-Sftp.md
  [52]: ./Doc/Public/Get-SshdConfiguration.md

> Back to the [summary](#-summary)

### 🔐 Access Control

- [Get-AclItem][10]
- [Set-AclItemOwner][18]
- [Get-UnixFileMode][53]
- [Add-UnixFileMode][54]
- [Set-LinuxFilePermission][56]
- [Get-UacConfiguration][13]
- [Set-UacConsentOnly][16]
- [Set-UacRequirePassword][17]
- [Get-SudoersAudit][57]
- [Invoke-Sudo][26]
- [New-LocalAdminUser][23]
- [New-WindowsUserProfile][24]

  [10]: ./Doc/Public/Get-AclItem.md
  [13]: ./Doc/Public/Get-UacConfiguration.md
  [16]: ./Doc/Public/Set-UacConsentOnly.md
  [17]: ./Doc/Public/Set-UacRequirePassword.md
  [18]: ./Doc/Public/Set-AclItemOwner.md
  [23]: ./Doc/Public/New-LocalAdminUser.md
  [24]: ./Doc/Public/New-WindowsUserProfile.md
  [26]: ./Doc/Public/Invoke-Sudo.md
  [53]: ./Doc/Public/Get-UnixFileMode.md
  [54]: ./Doc/Public/Add-UnixFileMode.md
  [56]: ./Doc/Public/Set-LinuxFilePermission.md
  [57]: ./Doc/Public/Get-SudoersAudit.md

> Back to the [summary](#-summary)

### 🧪 Security Testing

- [Get-ApplicationSignatureAudit][11]
- [Get-ScheduledTaskAudit][12]
- [Measure-OwnerAnomaly][14]

  [11]: ./Doc/Public/Get-ApplicationSignatureAudit.md
  [12]: ./Doc/Public/Get-ScheduledTaskAudit.md
  [14]: ./Doc/Public/Measure-OwnerAnomaly.md

> Back to the [summary](#-summary)

### 📡 Security Operations

- [Deploy-PSProfile][8]
- [Import-Ubuntu][27]
- [Install-AzureDevOpsAgent][28]
- [Install-DpkgPwsh][29]

  [27]: ./Doc/Public/Import-Ubuntu.md
  [28]: ./Doc/Public/Install-AzureDevOpsAgent.md
  [29]: ./Doc/Public/Install-DpkgPwsh.md

> Back to the [summary](#-summary)

### 💻 Secure Coding

- [Search-PatternInFile][34]
- [Convert-CommentHelpToMarkdown][32]

  [32]: ./Doc/Public/Convert-CommentHelpToMarkdown.md
  [34]: ./Doc/Public/Search-PatternInFile.md

> Back to the [summary](#-summary)

## 📁 Repository layout

Path | Contents
---- | --------
[PSSecurity.psd1][35] | Module manifest.
[PSSecurity.psm1][36] | Module loader.
[Public/][37] | File name matches function name, exported by the module.
[Private/][38] | File name matches function name, private to the module.
[Config/][39] | Configuration files. 
[Doc/][41] | Public and Private are generated.
[Pipeline/][42] | Azure Pipelines definitions (`.yml`).
[Skill/][43] | Agent skills, such as [cui-llm-redact][44].
[AGENTS.md][6] | Guidance for LLM's.

  [6]: ./AGENTS.md
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

> Back to the [summary](#-summary)

### 📝 Documentation

`Doc/Public/` and `Doc/Private/` are generated from comment-based help by
[Convert-CommentHelpToMarkdown][32]. Update the help inside a function, then
regenerate:

```powershell
Convert-CommentHelpToMarkdown -Path ./Private -OutPath ./Doc/Private
```

> Back to the [summary](#-summary)

## 🚧 Known issues and planned changes

- **The hash settings reach functions through hidden module variables.**
  [PSSecurity.psm1][36] copies the HashIndex settings in
  [Config/Setting.psd1][40] into `$script:` variables, which
  [Write-DirectoryHash][15] reads without declaring them. The Linux functions
  already read their own files in [Config/][39] instead.
- **`Public/` is flat.** Group functions into subfolders by security domain, such
  as `AccessControl` and `AssetSecurity`. The loader in [PSSecurity.psm1][36] only reads `.ps1`
  files directly inside `Public/` and `Private/`, so it needs to search
  sub folders first.
- **Some functions recurse file trees with their own code.** They should use
  `Get-Tree` instead. Find them by searching `Public/` for `-Recurse`.
- **[Compress-FileTree][31] runs its own thread-job pool.** It calls
  `Start-ThreadJob` directly instead of the module's shared thread-job
  functions, and installs ThreadJob from the PowerShell Gallery when
  `Start-ThreadJob` is missing.
- **Do Not write linux config files from a powershell function.** Put the config in `./Config`, and copy it into place.

> Back to the [summary](#-summary)

## 🚨 Vulnerabilities

Known security issues in this repository that are not yet fixed.

- **The WSL pipelines expose the admin password on a command line.**
  [build-ubuntu-wsl-tar.yml][60] and [harden-ubuntu-wsl-tar.yml][61] pass the
  admin password to `chpasswd` inside a `bash -c` argument. The password
  becomes part of the `wsl.exe` and `bash` command lines, so any process that
  can list command lines can read it, and command-line auditing and EDR logs
  record it. Fix: pipe it to `chpasswd` on standard input instead.

  [60]: ./Pipeline/build-ubuntu-wsl-tar.yml
  [61]: ./Pipeline/harden-ubuntu-wsl-tar.yml

> Back to the [summary](#-summary)

## 📄 License

This project is [licensed under the MIT License](./LICENSE).
