<h1 align="center">
PSSecurity
</h1>

<p align="center">
  A PowerShell security toolkit.<br />
  File integrity indexing, AES-256 encryption,<br />
  Windows ACL and UAC management, local-admin provisioning,<br />
  and Authenticode auditing.
</p>

<p align="center">
  <a href="https://www.powershellgallery.com/packages/PSSecurity">
    <img alt="PowerShell Gallery Version" src="https://img.shields.io/powershellgallery/v/PSSecurity" />
  </a>
  <a href="https://www.powershellgallery.com/packages/PSSecurity">
    <img alt="PowerShell Gallery Downloads" src="https://img.shields.io/powershellgallery/dt/PSSecurity" />
  </a>
  <img alt="PowerShell 7+" src="https://img.shields.io/badge/PowerShell-7%2B-5391FE" />
  <img alt="Edition Core" src="https://img.shields.io/badge/edition-Core-2b579a" />
  <img alt="License MIT" src="https://img.shields.io/badge/license-MIT-2ea44f" />
</p>


---

## 🚀 Quick Start

Install from the
[PowerShell Gallery](https://www.powershellgallery.com/packages/PSSecurity).


## Install the Module

```powershell
Install-Module -Name PSSecurity
```

## Install Dependencies

To run the build, test, and linting phases, you will need to install the dependencies 
listed in [PSSecuritySettings.json](./PSSecuritySettings.json)

```powershell
Import-Module '.\PSSecurity.psm1'
```

- On first import of the module, you will be asked to install run time and build time dependencies.
- You will not be able to develop on the project without these dependencies.
- You will be able to use the core functionality of the module without external dependencies.

## Usage

Basic usage is outlined in the [Skill.md](./Skill/ps-security/SKILL.md) file.

- For more in depth usage, read the documentation starting at [PSSecurity.md](./Doc/PSSecurity.md)

## 📄 License

MIT. See [LICENSE](LICENSE).
