# Get-FileSingleThreaded

*Returns the files in a directory that match a name pattern, on one thread.*

## DESCRIPTION

The sequential walker behind Get-FileMultiThreaded. Lists the files in -Directory
and, with -Recurse, every directory below it, using .NET enumeration and a
stack instead of Get-ChildItem or recursive function calls.

Directories whose name is in -Exclude are skipped entirely, so their contents
are never read. Directories that cannot be read are skipped instead of stopping
the walk. Symbolic links and junctions are not followed. Hidden and system
items are included. Name matching is case insensitive on every platform.

This function runs inside Invoke-ParallelJob workers, so it must not call
other functions from this module.

## PARAMETERS

### -Directory

The directory to list. Accepts directories from the pipeline.

### -Include

File name patterns to return, such as *.ps1. A file is returned when its name
matches any pattern.

### -Exclude

Directory names to skip, such as .git or node_modules. Matched against the
directory name only, not its path.

### -Recurse

Also lists every directory below -Directory. Without it, only the files
directly in -Directory are returned.

## EXAMPLES

### Example 1

```powershell
Get-FileSingleThreaded -Directory $HOME/Develop -Include '*.ps1' -Exclude '.git' -Recurse
```

Returns every PowerShell script under ~/Develop, skipping .git directories.

### Example 2

```powershell
Get-FileSingleThreaded -Directory /etc -Include '*.conf' -Exclude @()
```

Returns the .conf files directly in /etc, without reading subdirectories.

## INPUTS

System.IO.DirectoryInfo. You can pipe directories to this function.

## OUTPUTS

System.IO.FileInfo. One object for each matching file.

