# Get-Tree

*Returns the directories, or with -File the files, below a path.*

## DESCRIPTION

Recurses each path with .NET enumeration and a stack, without Get-ChildItem or
recursive function calls. Returns every directory below the path, or every file
with -File. The path itself is not returned.

Directories whose name is in -Exclude are skipped entirely: they are not
returned and their contents are never read. Directories that cannot be read
are skipped instead of stopping the recursion. Symbolic links and junctions are
not followed. Hidden and system items are included. Name matching is case
insensitive on every platform.

Runs on one thread by default. With -ThrottleLimit above 1, the items directly
in the path are returned first, then each subdirectory is recursed by
Enter-ThreadQueue, -ThrottleLimit subdirectories at a time. Starting workers
costs time, so raise -ThrottleLimit for large trees, such as /, and leave it at
1 for small ones. With more than one worker, items are returned as workers find
them, not in tree order.

## PARAMETERS

### -Path

The directories to recurse. Wildcards are accepted. Accepts paths and
directory objects from the pipeline. A path that resolves to a file throws.

### -File

Returns files instead of directories.

### -Include

Name patterns to return, such as *.ps1. An item is returned when its name
matches any pattern. Defaults to every name.

### -Exclude

Directory names to skip, such as .git or proc. Matched against the directory
name only, not its path. Defaults to none.

### -ThrottleLimit

The number of subdirectories recursed at once, from 1 through 255. Defaults to
1, one thread.

## EXAMPLES

### Example 1

```powershell
Get-Tree -Path . -Exclude '.git'
```

Returns the directories below the current directory, skipping .git.

### Example 2

```powershell
Get-Tree -Path $HOME/Develop -File -Include '*.ps1', '*.psm1' -Exclude '.git', 'node_modules'
```

Returns every PowerShell script under ~/Develop.

### Example 3

```powershell
Get-Tree -Path / -File -Exclude 'proc', 'sys', 'dev' -ThrottleLimit 8
```

Returns every file on the system, recursing eight subdirectories at a time.

### Example 4

```powershell
Get-Tree -Path . -File -ThrottleLimit 4 |
    Enter-ThreadQueue -ThrottleLimit 4 { process { Get-AclItem -LiteralPath $_.FullName } } |
    Measure-OwnerAnomaly -Identity 'BUILTIN\Administrators'
```

Reads the owner of every file below the current directory on four threads, then
counts the files that Administrators does not own.

## INPUTS

System.String. You can pipe paths, or directory objects by their FullName, to
this function.

## OUTPUTS

System.IO.DirectoryInfo, or System.IO.FileInfo with -File. One object for each
item.

