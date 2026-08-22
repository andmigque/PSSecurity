# Get Up to Speed

Use this sequence to understand the repository without crawling every file.

## 1. Load Order

Use the following load order to effectively start a new session in this project.

### 1.1 

Read [README.md](./README.md) for the module's purpose, requirements, and entry points.

### 1.2 

If the `ps-security` skill did not lead you here, read [SKILL.md](./Skill/ps-security/SKILL.md) from Usage onward.

### 1.3 

Read [PSSecurity.md](./Doc/PSSecurity.md) to understand how the module loads.

### 1.4 

Read [os.build.md](./Doc/os.build.md) to understand how the repository is built and verified.

If the `ps-security` skill led you here, do not read it again.

## 2. Stop and Route the Task

Do not read every function, test, or generated document. Use `HashIndex.json` to locate only the files needed for the current task.

### 2.1 Task to Doc Mapping Table

Generated files under `Doc` are read-first documentation. Change the Sharpdown comments in source, then regenerate the documentation.

| Task | Read next |
| --- | --- |
| Use or explain a function | Its file under `Doc/Public`. |
| Change a public function | Its `Doc/Public`, `Public`, and `Test` files. |
| Change a private helper | Its `Doc/Private`, `Private`, and related `Test` files. |
| Change module loading | `PSSecurity.psm1` after reading `Doc/PSSecurity.md`. |
| Change build behavior | `os.build.ps1` after reading `Doc/os.build.md`. |

## 3. Build, Test, Document

To build, test, and document, just run invoke build from the root to execute the entire suite:

```powershell
Invoke-Build
```