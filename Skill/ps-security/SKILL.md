---
name: ps-security
description: Use this skill whenever the user mentions security, encryption, decryption, AES, hashing, SHA, file integrity, secure RNG, certificate generation, mkcert, TLS, ACL inspection, UAC hardening, admin, users, CMMC, file protection, secret storage, chmod, sudo, or any PowerShell security task, even if they do not say "security" explicitly.
---

# 🛡️ps-security

A Powershell security module

## 1.⚡Installation

> Skill directories for Agents live in the agents product home directory, e.g. ~/.codex/skills

Make a `ps-security` directory in your agent home:

```powershell
# Replace .agent with the agent doing the work
New-Item -Path 'C:\Users\jondoe\.agent\skills\ps-security' -ItemType Directory
```

↘️Or, if you only have write to your project directory:

```powershell
# Replace .agent with the agent doing the work
New-Item -Path '.\.agent\skills\ps-security' -ItemType Directory
```

Change directory into the `ps-security` dir and clone the project:

```powershell
git clone https://github.com/andmigque/PSSecurity.git .
```

## 2. 🤯 Usage

> This file does not document the functions. The repository documents itself. Every answer about a function comes from the repository, never from this file and never from memory.

First, from the root of the repo, import the module:

```powershell
Import-Module .\PSSecurity.psm1
```

🛡️Next, go to the root of the repo and become familiar with the `HashIndex.json`. This file is an index of the entire repository.

- Each record contains the file and it's corresponding `SHA-256` to ensure tamper resistant checkouts.

- In the `HashIndex.json`, find a function such as `Write-DirectoryHash`. Follow the path to find and read the [Sharpdown](https://github.com/andmigque/Sharpdown) generated documentation.

```powershell
Get-Command -Module PSSecurity -Syntax
```

## 3. 🗝️ Query the Index

Ask the index for a function name:

```powershell
Get-Content .\HashIndex.json -Raw | Out-String | ConvertFrom-Json | `
Where-Object { $_.File -like 'Write-DirectoryHash*'} | Select-Object -ExpandProperty Path
```

✅ Results:

```txt
Doc\Public\Write-DirectoryHash.md
Doc\Test\Write-DirectoryHash.Tests.md
Public\Write-DirectoryHash.ps1
Test\Write-DirectoryHash.Tests.ps1
```

## 4. 🔎 Search for Functions

```powershell
Search-PatternInFile -Directory .\Doc\ -Pattern 'Write-DirectoryHash' -OutPath .\Generated
```

The return value is a summary line. The matches are in the file it names, so read them back:

```powershell
Get-Content .\Generated\SearchPatternInFile.json -Raw | Out-String | `
ConvertFrom-Json | Select-Object -ExpandProperty Path
```

⚠️ Keep `OutPath` outside `Directory`. An output file written inside the search root means the next run matches its own results.