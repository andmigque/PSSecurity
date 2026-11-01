# Get-UnixFileMode

*Finds files or directories whose Unix mode has any of the given bits set.*

## DESCRIPTION

Recurses the path and returns every file, or every directory with -ItemType
Directory, whose UnixFileMode includes at least one bit of -Mode. Use it to
find SUID and SGID binaries, world-writable files, and world-writable
directories.

Directories whose name is in -Exclude are skipped entirely. The defaults skip
the proc, sys, dev, and run pseudo filesystems, and mnt, where WSL mounts the
Windows drives with every file world-writable. Directories that cannot be read
are skipped, so run as root for a complete scan. Symbolic links are not
followed. The path itself is not checked, only the items below it.

Returns the raw .NET objects, which list as a flat table of names. Select
FullName and UnixFileMode to see the path and mode. Linux only.

## PARAMETERS

### -Path

The directories to search. Wildcards are accepted. Accepts paths from the
pipeline.

### -Mode

The mode bits to look for, such as SetUser, SetGroup, or OtherWrite. An item
matches when any of the bits is set.

### -ItemType

File returns files, Directory returns directories. Defaults to File.

### -Exclude

Directory names to skip, matched against the name only, not the path.
Defaults to proc, sys, dev, run, and mnt.

### -ThrottleLimit

The number of subdirectories recursed at once, from 1 through 255. Defaults
to 1, one thread. Higher values are faster on large or slow trees, slower on
small ones.

## EXAMPLES

### Example 1

```powershell
Get-UnixFileMode -Path / -Mode SetUser, SetGroup | Select-Object FullName, UnixFileMode
```

Lists the SUID and SGID files on the system.

### Example 2

```powershell
Get-UnixFileMode -Path / -Mode OtherWrite -ThrottleLimit 8
```

Lists the world-writable files on the system, recursing eight subdirectories
at a time.

### Example 3

```powershell
Get-UnixFileMode -Path /home, /var -Mode OtherWrite -ItemType Directory | Select-Object FullName, UnixFileMode
```

Lists the world-writable directories under /home and /var.

### Example 4

```powershell
Get-UnixFileMode -Path / -Mode OtherWrite -ItemType Directory | Add-UnixFileMode -Mode StickyBit
```

Adds the sticky bit to every world-writable directory that lacks it (CIS
1.1.21).

## INPUTS

System.String. You can pipe directory paths to this function.

## OUTPUTS

System.IO.FileInfo, or System.IO.DirectoryInfo with -ItemType Directory. One
object for each matching item.

