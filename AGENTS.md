# Get Up to Speed

Use this sequence to understand the repository without crawling every file.

## Load Order

1. Read [README.md](./README.md) for the module's purpose, requirements, and entry points.
2. If the `ps-security` skill did not lead you here, read [SKILL.md](./Skill/ps-security/SKILL.md) from Usage onward.
3. Read [PSSecurity.md](./Doc/PSSecurity.md) to understand how the module loads.
4. Read [os.build.md](./Doc/os.build.md) to understand how the repository is built and verified.

If the `ps-security` skill led you here, do not read it again.

## Stop and Route the Task

Do not read every function, test, or generated document. Use `HashIndex.json` to locate only the files needed for the current task.

| Task | Read next |
| --- | --- |
| Use or explain a function | Its file under `Doc/Public`. |
| Change a public function | Its `Doc/Public`, `Public`, and `Test` files. |
| Change a private helper | Its `Doc/Private`, `Private`, and related `Test` files. |
| Change module loading | `PSSecurity.psm1` after reading `Doc/PSSecurity.md`. |
| Change build behavior | `os.build.ps1` after reading `Doc/os.build.md`. |

Generated files under `Doc` are read-first documentation. Change the Sharpdown comments in source, then regenerate the documentation.
