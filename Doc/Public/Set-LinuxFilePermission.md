# Set-LinuxFilePermission

*Tightens the owner and mode of system files, cron directories, and home*
*directories to a rule table.*

## DESCRIPTION

Reads the rules in Config/LinuxFilePermission.psd1, or the file given with
-LiteralPath, and applies each one to every path it matches. The rules cover the
account databases, login banners, cron directories, and home directories, using
only values that hold on every distribution.

Mode is a floor: bits the rule does not allow are removed, and none are added,
so a repair never grants access a path did not already have. Owner and Group,
when a rule has them, are set with chown before the mode, because chown clears
the setuid and setgid bits. Paths that do not exist are skipped. Symbolic links
are skipped with a warning, because chown and chmod would change the file the
link points at.

Requires root. Supports -WhatIf and -Confirm. Linux only.

## PARAMETERS

### -LiteralPath

A .psd1 rule file to apply instead of Config/LinuxFilePermission.psd1. It must
hold a Rule list of hashtables with Path, Mode, and optionally Owner and Group.

### -PassThru

Returns each path that was changed.

## EXAMPLES

### Example 1

```powershell
Set-LinuxFilePermission -WhatIf
```

Lists each path that would change, with its owner and mode before and after.

### Example 2

```powershell
Invoke-Sudo { Import-Module ./PSSecurity.psd1; Set-LinuxFilePermission -PassThru }
```

Applies the rules as root and lists the paths that changed.

### Example 3

```powershell
Set-LinuxFilePermission -LiteralPath ./MyPermission.psd1
```

Applies a custom rule file.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.IO.FileSystemInfo. With -PassThru, one object per changed path.
Otherwise nothing.

