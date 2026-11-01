# Import-Ubuntu

*Imports an Ubuntu archive as a WSL 2 distribution.*

## DESCRIPTION

Creates the installation directory, then imports the tar archive with
wsl --import as a WSL 2 distribution. Supports -WhatIf and -Confirm. Windows
only.

## PARAMETERS

### -Path

The Ubuntu tar archive to import. Defaults to .\ubuntu.tar.

### -InstallPath

The directory for the distribution's virtual disk, created when missing.
Defaults to C:\WSL\DevUbuntu.

### -Name

The WSL distribution name. Defaults to DevUbuntu.

## EXAMPLES

### Example 1

```powershell
Import-Ubuntu
```

Imports .\ubuntu.tar as DevUbuntu in C:\WSL\DevUbuntu.

### Example 2

```powershell
Import-Ubuntu -Path .\ubuntu.tar -InstallPath C:\WSL\BuildUbuntu -Name BuildUbuntu
```

Creates the installation directory and imports the archive as BuildUbuntu.

### Example 3

```powershell
Import-Ubuntu -Name BuildUbuntu -InstallPath C:\WSL\BuildUbuntu -WhatIf
```

Previews the import without creating the directory or the distribution.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.String. The output of wsl --import.

